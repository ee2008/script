#!/usr/bin/perl -w

# @wxian2016Sep19

use Getopt::Long;
use strict;

die "Usage: perl $0 -i <infile.sv.vcf> [-o <out_dir> | infile_dir] [-p <panel_info> | panel_info] [-r <range> | 100]\n" unless (@ARGV > 0);

my ($in,$panel,$out_dir,$range);
GetOptions(
	'i=s' =>\$in,
	'p=s' =>\$panel,
	'o=s' =>\$out_dir,
	'r=i' =>\$range,
);

if (!$panel) {
	$panel="/lustre/project/og04/pub/dev/panel_design_tumor_drug/result_r5/pick_out/panel1.info";
}

if (!$out_dir) {
	$out_dir=`dirname \$(readlink -e $in)`;
	chomp $out_dir;
} else {
	if (!-e $out_dir) {
		mkdir $out_dir;
	}
}

if (!$range) {
	$range=100
}


my %hash=();
my $po_100l;
my $po_100r;
my $index;
my $SU;
my $PE;
my $SR;
my $panel_title;
my $sample;

my @file=split(/\//,$in);
my $file=$file[@file-1];
$sample=(split /\./ , $file)[0];
chomp $sample;
my $out_tem=$out_dir."/".$sample."tem.tsv";
my $out=$out_dir."/".$sample.".sv.panel.tsv";

open (OUT_TEM, '>', $out_tem);
open (P, '<', $panel);
while (<P>) {
	chomp;
	if (/^#/) {
		$panel_title=$_;
		next;
	}
	my $line=$_;
	my @line=split(/\t/,$line);
	if (($line[6] eq "fusion")) {
		print OUT_TEM "$line\n";
	}
}
close P;


open (IN, '<', $in);
while (<IN>) {
	chomp;
	next if /^#/;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $svtype=(split /;/, $line[7])[0];
	my $type=(split /=/, $svtype)[1];
	if (($type eq "BND")) {
		if ($line[7] =~ /SU=(\d+);PE=(\d+);SR=(\d+)/) {
			$SU=$1;
			$PE=$2;
			$SR=$3;
		}
		$po_100l=$line[1]-$range;
		print OUT_TEM "$line[0]\t$po_100l\tSV\t$line[0]\t$line[1]\t$line[4]\t$SU\t$PE\t$SR\n";
		$po_100r=$line[1]+$range;
		if ( $po_100r != $po_100l) {
			print OUT_TEM "$line[0]\t$po_100r\tSV\t$line[0]\t$line[1]\t$line[4]\t$SU\t$PE\t$SR\n";
		}
	}
}
close IN;
close OUT_TEM;

my $out_tem_sort=$out_dir."/".$sample.".tem_sort.tsv";
`sort -n -k 1 -k 2 $out_tem > $out_tem_sort`;

open (TEM, '<', $out_tem_sort);
open (OUT, '>', $out);
print OUT "#CHR\tPOS\tALT\tSU\tPE\tSR\t$panel_title\n";
while (<TEM>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if ( $line[2] eq "SV" ) {
		$index=$line[3].$line[4];	
		if (exists $hash{$index}) {
			$hash{$index}="end";
		} else {
			$hash{$index}=join("\t",@line[3..8]);
		}
	} else {
		for my $key(keys %hash) {
			if ($hash{$key} ne "end") {
				print OUT "$hash{$key}\t$line\n";
			}
		}
	}
}
close TEM;
close OUT;


`rm $out_tem  $out_tem_sort`




