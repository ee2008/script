#!/usr/bin/perl

#find target gene in snpeff
# @wxian2016May05

die "Usage: perl $0 <in_snpeff.vcf> <out_pathway> <out_gene> " unless (@ARGV == 3);

my $SNPEFF = $ARGV[0];
my $OUTPUT_PATHWAY= $ARGV[1];
my $OUTPUT_GENE = $ARGV[2];

my $database="/lustre/project/og04/pub/database/human_genome_hg19/protein/annotation/Human_summary/Human.desc.xls";

open (IN,'<',$database);
our %hash=();
while (<IN>) {
    chomp;
    my $line=$_;
    next if /^GeneID/;
	my @line=split(/\|/,$line);
	my $key=@line[5];
	$hash{$key}=$line;
}
close IN;

open (SNPEFF,'<',$SNPEFF);
open (OUT,'>',$OUTPUT_PATHWAY);
open (OUT2,'>',$OUTPUT_GENE);
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














