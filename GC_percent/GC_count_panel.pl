#!/usr/bin/perl -w

# compute GC_percent(%)  in every needle form itools_data  
#@wxian2016Dec28


use strict;

die "Usage: perl $0 <*.itools_depth.gz> <out_dir>\n" unless (@ARGV >0);

my $in_file = $ARGV[0];
my $out_dir = $ARGV[1];
if (!-e $out_dir) {
	mkdir $out_dir;
}

my $needle="/p299/user/og04/wangxian/GC_percent_test/panel_designed/designed_panel12_sort_uniq.bed";
my $needle_no=`wc -l $needle | cut -d " " -f 1`;
chomp $needle_no;

my $sample=`basename $in_file .itools_depth.gz`;
chomp $sample;
my $out=$out_dir."/".$sample.".gc_content.txt";

my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START $mon $day $ht $year\n";
print ">  INPUT: $in_file\n";

my %hash_panel=();
my $p=0;
open (PANEL, '<', $needle); 
while (<PANEL>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	$p=$p+1;
	$hash_panel{$p}=$line;
}
close PANEL;



my $chr;
my $i=1;
my %hash_all=();
my %hash_gc=();
open (IN,"gzip -dc $in_file|") or die ("can not open $in_file\n");
while (<IN>) {
	chomp;
	my $line=$_;
	if ($line=~/^>(\w+)\s\s\s#/) {
		$chr=$1;
		next;
	}
	next if ($chr eq "MT");
	next if (/^>(\*)\s\s\s#/);
	my @line=split(/\t/,$line);
	next if ($line[1]+$line[2]+$line[3]+$line[4] <100);
	for (my $j=0;$j<7;$j++) {
		my $index=$i+$j;
		if (exists $hash_panel{$index}) {
			my $chr_index=(split /\t/, $hash_panel{$index})[0];
			my $start=(split /\t/, $hash_panel{$index})[1];
			my $end=(split /\t/, $hash_panel{$index})[2];
			if (($chr eq $chr_index) && ($line[0] >= $start) && ($line[0] <=$end)) {
				if (exists $hash_all{$index}) {
					$hash_all{$index}=$hash_all{$index}+$line[1]+$line[2]+$line[3]+$line[4];
					$hash_gc{$index}=$hash_gc{$index}+$line[2]+$line[4];
				} else {
					$hash_all{$index}=$line[1]+$line[2]+$line[3]+$line[4];
					$hash_gc{$index}=$line[2]+$line[4];
				}
			}
		}
	}
	if ($i < $needle_no) {
		my $i_chr=(split /\t/, $hash_panel{$i})[0];
		my $i_index=(split /\t/, $hash_panel{$i})[2];
		if (($chr eq $i_chr) && ($line[0] > $i_index)) {
			$i=$i+1;
		}
	}
}
close IN;


my $gc_percent;	
open (OUT, '>', $out);
#my @k=sort keys %hash_all;
for (my $key=1;$key<=$needle_no;$key++) {
	if ((not exists $hash_all{$key}) || ($hash_all{$key} ==0)) {
		$gc_percent="-";
	} else {
		$gc_percent=$hash_gc{$key}/$hash_all{$key}*100;
	}
	print OUT "$key\t$gc_percent\n";
}
close OUT;

($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> DONE $mon $day $ht $year\n";




