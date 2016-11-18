#!/usr/bin/perl -w

use strict;

die "Usage: perl $0 <annovar.txt> <annodb.xls> <oncotator.vcf> <out_file_suscepibility> <out_file_suscepibility_new>\n" unless (@ARGV ==5);

my $annovar=$ARGV[0];
my $annodb=$ARGV[1];
my $oncotator=$ARGV[2];
my $out1=$ARGV[3];
my $out2=$ARGV[4];
my %hash=();
my $CGC;
my $OMIM;
my $gene;
my $s=0;
my $e=0;

open (ONCOTATOR, '<', $oncotator);
while (<ONCOTATOR>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	next if ((/^#/) || (/^Familial/));
	my $chr=$line[14];
	my @chr=split(/:/,$chr);
	my $key1=substr($chr[0],5,length($chr[0]));
	my $key2=substr($chr[1],0,length($chr[1])-3);
	$hash{$key1.$key2."CGC"}=$line[134];
	$hash{$key1.$key2."OMIM"}=$line[100];
}
close ONCOTATOR;

open (ANNODB, '<', $annodb);
while (<ANNODB>) {
	chomp;
	my $line=$_;
	next if (/^Func/);
	my @line=split(/\t/,$line);
	my $chr=substr($line[15],3,length($line[15]));
	$hash{$chr.$line[16]."gene"}="$line[0]\t$line[1]\t$line[2]";
}
close ANNODB;

open (ANNOVAR, '<', $annovar);
open (OUT1, '>', $out1);
open (OUT2, '>', $out2);

while (<ANNOVAR>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (/^Chr/) {
		print OUT1 "#Func\tGene\tExonic|Biotype\t$line\tCGC_GeneID\tHGNC_OMIM_ID(supplied_by_NCBI)\n";
		print OUT2 "#Func\tGene\tExonic|Biotype\t$line\tCGC_GeneID\tHGNC_OMIM_ID(supplied_by_NCBI)\n";
		next;
	}
	if (!$hash{$line[0].$line[1]."CGC"}) {
		$CGC=".";
	} else {
		$CGC=$hash{$line[0].$line[1]."CGC"};
	}
	if (!$hash{$line[0].$line[1]."OMIM"}) {
		$OMIM=".";
	} else {
		$OMIM=$hash{$line[0].$line[1]."OMIM"};
	}
	my $i=0;
	if ($CGC ne ".") {
		$i=$i+1;
	}
	if ($OMIM ne ".") {
		$i=$i+1;
	}
	if ($line[8] ne ".") {
		$i=$i+1;
	}
	if ($line[23] ne ".") {
		$i=$i+1;
	}
	if ($i >= 2) {
		$s=0;
		$e=0;
		if (($line[18] ne ".") &&  ($line[18] < 0.05)) {
			if ($line[10] eq "D") {
				$s=$s+1;
			}
			if ($line[11] ne ".") {
				$s=$s+1;
			}
			if ($line[13] ne ".") {
				$s=$s+1;
			}
			if ($line[15] ne ".") {
				$s=$s+1;
			}
		}
		if (($line[19] ne ".") && ($line[19] < 0.05)) {
			if ($line[10] eq "D") {
				 $e=$e+1;
			}
			if ($line[11] ne ".") {
				$e=$e+1;
			}
			if ($line[13] ne ".") {
				$e=$e+1;
			}
			if ($line[15] ne ".") {
				$e=$e+1;
			}
		}
		if (($s >=3) || ($e >=3)) {
			$gene=$hash{$line[0].$line[1]."gene"};
			print OUT1 "$gene\t$line\t$CGC\t$OMIM\n";
		}
	} else {
		if (($line[5] ne "intronic") && ($line[5] ne "intergenic") && ($line[5] ne "downstream") && ($line[5] ne "upstream")) {
			$s=0;
			$e=0;
			if (($line[18] ne ".") && ($line[18] < 0.01)) {
				if ($line[10] eq "D") {
					$s=$s+1;
				}
				if ($line[11] ne ".") {
					$s=$s+1;
				}
				if ($line[13] ne ".") {
					$s=$s+1;
				}
				if ($line[15] ne ".") {
					$s=$s+1;
				}
			} 
			if (($line[19] ne ".") && ($line[19] < 0.01)) {
				if ($line[10] eq "D") {
					$e=$e+1;
				}
				if ($line[11] ne ".") {
					$e=$e+1;
				}
				if ($line[13] ne ".") {
					$e=$e+1;
				}
				if ($line[15] ne ".") {
					$e=$e+1;
				}
			}
			if (($s >=3) || ($e >= 3)) {
				$gene=$hash{$line[0].$line[1]."gene"};
				print OUT1 "$gene\t$line\t$CGC\t$OMIM\n";
			}
			my $n=0;
			if (($line[18] eq ".") && ($line[19] eq ".")) {
				if ($line[10] eq "D") {
					$n=$n+1;	
				}
				if ($line[11] ne ".") {
					$n=$n+1;
				}
				if ($line[13] ne ".") {
					$n=$n+1;
				}
				if ($line[15] ne ".") {
					$n=$n+1;
				}
				if ($n >=3) {
					$gene=$hash{$line[0].$line[1]."gene"};
					print OUT2 "$gene\t$line\t$CGC\t$OMIM\n";
				}
			}
		}
	}
}
close ANNOVAR;
close OUT1;
close OUT2;
		
