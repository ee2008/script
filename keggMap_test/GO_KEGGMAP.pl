#!/usr/bin/perl

#find target gene in snpeff
# @wxian2016Dec09

use strict;
use FindBin qw($Bin);

die "Usage: perl $0 <in_snpeff.vcf> <out_dir>\n" unless (@ARGV == 2);


my $kegg_map=$Bin."/keggMap.pl";
my $database="/lustre/project/og04/pub/database/human_genome_hg19/protein/annotation/Human_summary/Human.desc.xls";

my $SNPEFF = $ARGV[0];
my $OUT = $ARGV[1];
if (!-e $OUT) {
	mkdir $OUT;
}

my @path = split(/\//,$SNPEFF);
my @sample = split (/\./, @path[@path-1]);
my $sample = @sample[0];

my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START $mon $day $ht $year\n";
## === step 1: gene and pathway from var.snpeff.vcf

open (DATEBASE,'<',$database);
our %hash=();
while (<DATEBASE>) {
    chomp;
    my $line=$_;
    next if /^GeneID/;
	my @line=split(/\|/,$line);
	my $key=@line[5];
	$hash{$key}=$line;
}
close DATEBASE;

my $OUTPUT_GENE_tem = $OUT."/".$sample.".var.gene.txt";
my $OUTPUT_PATHWAY_tem = $OUT."/".$sample.".var.pathway.txt"; 

open (SNPEFF,'<',$SNPEFF);
open (OUT,'>',$OUTPUT_PATHWAY_tem);
open (OUT2,'>',$OUTPUT_GENE_tem);
while (<SNPEFF>) {
	chomp;
	my $line=$_;
	if (/#/) {
		next;
	}
	my @line=split(/\t/,$line);
	my @info=split(/;/,@line[7]);
	my @ANN=split(/,/,@info[$#info]);
	foreach (@ANN) {
		my $ANN=$_;
		my @gene_name=split(/\|/,$ANN);
		my $gene_type=@gene_name[1];
		if (($gene_type == "upstream_gene_variant") || ($gene_type =="downstream_gene_variant") || ($gene_type == "intron_variant") || ($gene_type == "intergenic_region")) {
			next;
		} else {
			my $gene_name=@gene_name[3];
			print OUT2 "$gene_name\n";
			if (exists $hash{$gene_name}) {
				print OUT "$hash{$gene_name}\n"
			}
		}
	}
}
close SNPEFF;
close OUT;
close OUT2;

## sort and uniq the gene and pathway txt
my $OUTPUT_PATHWAY_tem_nohead = $OUT."/".$sample.".var.pathway.uniq_nohead.txt";
my $OUTPUT_GENE = $OUT."/".$sample.".var.gene.uniq.txt";
my $OUTPUT_PATHWAY = $OUT."/".$sample.".var.pathway.uniq.txt";
`sort $OUTPUT_GENE_tem | uniq > $OUTPUT_GENE`;
`sort -n -k 1 $OUTPUT_PATHWAY_tem | uniq > $OUTPUT_PATHWAY_tem_nohead`;
`sed -e '1i\#GeneID\tPathway\tGO Component\tGO Function\tGO Process\tBlast nr' $OUTPUT_PATHWAY_tem_nohead > $OUTPUT_PATHWAY`;
`rm $OUTPUT_PATHWAY_tem $OUTPUT_GENE_tem $OUTPUT_PATHWAY_tem_nohead`;

## === step 2: prepare data for KEGGMAP

my $KEGGMAP_data=$OUT."/".$sample.".keggMap_data.txt";

my ($ko,@ko,$ko_no,$k,$pathway,@pathway);
open (IN, '<', $OUTPUT_PATHWAY);
open (OUT, '>', $KEGGMAP_data);
while (<IN>) {
	chomp;
	my $line=$_;
	next if /^#GeneID/;
	my @line=split (/\t/, $line);
	if ($line[1] ne "-") {
		my $kegg=();
		@pathway=split(/;/,$line[1]);
		for my $pathway(@pathway) {
			my @ko=split (/\/\//,$pathway);
			my $ko_no=substr($ko[0],2);
			my $k="K".$ko_no."\|".$ko[1];
			if ( $kegg ) {
				$kegg=$kegg."\!".$k;
			} else {
				$kegg=$k;
			}
		}
		print OUT "$line[0]\t$kegg\n";
	}
}
close IN;
close OUT;


## === step 3: PLOT KEGGMAP

my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> PLOTTING PATHWAY $mon $day $ht $year\n";
`/nfs/onegene/user/1gene/happy/soft/perl/bin/perl $kegg_map -ko $KEGGMAP_data -komap /nfs/database/db/Pub/kegg/RNA/59.3/komap/animal_ko_map.tab -diff $KEGGMAP_data -outdir $OUT/$sample`;

my %hash_path=();
open (IN_OUT, '<', $KEGGMAP_data);
while (<IN_OUT>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (exists $hash_path{$line[1]}) {
		$hash_path{$line[1]}=$hash_path{$line[1]}.";".$line[0];
	} else {
		$hash_path{$line[1]}=$line[0];
	}
}
close IN_OUT;

my $path_uniq=$OUT."/".$sample.".var.pathway.txt";
open (PATH, '>', $path_uniq); 
print PATH "#Pathway\tGene\n";
for my $key(keys %hash_path) {
	print PATH "$key\t$hash_path{$key}\n";
}


my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> DONE $mon $day $ht $year\n";


