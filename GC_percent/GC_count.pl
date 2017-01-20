#!/usr/bin/perl -w

# GC content 
#@wxian2016Dec28


use strict;

die "Usage: perl $0 <*.itools_depth.gz> <out_dir>\n" unless (@ARGV >0);

my $in_file = $ARGV[0];
my $out_dir = $ARGV[1];
if (!-e $out_dir) {
	mkdir $out_dir;
}

my $sample=`basename $in_file .itools_depth.gz`;
chomp $sample;
my $out=$out_dir."/".$sample.".gc_content.txt";

my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START $mon $day $ht $year\n";
print ">  INPUT: $in_file\n";

my ($chr,$chr_last,,$start,$end,$percent);
my $i=1;
my $po=0;
my $gc=0;
my $base=0;
my $mt=0;
my %hash=();
open (IN,"gzip -dc $in_file|") or die ("can not open $in_file\n");
open (OUT, '>', $out);
while (<IN>) {
	chomp;
	my $line=$_;
	if ($line=~/^>(\w+)\s\s\s#/) {
		if ($1 ne "MT") {
			$chr=$1;
		} else {
			$mt=$1;
		}
		next;
	}
	if ($line=~/^>(\*)\s\s\s#/) {
		$end=$po;
		$percent=$gc/$base*100;
		my $start_print=$start;
		my $end_print=$end;
		while ($start_print <= $end_print) {
				print OUT "$chr\t$start_print\t$end_print\t$percent\t$hash{$start_print}\n";
				delete$hash{$start_print};
				$start_print=$start_print+1;
			}
		next;
	}
	next if ($mt eq "MT");
	my @line=split(/\t/,$line);
	next if ($line[1]+$line[2]+$line[3]+$line[4] <100);
	if ($line[0] == $po+1) {
		if ($i < 100) {
			$gc=$gc+$line[2]+$line[4];
			$base=$base+$line[1]+$line[2]+$line[3]+$line[4];
			$i=$i+1;
			$hash{$line[0]}=$line[1]+$line[2]+$line[3]+$line[4];
		} else {
			$end=$po;
			$percent=$gc/$base*100;
			my $start_print=$start;
			my $end_print=$end;
			while ($start_print <= $end_print) {
				print OUT "$chr\t$start_print\t$end_print\t$percent\t$hash{$start_print}\n";
				delete$hash{$start_print};
				$start_print=$start_print+1;
			}
			$start=$line[0];
			$gc=$line[2]+$line[4];
			$base=$line[1]+$line[2]+$line[3]+$line[4];
			$i=1;
			$hash{$line[0]}=$line[1]+$line[2]+$line[3]+$line[4];
		} 
	} else {
		$end=$po;
		if ($end != 0) {
			$percent=$gc/$base*100;
			my $start_print=$start;
			my $end_print=$end;
			while ($start_print <= $end_print) {
				print OUT "$chr\t$start_print\t$end_print\t$percent\t$hash{$start_print}\n";
				delete$hash{$start_print};
				$start_print=$start_print+1;
			}
		}
		$start=$line[0];
		$gc=$line[2]+$line[4];
		$base=$line[1]+$line[2]+$line[3]+$line[4];
		$i=1;
		$hash{$line[0]}=$line[1]+$line[2]+$line[3]+$line[4];
	} 
	$po=$line[0];
	$chr_last=$chr;
}
close IN;
close OUT;

($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> DONE $mon $day $ht $year\n";




