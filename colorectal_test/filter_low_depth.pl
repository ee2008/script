#!/usr/bin/perl -w

use strict;

die "Usage: perl $0 <sample1.snp.vcf> <sample2.snp.vcf> ... <intersection.snp.vcf> <min_depth> <out.vcf>\n" unless (@ARGV > 0); 

my $s=@ARGV-4;
my @sample=@ARGV[0..$s];
my $input=@ARGV[@ARGV-3];
my $min_depth=$ARGV[@ARGV-2];
my $out=$ARGV[@ARGV-1];

my $key;
my $k1;
my $k2;
my $depth;
my %hash=();

open (IN, '<', $input);
while (<IN>) {
	chomp;
	next if /^#/;
	my $line=$_;
	my @line=split(/\t/,$line);
	$key=join("\t",$line[0],$line[1],$line[3],$line[4]);
	$hash{$key}=0;
}
close IN;

for my $sample(@sample) {
	open (SAMPLE, '<', $sample);
	while (<SAMPLE>) {
		chomp;
		next if /^#/;
		my $line=$_;
		my @line=split(/\t/,$line);
		$k1=join("\t",$line[0],$line[1],$line[3],$line[4]);
		if (exists $hash{$k1}) {
			if ($line[7] =~ /DP=(\d+);/) {
				$depth=$1;
				if ($depth >= $min_depth) {
					$hash{$k1}=$hash{$k1}+1;
				}
			}
		} else {
			next;
		}
	}
	close SAMPLE;
}

open (OUT, '>', $out);
print OUT "##fileformat=VCFv4.1\n";
print OUT "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n";
for my $k2(keys %hash) {
	if ($hash{$k2} == $s+1) {
		my @k2=split(/\t/,$k2);
		print OUT "$k2[0]\t$k2[1]\t.\t$k2[2]\t$k2[3]\t.\t.\t.\n";
	}
}
close OUT;
		



