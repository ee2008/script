#!/usr/bin/perl
# validate the format of maf file 

die "Usage: perl $0 <input_file> <output_file> <Tumor_Sample_Barcode> <Matched_Norm_Sample_Barcode>\n" unless (@ARGV == 4);

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
		if ((@line[8] eq "lincRNA")) {
			@line[8]="RNA";
		}
		if ((@line[8] eq "Start_Codon_SNP")) {
			@line[8]="Translation_Start_Site";
		}
		if ((@line[8] eq "Stop_Codon_Del")) {
			@line[8]="Nonstop_Mutation";
		}
		if ((@line[4] eq "M")) {
			@line[4]="MT";
		}
		@line[15] =$TUMOR;
		@line[16] =$NORMAL;
		$out = join("\t",@line);
#my $out = join("\t",@line[0..11,13..$#line]);
		print OUT "$out\n";
	}
}
close IN;
