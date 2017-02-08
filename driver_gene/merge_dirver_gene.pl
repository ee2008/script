#!/usr/bin/perl -w

# @wxian2017Feb06
# merge the info of driver gene from 4 dataset


use strict;

my %hash_1=();
my %hash_2=();
my %hash_3=();
my %hash_4=();
my $head="#Gene";
open (IN1, '<', "./BestVogelstein125_1.txt");
while (<IN1>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (/^Gene/) {
		$head=$head."\t".$line;	
		next;
	}
	$hash_1{$line[0]}=$line;
}
close IN1;


open (IN2, '<', "./SMG127_2.TXT");
while (<IN2>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (/^Gene/) {
		$head=$head."\t".$line;	
		next;
	}
	$hash_2{$line[0]}=$line;
}
close IN2;


open (IN3, '<', "./Comprehensive435_3.txt");
while (<IN3>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (/^Gene/) {
		$head=$head."\t".$line;	
		next;
	}
	$hash_3{$line[0]}=$line;
}
close IN3;

open (IN4, '<', "./Cancer_gene_census609_4.txt");
while (<IN4>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (/^Gene/) {
		$head=$head."\t".$line;	
		next;
	}
	$hash_4{$line[0]}=$line;
}
close IN4;


open (OUT, '>', "./driver_gene_merge.txt");
print OUT "$head\n";
my $output;
open (GENE, '<', "./driver_gene_name_sort.txt");
while (<GENE>) {
	chomp;
	my $line=$_;
	if (exists $hash_1{$line}) {
		$output=$hash_1{$line};
	} else {
		$output=".\t.\t.\t.\t.\t.\t.\t.";
	}
	if (exists $hash_2{$line}) {
		$output=$output."\t".$hash_2{$line};
	} else {
		$output=$output."\t".".\t.\t.\t.\t.\t.";
	}
	if (exists $hash_3{$line}) {
		$output=$output."\t".$hash_3{$line};
	} else {
		$output=$output."\t".".\t.\t.\t.\t.\t.\t.\t.";
	}
	if (exists $hash_4{$line}) {
		$output=$output."\t".$hash_4{$line};
	} else {
		$output=$output."\t".".\t.\t.\t.\t.\t.\t.\t.\t.\t.\t.\t.\t.\t.\t.\t.\t.\t.";
	}
	print OUT "$line\t$output\n";
}
close GENE;
close OUT;













