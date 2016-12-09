#!/usr/bin/perl -w

use strict;
use FindBin qw($Bin);
my $kegg_plot=$Bin."/keggMap.pl";

die "Usage: perl $0 <in_pathway.txt> <out_dir>\n" unless (@ARGV > 0);

my $in=$ARGV[0];
my $out_dir=$ARGV[1];

my @path=split(/\//,$in);
my $path;
my $sample=(split /\./, $path[@path-1])[0];
my $out=$out_dir."/".$sample.".keggMap_data.txt";

my ($ko,@ko,$ko_no,$k,$pathway,@pathway);
open (IN, '<', $in);
open (OUT, '>', $out);
while (<IN>) {
	chomp;
	my $line=$_;
	next if /^GeneID/;
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

`/nfs/onegene/user/1gene/happy/soft/perl/bin/perl $kegg_plot -ko $out -komap /nfs/database/db/Pub/kegg/RNA/59.3/komap/animal_ko_map.tab -diff $out -outdir $out_dir/$sample`;

my %hash=();
open (IN_OUT, '<', $out);
while (<IN_OUT>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (exists $hash{$line[1]}) {
		$hash{$line[1]}=$hash{$line[1]}.";".$line[0];
	} else {
		$hash{$line[1]}=$line[0];
	}
}
close IN_OUT;

my $path_uniq=$out_dir."/".$sample.".kegg_gene.txt";
open (PATH, '>', $path_uniq); 
print PATH "#Pathway\tGene\n";
for my $key(keys %hash) {
	print PATH "$key\t$hash{$key}\n";
}




