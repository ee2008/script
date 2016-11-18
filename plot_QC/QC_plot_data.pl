#!/usr/bin/perl -w

use strict;

die "Usage: perl $0 <sample_R1_fqstat.txt> <sample_R2_fqstat.txt> <out_sample_fqstat.txt> <sample_R1_fastqc_data.txt> <sample_R2_fastqc_data.txt> <out_sample_fastqc.txt> <sample_rank.samtools_depth_bed.txt> <out_sample_depth.txt> <total_base>\n" unless (@ARGV == 9);

my $R1_b=$ARGV[0];
my $R2_b=$ARGV[1];
my $OUT_b=$ARGV[2];
my $R1_q=$ARGV[3];
my $R2_q=$ARGV[4];
my $OUT_q=$ARGV[5];
my $DATA_d=$ARGV[6];
my $OUT_d=$ARGV[7];
my $t_base=$ARGV[8];
my $A_PER;
my $C_PER;
my $T_PER;
my $G_PER;
my $N_PER;
my $A;
my $C;
my $T;
my $G;
my $N;
my $SUM;
my $base;
my %hash=();
my $percent;
my $Percent;
my $accumulate_percent;
my $Accumulate_percent;

open (R1_b, '<', $R1_b);
open (OUT1_b, '>', $OUT_b);
while (<R1_b>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	next if ((/^#/) || /^\s*$/ );
	if (/^Po/) {
		print OUT1_b "Posi\tA\tC\tT\tG\tN\n";
		next;
	}
	$SUM=$line[1]+$line[2]+$line[3]+$line[4]+$line[5];
	$A_PER=$line[1]/$SUM*100;
	$A=sprintf"%0.2f",$A_PER;
	$C_PER=$line[2]/$SUM*100;
	$C=sprintf"%0.2f",$C_PER;
	$T_PER=$line[3]/$SUM*100;
	$T=sprintf"%0.2f",$T_PER;
	$G_PER=$line[4]/$SUM*100;
	$G=sprintf"%0.2f",$G_PER;
	$N_PER=$line[5]/$SUM*100;
	$N=sprintf"%0.2f",$N_PER;
	print OUT1_b "$line[0]\t$A\t$C\t$T\t$G\t$N\n";
}
close R1_b;
close OUT1_b;

open (R2_b, '<', $R2_b);
open (OUT2_b, '>>', $OUT_b);
while (<R2_b>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	next if ((/^#/) || /^\s*$/ || (/^Posi/));
	$SUM=$line[1]+$line[2]+$line[3]+$line[4]+$line[5];
	$A_PER=$line[1]/$SUM*100;
	$A=sprintf"%0.2f",$A_PER; 
	$C_PER=$line[2]/$SUM*100;
	$C=sprintf"%0.2f",$C_PER;
	$T_PER=$line[3]/$SUM*100;
	$T=sprintf"%0.2f",$T_PER;
	$G_PER=$line[4]/$SUM*100;
	$G=sprintf"%0.2f",$G_PER;
	$N_PER=$line[5]/$SUM*100;
	$N=sprintf"%0.2f",$N_PER;
	my $po=$line[0]+150;
	print OUT2_b "$po\t$A\t$C\t$T\t$G\t$N\n";
}
close R2_b;
close OUT2_b;

open (R1_q, '<', $R1_q);
open (OUT1_q, '>>', $OUT_q);
print OUT1_q "Base\tQuality\n";
my $i=0;
while (<R1_q>) {
	chomp;
	my $line=$_;
	if (/^#Base\tMean/) {
		$i=1;
	}
	if (/\>\>END_MODULE/) {
		$i=2;
	}
	my @line=split(/\t/,$line);
	if (($i == 1) && ($line[0] ne "#Base")) {
		my $quality=sprintf"%0.2f",$line[1];
		if (length($line[0]) <=3) {
			print OUT1_q "$line[0]\t$quality\n";
		} else {
			my $base_0=$line[0];
			my @base_0=split(/\-/,$base_0);
			while ($base_0[0]<=$base_0[1]) {
				print OUT1_q "$base_0[0]\t$quality\n";
				$base_0[0]=$base_0[0]+1;
			}
		}
	}
}
close R1_q;
close OUT1_q;

open (R2_q, '<', $R2_q);
open (OUT2_q, '>>', $OUT_q);
$i=0;
while (<R2_q>) {
 	chomp;
	my $line=$_;
	if (/^#Base\tMean/) {
		$i=1;
	}
	if (/\>\>END_MODULE/) {
		$i=2;
	}
	my @line=split(/\t/,$line);
	if (($i == 1) && ($line[0] ne "#Base")) {
		my $quality=sprintf"%0.2f",$line[1];
		if (length($line[0]) <= 3) {
			$base=$line[0] + 150;
			print OUT2_q "$base\t$quality\n";
		} else {
			my $base_0=$line[0];
			my @base_0=split(/\-/,$base_0);
			my $base_1=$base_0[0] + 150;
			my $base_2=$base_0[1] + 150;
			while ($base_1 <= $base_2) {
				print OUT2_q "$base_1\t$quality\n";
				$base_1=$base_1+1;
			}
		}
	}
}
close R2_q;
close OUT2_q;

$hash{max}=0;
open (DATA_d, '<', $DATA_d);
open (OUT_d, '>', $OUT_d);
while (<DATA_d>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	next if /^#/; 
	if (not exists $hash{$line[2]}) {
		$hash{$line[2]}=0;
	}
	$hash{$line[2]}=$hash{$line[2]}+1;
	if ($line[2] > $hash{max}) {
		$hash{max} = $line[2];
	}
}
close DATA_d;


for (my $i=0; $i<=$hash{max}; $i++) {
	$percent=$hash{$i}/$t_base*100;
	$Percent=sprintf"%0.2f",$percent;
	if ($i > 0) {
		$accumulate_percent=$accumulate_percent-$percent;
	} else {
		print OUT_d "Depth\tPercent\tAccumulate_percent\n";
		$accumulate_percent=100-$percent;
	}
	$Accumulate_percent=sprintf"%0.2f",$accumulate_percent;
	print OUT_d "$i\t$Percent\t$Accumulate_percent\n";
}
close OUT_d;
	
