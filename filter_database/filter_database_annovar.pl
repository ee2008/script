#!/usr/bin/perl

die "Usage: perl $0 <in_file> <out_file>" unless (@ARGV == 2);
my $IN=$ARGV[0];
my $OUT=$ARGV[1];

open (IN, '<', $IN);
open (OUT, '>', $OUT);
while (<IN>) {
	chomp;
	my $line=$_;
	@line=split("\t",$line);
	if (/^Chr/) {
