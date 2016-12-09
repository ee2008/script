#!/usr/bin/perl
# validate the format of maf file 

die "Usage: perl $0 <input_file> <output_file> <tumor_name> <nromal_name>" unless (@ARGV == 4);

$IN = $ARGV[0];
$OUT = $ARGV[1];
$TUMOR = $ARGV[2];
$NORMAL = $ARGV[3];

open (IN,'<',$IN);
open (OUT,'>',$OUT);
my $i=0;
while (<IN>) {
	chomp;
	my $line = $_;
	if (/^#/ || /^Hugo_Symbol/) {
		print OUT "$line\n";
		next;
	}
	$i=$i+1;
	if (($i%2 ne 0)) {
		my @line = split(/\t/,$line);
		@line[15] =$TUMOR;
		@line[16] =$NORMAL;
		$out = join("\t",@line);
#my $out = join("\t",@line[0..11,13..$#line]);
		print OUT "$out\n";
	}
}
close IN;
