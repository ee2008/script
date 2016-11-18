#!/usr/bin/perl -w
# to judge the pure of sample
# @wxian2016JULY20

use strict;

die "Usage: perl $0 in_file out_file\n" unless (@ARGV ==2 );

my $in=$ARGV[0];
my $out=$ARGV[1];

my $s08;
my $s11;
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
	if (($base[1] eq "K") || ($base[1] eq "M") || ($base[1] eq "R") || ($base[1] eq "S") || ($base[1] eq "W") || ($base[1] eq "Y")) {
		$s08="C";
	} else {
		$s08="P";
	}
	if (($base[4] eq "K") || ($base[4] eq "M") || ($base[4] eq "R") || ($base[4] eq "S") || ($base[4] eq "W") || ($base[4] eq "Y")) {
		$s11="C";
	} else {
		$s11="P";
	}
	if ( $s08 ne $s11 ) {
		print OUT "$line\n";
	}
}
close IN;
close OUT;













