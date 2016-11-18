#!/usr/bin/perl -w
# @wxian
use strict;

die "Usage: perl $0 [-d <delimiter>| \"\\t\"] <row_colname>\n" unless (@ARGV > 0);

my $in;
my $colname;
my $deli;
my $i=0;
my $j=1;
my $d=$ARGV[0];

if ($d eq "-d") {
	$deli=$ARGV[1];
	$in=$ARGV[2];
} else {
	$deli="\t";
	$in=$ARGV[0];
}

print "perl_id\tcolname\tshell_id\n";
open(IN, '<', $in);
while (<IN>) {
	chomp;
	my $line=$_;
	my @line=split(/$deli/,$line);
	foreach $colname (@line) {
		print "$i\t$colname\t$j\n";
		$i=$i+1;
		$j=$j+1;
	}
}



