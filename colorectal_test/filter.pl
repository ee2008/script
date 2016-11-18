#!/usr/bin/perl

die "Usage: perl $0 <in_file> <out_file> " unless (@ARGV == 2);
my $IN=$ARGV[0];
my $OUT=$ARGV[1];

open (IN, '<', $IN);
open (OUT, '>', $OUT);
while (<IN>) {
	chomp;
	my $line=$_;
	@line=split("\t",$line);
	if (/^Chr/) {
		my $out=join("\t",$line[0],$line[1],$line[2],$line[3],$line[4],$line[53],$line[54],$line[55],$line[102],$line[103],$line[104]);
		print OUT "$out\n";
	}
	if (( $line[10] eq "." ) && ($line[11] eq ".") && ($line[12] eq ".") && ($line[13] eq ".") && ($line[144] eq ".") && ($line[194] eq ".") && ($line[195] eq ".") && ($line[196] eq ".") && ($line[197] eq ".") && ($line[198] eq ".") && ($line[199] eq ".") && ($line[208] eq ".") && ($line[209] eq ".") && ($line[210] eq ".") && ($line[9] eq ".")) { 
		my $out=join("\t",$line[0],$line[1],$line[2],$line[3],$line[4],$line[53],$line[54],$line[55],$line[102],$line[103],$line[104]);
		print OUT "$out\n";
	}
}
close IN;
