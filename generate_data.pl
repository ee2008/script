#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <in_cns.po.txt> <out_file> <category_count> < disease_count>\n" unless (@ARGV==4);

my $in = $ARGV[0];
my $out = $ARGV[1];
my $category = $ARGV[2];
my $disease = $ARGV[3];
my $suggestion="./suggestion.txt";

my %hash1=();
my %hash2=();
my %hash3=();
my $ALT=();
my $genetype=();
my $advantage=();

open (SUG, '<', $suggestion);
while (<SUG>) {
	next if /^#/;
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	$hash1{$line[0]}{$line[2]}->{sug}=$line[4];
}
close SUG;

$hash1{gene}="\"genes\":[";
$hash1{advantage}="\"advantage\":[";

open (IN, '<', $in);
open (OUT, '>', $out);

while (<IN>) {
	next if /^#/;
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if ( not exists $hash1{$line[0]}{$line[2]}->{or} ) {
		$hash1{$line[0]}{$line[2]}->{or}=1;
	}

	if (($line[20] eq "K") || ($line[20] eq "M") || ($line[20] eq "R") || ($line[20] eq "S") || ($line[20] eq "W") || ($line[20] eq "Y")) {
		$ALT=$line[35];
		$genetype=$line[19].$line[35];
	} else {
		$ALT=$line[20];
		$genetype=$line[20].$line[20];
	}

	if (($line[0] eq "2") || ($line[0] eq "7")) {
		if (length($line[9]) eq 2) {
			if (not exists $hash1{$line[0]}{$line[2]}->{$line[9]}) {
				$hash1{$line[0]}{$line[2]}->{$line[9]}=1;
			}
			if (($genetype ne $line[9]) && ($hash1{$line[0]}{$line[2]}->{$line[9]} <3 )) {
				$hash1{$line[0]}{$line[2]}->{$line[9]}=$hash1{$line[0]}{$line[2]}->{$line[9]}+1;
				next;
			}
		}
	}

	if (($line[9] eq $ALT) || ($line[9] eq $genetype)) {
		if (($line[20] eq "K") || ($line[20] eq "M") || ($line[20] eq "R") || ($line[20] eq "S") || ($line[20] eq "W") || ($line[20] eq "Y")) {
			$hash1{$line[0]}{$line[2]}->{or}=$hash1{$line[0]}{$line[2]}->{or}*$line[15];
		} else {
			$hash1{$line[0]}{$line[2]}->{or}=$hash1{$line[0]}{$line[2]}->{or}*$line[14];
		}
		$hash1{$line[0]}{$line[2]}->{influence}="\"influence\":"."\"$line[11]\"";
	} else {
		$hash1{$line[0]}{$line[2]}->{influence}="\"influence\":"."\"正常\"";
	}

	$hash2{$line[0]}->{classification_id}="\"classification_id\":"."\"$line[0]\"";
	$hash2{$line[0]}->{classification_name}="\"name\":"."\"$line[1]\"";
	$hash1{$line[0]}{$line[2]}->{id}="\"id\":"."\"$line[2]\"";
	$hash1{$line[0]}{$line[2]}->{name}="\"name\":"."\"$line[3]\"";
	$hash1{$line[0]}{$line[2]}->{or_value}="\"or_value\":"."\"$hash1{$line[0]}{$line[2]}->{or}\"";
		
	if ($hash1{$line[0]}{$line[2]}->{or} < 1) {
		$hash1{$line[0]}{$line[2]}->{level}="\"level\":\"0\"";
	} elsif ($hash1{$line[0]}{$line[2]}->{or} < $line[16]){
		$hash1{$line[0]}{$line[2]}->{level}="\"level\":\"2\"";
	} else {
		$hash1{$line[0]}{$line[2]}->{level}="\"level\":\"4\"";
	}
		
	$hash1{$line[0]}{$line[2]}->{probability}="\"probility\":"."\"NA\"";
		
	if (not exists $hash1{$line[0]}{$line[2]}->{gene}) {
		$hash1{$line[0]}{$line[2]}->{gene}="\"gene\":[";
	}
	if ($hash1{$line[0]}{$line[2]}->{level} eq "\"level\":\"4\"") {
		$hash1{$line[0]}{$line[2]}->{advantage}="\"advantage\":["."\"$line[3]"."风险高\"";
		if (not exists $hash1{$line[0]}{$line[2]}->{sug}) {
			$hash1{$line[0]}{$line[2]}->{suggestion}="\"suggestion\":"."[]";
		} else {
			$hash1{$line[0]}{$line[2]}->{suggestion}="\"suggestion\":"."[\"$hash1{$line[0]}{$line[2]}->{sug}\"]";
		}
	} elsif ($hash1{$line[0]}{$line[2]}->{level} eq "\"level\":\"2\"") {
		$hash1{$line[0]}{$line[2]}->{advantage}="\"advantage\":["."\"$line[3]"."风险一般\"";
		$hash1{$line[0]}{$line[2]}->{suggestion}="\"suggestion\":"."[\"您的基因检测结果正常，请您继续保持良好的生活习惯\"]";
	} else {
		$hash1{$line[0]}{$line[2]}->{advantage}="\"advantage\":["."\"$line[3]"."风险较低\"";
		$hash1{$line[0]}{$line[2]}->{suggestion}="\"suggestion\":"."[\"您的基因棒棒哒\"]";
	}

	$hash1{$line[0]}{$line[2]}->{notice}="\"notice\":"."[]";

	$hash1{$line[0]}{$line[2]}->{gene}=$hash1{$line[0]}{$line[2]}->{gene}."{\"name\":"."\"$line[12]\"".","."\"chrom\":"."\"$line[5]\"".","."\"rs_pos\":"."\"$line[6]\"".","."\"rs_id\":"."\"$line[4]\"".","."\"location\":"."\"$line[13]\"".","."\"gene_type\":"."\"".$genetype."\"".","."\"gene_probility\":"."\"$line[10]\"".",".$hash1{$line[0]}{$line[2]}->{influence}.","."\"label\":"."\"NA\"".","."\"notice\":"."\"NA\""."},";
	
	$hash1{gene}=$hash1{gene}."{\"name\":"."\"$line[12]\"".","."\"chrom\":"."\"$line[5]\"".","."\"rs_pos\":"."\"$line[6]\"".","."\"gene_type\":"."\"".$genetype."\""."},";

}
close IN;

