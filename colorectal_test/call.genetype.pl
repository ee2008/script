#!/usr/bin/perl

my $IN = "./CRC_heredity.genotype";
my $OUT = "./genetype.txt";

open (IN,'<',$IN);
open (OUT, '>', $OUT);
while (<IN>) {
	chomp;
	my $line = $_;
	my @line = split (/\t/,$line);
	my $base = $line[2];
	my @base = split (/ /,$base);
	if (($base[0] ne $base[1]) and ($base[1] eq $base[2])) {
		if (($base[0] eq $base[3]) && ($base[0] eq $base[4]) && ($base[0] eq $base[5]) && ($base[0] eq $base[6]) && ($base[0] eq $base[7])) {
			print OUT "$line\n";
		}
	}
}
close IN;
