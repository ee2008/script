#!/usr/bin/perl
# @wxian2016Mar03

# == usage
die "Usage: perl $0 <file_prefix>" unless (@ARGV ==1);

my $time=localtime();
print ">>start at $time\n";

# == path
our $file_prefix = $ARGV[0];
our $GENE = "/lustre/project/og04/pub/database/onco_panel/gene";
our $ANNO = "/lustre/project/og04/shenzhongji/human_tumor/QuanlityAssessment/anno/";
#our $ANNO="/export/home/wangxian/test.pl/";
our $OUTPUT_GENE="/lustre/project/og04/wangxian/merge/".$file_prefix.".gene.snpeff.vcf";
our $UNION="/lustre/project/og04/wangxian/merge/".$file_prefix.".var.union";
#our $OUTPUT_GENE="/export/home/wangxian/test.pl/".$file_prefix.".gene.snpeff.vcf";
#our $UNION="/export/home/wangxian/test.pl/".$file_prefix.".union";
our $SNPEFF=$ANNO.$file_prefix.".var.snpeff.vcf";
our $INDEL_ANNODB=$ANNO.$file_prefix.".var.annodb.indel.exome_summary.csv";
our $SNP_ANNODB=$ANNO.$file_prefix.".var.annodb.snp.exome_summary.csv";
our $CLINVAR_ANNOVAR=$ANNO.$file_prefix.".var.annovar.hg19_clinvar_20150629_dropped";
our $COSMIC70_ANNOVAR=$ANNO.$file_prefix.".var.annovar.hg19_cosmic70_dropped";
our $ONCOTATOR=$ANNO.$file_prefix.".var.oncotator.vcf";

# == build index of gene
open (GENE, '<', $GENE);
our %hash_gene=();
while (<GENE>) {
	chomp;
	my $key=$_;
	$hash_gene{$key}=$_;
}
close GENE;

# == find gene in var.snpeff
open (SNPEFF,'<',$SNPEFF);
open (OUT,'>',$OUTPUT_GENE);
while (<SNPEFF>) {
	chomp;
	my $line=$_;
	if (/#/) {
		print OUT "$line\n";
		next;
	}
	my @line=split(/\t/,$line);
	my @info=split(/;/,@line[7]);
	my @ANN=split(/,/,@info[$#info]);
	foreach (@ANN) {
		my $ANN=$_;
		my @gene_name=split(/\|/,$ANN);
		my $gene_name=@gene_name[3];
		if (exists $hash_gene{$gene_name}) {
			print OUT "$line\n";
			last;
		}
	}
}
close SNPEFF;
print ">>finish finding the gene in snpeff file\n";
print ">>the output file:$OUTPUT_GENE\n";


# == get the union from var.annodb.indel, var.annodb.snp, var.annovar.clinvar, var.annovar.cosmic70, var.oncotator
# == build index of var.annodb.indel
open (INDEL,'<',$INDEL_ANNODB);
our %hash_indel=();
while (<INDEL>) {
	chomp;
	my $line=$_;
	next if /^Func/;
	$line=~/,chr(\w),(\d+)/;
	my $key_indel=join ("\t",$1,$2);
	$hash_indel{$key_indel}=$line;
}
close INDEL;

# == build index of var.snp.indel
open (SNP,'<',$SNP_ANNODB);
our %hash_snp=();
while (<SNP>) {
	chomp;
	my $line=$_;
        next if /^Func/;
        $line=~/,chr(\w),(\d+)/;
	my $key_snp=join ("\t",$1,$2);
        $hash_snp{$key_snp}=$line;
 }
close SNP;

# == build index of var.clinvar
open (CLINVAR,'<',$CLINVAR_ANNOVAR);
our %hash_clinvar=();
while (<CLINVAR>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $key_clinvar=join("\t",@line[10],@line[11]);
	$hash_clinvar{$key_clinvar}=$line;
}
close CLINVAR;

# == build index of var.cosmic70
open(COSMIC70,'<',$COSMIC70_ANNOVAR);
our %hash_cosmic70=();
while (<COSMIC70>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $key_cosmic70=join("\t",@line[10],@line[11]);
	$hash_cosmic70{$key_cosmic70}=$line;
}
close COSMIC70;

# == build index of oncotator
open(ONCOTATOR,'<',$ONCOTATOR);
our %hash_oncotator=();
while (<ONCOTATOR>) {
	chomp;
	next if /^#/;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $key_oncotator=join("\t",@line[0],@line[1]);
	$hash_oncotator{$key_oncotator}=$line;
}
close ONCOTATOR;

# == merge all data
open (IN,'<',$OUTPUT_GENE);
open (UNION,'>',$UNION);
while (<IN>) {
	chomp;
	next if /^#/;
	my $line=$_;
	print UNION "snpeff.vcf:\t$line\n";
	my @line=split(/\t/,$line);
	my $cp=join("\t",@line[0],@line[1]);
	if (exists $hash_indel{$cp}) {
		our $indel=$hash_indel{$cp};
	} else {
		our $indel="Not found!";
	}
	print UNION "annodb.indel:\t$indel\n";
	if (exists $hash_snp{$cp}) {
		our $snp=$hash_snp{$cp};
	} else {
		our $snp="Not found!";
	}
	print UNION "annodb.snp:\t$snp\n";
	if (exists $hash_clinvar{$cp}) {
		our $clinvar=$hash_clinvar{$cp};
	} else {
		our $clinvar="Not found!";
	}
	print UNION "anv.clinvar:\t$clinvar\n";
	if (exists $hash_cosmic70{$cp}) {
		our $cosmic70=$hash_cosmic70{$cp};
	} else {
		our $cosmic70="Not found!";
	}
	print UNION "anv.cosmic:\t$cosmic70\n";
	if (exists $hash_oncotator{$cp}) {
		our $oncotator=$hash_oncotator{$cp};
	} else {
		our $oncotator="Not found!";
	}
	print UNION "oncotator:\t$oncotator\n";
	print UNION "\n";
}

# == END
print ">>finish merging all files\n";
print ">>the output file:$UNION\n";
my $final_time=localtime();
print ">>finished at $final_time\n";


















	
	










