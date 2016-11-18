#!/usr/bin/perl -w
# to judge the pure of sample
# @wxian2016JULY20

use strict;

die "Usage: perl $0 in_file out_file\n" unless (@ARGV ==2 );

my $in=$ARGV[0];
my $out=$ARGV[1];

my $s09;
my $s10;
my $s13;
open (IN,'<',$in);
open (OUT,'>', $out);
while (<IN>) { 
	chomp;
	my $line=$_;
	if (/^#/) {
		print OUT "$line\n";
	}
	my @line=split(/\t/,$line);
	my @base=split(/ /,$line[2]);
	if (($base[2] eq "K") || ($base[2] eq "M") || ($base[2] eq "R") || ($base[2] eq "S") || ($base[2] eq "W") || ($base[2] eq "Y")) {
		$s09="C";
	} else {
		$s09="P";
	}
	if (($base[3] eq "K") || ($base[3] eq "M") || ($base[3] eq "R") || ($base[3] eq "S") || ($base[3] eq "W") || ($base[3] eq "Y")) {
		$s10="C";
	} else {
		$s10="P";
	}
	if (($base[6] eq "K") || ($base[6] eq "M") || ($base[6] eq "R") || ($base[6] eq "S") || ($base[6] eq "W") || ($base[6] eq "Y")) {
		$s13="C";
	} else {
		$s13="P";
	}
	if (( $s10 eq $s13 ) && ( $s09 ne $s10 )) {
		print OUT "$line\n";
	}
}
close IN;
close OUT;













