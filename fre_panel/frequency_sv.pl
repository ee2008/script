#!/usr/bin/perl -w
#extract frequency by *.sv.join.tsv
# @wxian2016Oct27

use strict;

die "Usage: perl $0  <project_dir> <in_file> <somatic/germline> <col_chr(from 0,1..)> <out_dir> <postfix>\n" unless (@ARGV > 0);

my $project=$ARGV[0];
my $in=$ARGV[1];
my $t=$ARGV[2];
my $chr=$ARGV[3];
my $out_dir=$ARGV[4];
my $postfix=$ARGV[5];


if (!-e $out_dir) {
	mkdir $out_dir;
}

my @file=split(/\//,$in);
my $file=$file[@file-1];
my $sample=(split /\./ , $file)[0];
chomp $sample;
my $vcf=$project."/var/".$sample.".sv.vcf";
my $out=$out_dir."/".$sample.".".$postfix;

my %hash=();
my ($key,$index,$info,$svtype,@fre,@fre_N,@fre_T);
open (VCF, '<', $vcf);
while (<VCF>) {
	chomp;
	next if /^#/;
	my $line=$_;
	my @line=split(/\t/, $line);
	$info=(split /\;/, $line[7])[0];
	$svtype=(split /\=/, $info)[1];
	$key=join("\t",$line[0],$line[1]);
	if ($t eq "germline") {
		@fre=split(/\:/,$line[9]);
		$hash{$key}=join("\t", @fre[1..3],$svtype);
	} else {
		@fre_N=split(/\:/,$line[9]);
		@fre_T=split(/\:/,$line[10]);
		$hash{$key}=join("\t", @fre_N[1..3],@fre_T[1..3],$svtype);
	}
}
close VCF;

open (IN, '<', $in);
open (OUT, '>', $out);
while (<IN>) {
	chomp;
	my $line=$_;
	my @line=split (/\t/,$line);
	if ((/^#/) || (/^chr/)) {
		if ($t eq "germline") {
			print OUT "$line\tSU\tPE\tSR\tSVTYPE\n";
		} else {
			print OUT "$line\tN_SU\tN_PE\tN_SR\tT_SU\tT_PE\tT_SR\tSVTYPE\n";
		}
		next;
	}
	$index=join("\t",$line[$chr],$line[$chr+1]);
	if (exists $hash{$index}) {
		print OUT "$line\t$hash{$index}\n";
	} else {
		if ($t eq "germline") {
			print OUT "$line\t.\t.\t.\t.\n";
		} else {
			print OUT "$line\t.\t.\t.\t.\t.\t.\t.\n";
		}
	}
}
close IN;
close OUT;