my $output=();
$hash3{category}="\"category\":[";
$hash3{health_index}=0;
for ( my $i=1;$i<=$category;$i++ ) {
	if (exists $hash2{$i}->{classification_id}) {
		$hash2{$i}->{disease}="\"disease\":[";
		for ( my $j=1;$j<= $disease;$j++ ) {
			if (exists $hash1{$i}{$j}->{id}) {
	#			print "$hash1{$i}{$j}->{id}\n";
				if (substr($hash1{$i}{$j}->{gene},-1,1) ne "[") {
					$hash1{$i}{$j}->{gene}=substr($hash1{$i}{$j}->{gene},0,length($hash1{$i}{$j}->{gene})-1);
				}
				$hash1{$i}{$j}->{gene}=$hash1{$i}{$j}->{gene}."]";
				$hash2{$i}->{disease}=$hash2{$i}->{disease}."{".$hash1{$i}{$j}->{id}.",".$hash1{$i}{$j}->{name}.",".$hash1{$i}{$j}->{or_value}.",".$hash1{$i}{$j}->{level}.",".$hash1{$i}{$j}->{probability}.",".$hash1{$i}{$j}->{gene}.",".$hash1{$i}{$j}->{advantage}."],".$hash1{$i}{$j}->{notice}.",".$hash1{$i}{$j}->{suggestion}."},";
				$hash3{health_index}=$hash3{health_index}+$hash1{$i}{$j}->{or};
				$advantage=substr($hash1{$i}{$j}->{advantage},13,length($hash1{$i}{$j}->{advantage}));
				$hash1{advantage}=$hash1{advantage}.$advantage.",";

			}
		}
		if (substr($hash2{$i}->{disease},-1,1) ne "[") {
			$hash2{$i}->{disease}=substr($hash2{$i}->{disease},0,length($hash2{$i}->{disease})-1);
		}
		$hash2{$i}->{disease}=$hash2{$i}->{disease}."]";
		$hash3{category}=$hash3{category}."{".$hash2{$i}->{classification_id}.",".$hash2{$i}->{classification_name}.",".$hash2{$i}->{disease}."},";
	}
}
if (substr($hash3{category},-1,1) ne "[") {
	$hash3{category}=substr($hash3{category},0,length($hash3{category})-1);
}
$hash3{category}=$hash3{category}."]";
if (substr($hash1{gene},-1,1) ne "[") {
	$hash1{gene}=substr($hash1{gene},0,length($hash1{gene})-1);
}
$hash1{gene}=$hash1{gene}."]";
if (substr($hash1{advantage},-1,1) ne "[") {
	$hash1{advantage}=substr($hash1{advantage},0,length($hash1{advantage})-1);
}
$hash1{advantage}=$hash1{advantage}."]";
#$output="{\"health_index\":"."\"$hash3{health_index}\"".","."\"detect_count\":"."\"$disease\"".",".$hash3{category}."}";
$output="{\"health_index\":"."\"$hash3{health_index}\"".","."\"detect_count\":"."\"$disease\"".",".$hash3{category}.",".$hash1{gene}.",".$hash1{advantage}.","."\"notice\":[]"."}";
print OUT "$output\n";



