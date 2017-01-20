#!/usr/bin/perl -w

#@wxian2016Dec30

use strict;

die "Usage: perl $0 <designed.bed> <out_file>\n" unless (@ARGV>0);

my $in = $ARGV[0];
my $out = $ARGV[1];

my %hash;
my $rank;
open (IN, '<', $in);
open (OUT,'>', $out);
while (<IN>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $start=$line[1];
	my $end=$line[2];
	my $level=1;
	my $key=$line[0]."\t".$line[1];
	if (exists $hash{$key}) {
		my @rank=split(/,/,$hash{$key});
		while ($level ~~ @rank ) {
			$level=$level+1;
		}
	}
	while ($start <= $end) {
		my $index=$line[0]."\t".$start;
		if (exists $hash{$index}) {
			$hash{$index}=$hash{$index}.",".$level;
		} else {
			$hash{$index}=$level;
		}
		my $percent=-$level*10;
		print OUT "$line[0]\t$start\t$percent\t$line[3]\n";
		$start=$start+1;
	}
}
close IN;
close OUT;




