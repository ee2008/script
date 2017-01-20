#!/usr/bin/perl -w


die "USAGE: perl $0 <in_file> <out_file>\n" unless (@ARGV >0);
my $in=$ARGV[0];
my $out=$ARGV[1];

open (IN, '<',$in);
open (OUT, '>',$out);
while (<IN>) {
	chomp;
	my $i=0;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $len=length($line[4]);
	for (my $n=0;$n<$len;$n++) {
		my $var=substr($line[4],$n,1);
		if (($var eq "G") || ($var eq "C")) {
			$i=$i+1;
		}
	}
	my $gc=$i/$len*100;
	print OUT "$line\t$gc\n";
}
close IN;
close OUT;






