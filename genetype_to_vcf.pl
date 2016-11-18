#!/usr/bin/perl
# change format to vcf

die "Usage: perl $0 <in_file> <out_vcf> " unless (@ARGV == 2);
my $IN = $ARGV[0];
my $OUT = $ARGV[1];

open (IN,'<',$IN);
open (OUT, '>', $OUT);
print OUT "##fileformat=VCFv4.1\n";
print OUT "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n";
while (<IN>) {
	chomp;
	next if /^#/;
	my $line = $_;
	my @line = split (/\t/,$line);
	print OUT "$line[0]\t$line[1]\t.\t$line[2]\t$line[3]\t.\t.\t.\n";
}
close IN;
