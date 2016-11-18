#!/usr/bin/perl

my $IN="/lustre/project/og04/shenzhongji/human_tumor/cancer_colorectal-20160220_hangzhou/custom_heredity/CRC_heredity.fix.snp.vcf";
my $REF="/lustre/project/og04/wangxian/colorectal_test/genetype.txt";
my $OUT="./genetype.vcf";

open (REF, '<', $REF);
my %hash=();
while (<REF>) {
	chomp;
	my $line=$_;
	next if /^#/;
	my @line=split(/\t/,$line);
	my $key=join("\t",$line[0],$line[1]);
	$hash{$key}=$line;
}
close REF;

open (IN,'<',$IN);
open (OUT,'>',$OUT);
while (<IN>){	
	chomp;
	my $line=$_;
	if (/^#/) {
		print OUT "$line\n";
		next;
	}
	my @line=split(/\t/,$line);
	my $ref=join("\t",$line[0],$line[1]);
	if (exists $hash{$ref}) {
		print OUT "$line\n";
	}
}
close IN;


