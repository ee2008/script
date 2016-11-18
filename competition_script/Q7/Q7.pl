#!/nfs2/pipe/Re/Software/miniconda/bin/perl -w
# @wxian2016Aug15

use strict;

die "Usage: perl $0 <sample1> <sample2> <sample3> <out_file>\n" unless (@ARGV > 0);

my $s=@ARGV-2;
my @sample=@ARGV[0..$s];
my $out=$ARGV[@ARGV-1];

# parameter
my %hash=();
my %hash_s=();
my %hash_name=();

for my $sample(@sample) {
	open (IN, '<', $sample);
	while (<IN>) {
		chomp;
		next if /^pairwise/;
		my $line=$_;
		my @line=split(/\t/,$line);
		my @s_name=split(/\-/,$line[0]);
		$hash_s{$s_name[0]}=$s_name[0];
		$hash_s{$s_name[1]}=$s_name[1];
		$hash{$line[1]}{$s_name[0]}=$line[6];
		$hash{$line[1]}{$s_name[1]}=$line[7];
		$hash_name{$line[1]}=$line[1];
	}
	close IN;
}

open (OUT, '>>', $out);
my @s=sort keys %hash_s;
print OUT "miRNAid";
for my $key1(@s) {
	print OUT "\t$key1";
}
print OUT "\n";
for my $key(keys %hash_name) {
	print OUT "$key";
	for my $key2(@s) {
		if (not exists $hash{$key}{$key2}) {
			$hash{$key}{$key2}=0.01;
		}
		print OUT "\t$hash{$key}{$key2}";
	}
	print OUT "\n";
}













