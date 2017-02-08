#!/usr/bin/perl -w
# summary mutation type
# @wxian20160821


die "Usage: perl $0 <sample1.vcf> <sample2.vcf> ...[-o <out_dir> | ./]\n" unless (@ARGV > 0 );

use FindBin qw($Bin);
my $mutation_fraction_R=$Bin."/mutation_fraction_plot.R";
$ENV{'LD_LIBRARY_PATH'} = "/nfs2/pipe/Re/Software/miniconda/lib:".$ENV{'LD_LIBRARY_PATH'};

my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START $mon $day $ht $year\n";

my $s;
my $out="./";

if ($ARGV[@ARGV-2] eq "-o") {
	$s=@ARGV-3;
	$out=$ARGV[@ARGV-1];
} else {
	$s=@ARGV-1;
}


my @sample=@ARGV[0..$s];
my $out_bar=$out."/fraction_mutation_bar.txt";
my $out_heat=$out."/fraction_mutation_heat.txt";
my %hash=();

open (OUT1, '>', $out_bar);
open (OUT2, '>', $out_heat);
print OUT1 "Sample\tMutation_fra\tMutation_type\n";
print OUT2 "Sample\tCTGA\tTCAG\tCGGC\tCAGT\tTGAC\tTAAT\n";
for my $sample(@sample) {
	$hash{CT}=0;
	$hash{GA}=0;
	$hash{TC}=0;
	$hash{AG}=0;
	$hash{CG}=0;
	$hash{GC}=0;
	$hash{CA}=0;
	$hash{GT}=0;
	$hash{TG}=0;
	$hash{AC}=0;
	$hash{TA}=0;
	$hash{AT}=0;
	open (IN, '<', $sample);
	my @file_name=split(/\//,$sample);
	my $file_name=$file_name[@file_name-1];
	my $sample_name=(split /\./,$file_name)[0];
	my $n=0;
	while (<IN>) {
		chomp;
		next if /^#/;
		my $line=$_;
		my @line=split(/\t/,$line);
		if (exists $hash{$line[3].$line[4]}) {
			$hash{$line[3].$line[4]}=$hash{$line[3].$line[4]}+1;
			$n=$n+1;
		}
	}		
	close IN;
	my $CTGA=($hash{CT}+$hash{GA})/$n;
	$CTGA=sprintf"%0.4f",$CTGA;
	my $TCAG=($hash{TC}+$hash{AG})/$n;
	$TCAG=sprintf"%0.4f",$TCAG;
	my $CGGC=($hash{CG}+$hash{GC})/$n;
	$CGGC=sprintf"%0.4f",$CGGC;
	my $CAGT=($hash{CA}+$hash{GT})/$n;
	$CAGT=sprintf"%0.4f",$CAGT;
	my $TGAC=($hash{TG}+$hash{AC})/$n;
	$TGAC=sprintf"%0.4f",$TGAC;
	my $TAAT=($hash{TA}+$hash{AT})/$n;
	$TAAT=sprintf"%0.4f",$TAAT;
	print OUT1 "$sample_name\t$CTGA\tC>T/G>A\n$sample_name\t$TCAG\tT>C/A>G\n$sample_name\t$CGGC\tC>G/G>C\n$sample_name\t$CAGT\tC>A/G>T\n$sample_name\t$TGAC\tT>G/A>C\n$sample_name\t$TAAT\tT>A/A>T\n";
	print OUT2 "$sample_name\t$CTGA\t$TCAG\t$CGGC\t$CAGT\t$TGAC\t$TAAT\n";
}
close OUT1;
close OUT2;

($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START PLOTTING $mon $day $ht $year\n";


system("$mutation_fraction_R $out_bar $out_heat $out"); 

($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> DONE $mon $day $ht $year\n";

