#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <in.vcf> <out_panel1.file> <out_panel2.file> " unless (@ARGV == 3);

my $IN=$ARGV[0];
my $OUT_panel1=$ARGV[1];
my $OUT_panel2=$ARGV[2];

my $panle1="/lustre/project/og04/pub/dev/panel_design_tumor_drug/result_r8/panel1.merge.bed";
my $panel2="/lustre/project/og04/pub/dev/panel_design_tumor_drug/result_r8/panel2.merge.bed";
my $panel1_full="./tem_panel1.bed";
my $panel2_full="./tem_panel2.bed";

my %hash_panel1=();
open (PANEL1, '<', $panle1);
open (TEM_panel1, '>', $panel1_full);
while (<PANEL1>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $r1=$line[1];
	my $r2=$line[2];
	my $key1_r1=$line[0]."_".$r1;
	$hash_panel1{$key1_r1}=$r1;
	print TEM_panel1 "$key1_r1\n";
	while ($r2 > $r1) {
		$r1=$r1+1;
		my $key1_r1=$line[0]."_".$r1;
		$hash_panel1{$key1_r1}=$r1;
		print TEM_panel1 "$key1_r1\n";
	}
}
close PANEL1;
close TEM_panel1;

my %hash_panel2=();
open (PANEL2, '<', $panel2);
open (TEM_panel2, '>', $panel2_full);
while (<PANEL2>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $r1=$line[1];
	my $r2=$line[2];
	my $key2_r1=$line[0]."_".$r1;
	$hash_panel2{$key2_r1}=$r1;
	print TEM_panel2 "$key2_r1\n";
	while ($r2 > $r1) {
		$r1=$r1+1;
		my $key2_r1=$line[0]."_".$r1;
		$hash_panel2{$key2_r1}=$r1;
		print TEM_panel2 "$key2_r1\n";
	}
}
close PANEL2;
close TEM_panel2;

open (IN, '<', $IN);
open (OUT1, '>', $OUT_panel1);
open (OUT2, '>', $OUT_panel2);
while (<IN>) {
	chomp;
	my $line=$_; 
	my @line=split(/\t/,$line);
	my $key=$line[0]."_".$line[1];
	#print "$key\n";
	if (exists $hash_panel1{$key}) {
		print OUT1 "$line\n";
	}
	if (exists $hash_panel2{$key}) {
		print OUT2 "$line\n";
	}
}
close OUT1;
close OUT2;

unlink($panel1_full);
unlink($panel2_full);

