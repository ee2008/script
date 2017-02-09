#!/usr/bin/perl -w
# filter database (for SNP)
# must cut sample.vcf.annovar.hg19_multianno.txt first -- can ignore this if you use the script:filter_database.sh 
# @wxian20160822

use strict;

die "Usage: perl $0 <simply_annovar.txt> <simply_annodb.xls> <simply_oncotator.tsv> <out_file_suscepibility> <out_file_suscepibility_new>

file_info:
the colname in simply_annovar.txt: Chr,Start,End,Ref,Alt,Func.ensGene,Gene.ensGene,GeneDetail.ensGene,avsnp144,SIFT_score,SIFT_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,MutationTaster_score,MutationTaster_pred,CADD_raw,CADD_phred,COSMIC_ID,1000G_EAS,ESP6500siv2_ALL,cg46,cg69,clinvar_20150629,cosmic70

the colname in simply_annodb.xls:Func,Gene,Exonic|Biotype,Chr,Start

the colname in simply_oncotator.tsv:genome_change,HGNC_OMIM ID(supplied by NCBI),CGC_GeneID\n" unless (@ARGV ==5);

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
my $key2;

open (ONCOTATOR, '<', $oncotator);
while (<ONCOTATOR>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	next if /^genome_change/;
	my $chr=$line[0];
	my @chr=split(/:/,$chr);
	my $key1=substr($chr[0],5,length($chr[0]));
	if ($chr[1]=~/^(\d+)/) {
		$key2=$1;
	}
	#my $key2=substr($chr[1],0,length($chr[1])-3);
	$hash{$key1.$key2."CGC"}=$line[2];
	$hash{$key1.$key2."OMIM"}=$line[1];
}
close ONCOTATOR;

open (ANNODB, '<', $annodb);
while (<ANNODB>) {
	chomp;
	my $line=$_;
	next if (/^Func/);
	my @line=split(/\t/,$line);
	my $chr=substr($line[3],3,length($line[3]));
	$hash{$chr.$line[4]."gene"}="$line[0]\t$line[1]\t$line[2]";
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
	if ($line[24] < 10) {
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
		if ((($line[18] ne ".") &&  ($line[18] < 0.05)) || (($line[19] ne ".") &&  ($line[19] < 0.05))) {
			if ($line[10] eq "D") {
				$s=$s+1;
			}
			if (($line[12] eq "D") || ($line[12] eq "P")) {
				$s=$s+1;
			}
			if (($line[14] eq "A") || ($line[14] eq "D")){
				$s=$s+1;
			}
			if (($line[16] ne ".") && ($line[16] >= 10)) {
				$s=$s+1;
			}
		} 
		if ($s >=3) {
			$gene=$hash{$line[0].$line[1]."gene"};
			print OUT1 "$gene\t$line\t$CGC\t$OMIM\n";
		}
	} else {
		if (($line[5] ne "intronic") && ($line[5] ne "intergenic") && ($line[5] ne "downstream") && ($line[5] ne "upstream")) {
			$s=0;
			$e=0;
			if ((($line[18] ne ".") && ($line[18] < 0.01)) || (($line[19] ne ".") && ($line[19] < 0.01))) {
				if ($line[10] eq "D") {
					$s=$s+1;
				}
				if (($line[12] eq "D") || ($line[12] eq "P")) {
					$s=$s+1;
				}
				if (($line[14] eq "A") || ($line[13] eq "D")) {
					$s=$s+1;
				}
				if (($line[16] ne ".") && ($line[16] >= 10)) {
					$s=$s+1;
				}
			} 
			if ($s >=3) {
				$gene=$hash{$line[0].$line[1]."gene"};
				print OUT1 "$gene\t$line\t$CGC\t$OMIM\n";
			}
			my $n=0;
			if (($line[18] eq ".") && ($line[19] eq ".")) {
				if ($line[10] eq "D") {
					$n=$n+1;	
				}
				if (($line[12] eq "P") || ($line[11] eq "D")) {
					$n=$n+1;
				}
				if (($line[14] eq "A") || ($line[13] eq "D")) {
					$n=$n+1;
				}
				if (($line[16] ne ".") && ($line[16] >= 10)) {
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
		
