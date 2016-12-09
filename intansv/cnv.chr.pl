#!/usr/bin/perl

# delete the chr of cheomosome name
# @wxian2016Mar10

die "Usage: perl $0 [cnv.file.old] [cnv.file]\n" unless (@ARGV == 2);

my $in = $ARGV[0];
my $out = $ARGV[1];

open (IN,'<',$in);
open (OUT,'>',$out);
while (<IN>) {
	chomp;
	if (/#/) {
		print OUT "$line\n";
		next;
	}
	my $line = $_;
	my @line =split(/\t/,$line);
	my $chr=@line[1];
	if ($chr =~/^chr/) {
		@line[1] = substr($chr,3);
	}
	my $out = join("\t",@line);
	print OUT "$out\n";
}
close IN;
