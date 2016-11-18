#!/usr/bin/perl
# @wxian

die "Usage: perl <file1.vcf> <file_standard.vcf> <depth>\n" unless (@ARGV ==3 );

my $IN = $ARGV[0];
my $ST=$ARGV[1];
my $depth=$ARGV[2];


my $s=0;
open (ST,'<',$ST);
my %hash=();
while (<ST>) {
	chomp;
	next if /^#/;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $key=join("\t",$line[0],$line[1],$line[4]);
	$hash{$key}=$key;
	$s=$s+1;
}
close ST;

my $i=0;
my $n=0;
open (IN,'<', $IN);
while (<IN>) {
	chomp;	
	my $line=$_;
	next if /^#/;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $index=join("\t",$line[0],$line[1],$line[4]);
	if (exists $hash{$index}) {
		$i=$i+1;
	}
	$n=$n+1;
}
close IN;

my $percent=$i/$s*100;
my $percent_2=sprintf "%0.2f", $percent;
print "$depth\t$s\t$n\t$i\t$percent_2\n";










