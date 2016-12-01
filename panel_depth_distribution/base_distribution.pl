#!/usr/bin/perl -w

# @wxian2016Nov23

use FindBin qw($Bin);
use Getopt::Long;
use strict;
use Env;
my $dir="/nfs2/pipe/Re/Software/miniconda/lib:";
my @LD_LIBRARY_PATH;
push @LD_LIBRARY_PATH, $dir;

my $plot_base_distribution=$Bin."/plot_base_distribution.R";

die "Usage: perl $0 
	-p <project_dir> 
	-s <sample> 
	-o <out_dir> 
	[-d <depth>|100] 
	[-c <1,2..X,Y>|all] 
	[-min <min>|0] 
	[-max <max>|all]
	[-po <0/1>|0(not activated)]
	[-v_min <v_min>]: can only use when using -po or -c with one chromosome 
	[-v_max <v_max>]: can only use when using -po or -c with one chromosome 
	\n" unless (@ARGV > 0);

my ($project,$sample,$out_dir,$depth,$chr,@chr,$min,$max,$v_min,$v_max,$po);
GetOptions(
	'p=s' =>\$project,
	's=s' =>\$sample,
	'o=s' =>\$out_dir,
	'd=i' =>\$depth,
	'c=s' =>\$chr,
	'min=i' =>\$min,
	'max=i' =>\$max,
	'v_min=i' =>\$v_min,
	'v_max=i' =>\$v_max,
	'po=i' =>\$po,
);


if (!-e $out_dir) {
	mkdir $out_dir;
}

if (!$depth) {
	$depth=100;
}

if (!$v_min) {
	$v_min=0;
}
if (!$v_max) {
	$v_max=0;
}

my $panel_po=$project."/qc/panel/".$sample.".samtools_depth_bed.txt";
my $chr_po=$project."/qc/align/".$sample.".samtools_depth.txt.gz";

my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START $mon $day $ht $year\n";


my %hash;
open (PANEL, '<', $panel_po);
while (<PANEL>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	my $key=join("\t",@line[0..1]);
	$hash{$key}=$line[2];
}
close PANEL;

if ($chr) {
	@chr=split(",",$chr);
} else {
	@chr=(1..22,"X","Y");
}
open (CHR,"gzip -dc $chr_po|") or die ("can not open $chr_po\n");
my %hash_chr;
foreach my $id (@chr) {
	$hash_chr{$id}=0;
}

my ($v_line1,$v_line2);
my $out=$out_dir."/".$sample.".depth".$depth.".samtools_depth.txt";
open (OUT, '>', $out);
print OUT "NO\tCHR\tPO\tDEPTH\tPANEL\n";
while (<CHR>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/, $line);
	next if (($line[2] < $depth) || (not exists $hash_chr{$line[0]}));
	next if ((($min) && ($line[1] < $min)) || (($max) && ($line[1] > $max)));
	my $index=join("\t",@line[0..1]);
	$hash_chr{$line[0]}=$hash_chr{$line[0]}+1;
#	my $out_name="TMP".$line[0];
	if (($po) && ($po == 1)) {
		if (exists $hash{$index}) {
			print OUT "$line[1]\t$line\tred\n";
		} else {
			print OUT "$line[1]\t$line\tblue\n";
		}
	} else {
		if ($line[1] == $v_min) {
			$v_line1=$hash_chr{$line[0]};
		}
		if ($line[1] == $v_max) {
			$v_line2=$hash_chr{$line[0]};
		} 
		if (exists $hash{$index}) {
			print OUT "$hash_chr{$line[0]}\t$line\tred\n";
		} else {
			print OUT "$hash_chr{$line[0]}\t$line\tblue\n";
		}
	}	
}
close CHR;
close OUT;

if (($po) && ($po == 1)) {
	$v_line1=$v_min;
	$v_line2=$v_max;
}

if ((($v_line1) && ($v_line1 == 0)) || (!$v_line1)) {
	$v_line1=" ";
}
if ((($v_line2) && ($v_line2 == 0)) || (!$v_line2)) {
	$v_line2=" ";
}

($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> PLOT $mon $day $ht $year\n";

system("$plot_base_distribution $out $out_dir $depth $v_line1 $v_line2"); 

($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> DONE $mon $day $ht $year\n";

