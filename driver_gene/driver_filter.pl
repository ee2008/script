#!/usr/bin/perl -w
# @wxian2017Feb13


use strict;

die "perl $0 <sample.var.annovar.hg19_multianno.txt> <out_dir>\n" unless (@ARGV > 0);


my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START $mon $day $ht $year\n";


my $annovar=$ARGV[0];
my $out_dir=$ARGV[1];
if (!-e $out_dir) {
	mkdir $out_dir;
}
my @path=split (/\//,$annovar);
my $sample=(split /\./, $path[@path-1])[0];


my $driver_gene="/lustre/project/og04/wangxian/pipeline_script/driver_gene/driver_gene.txt";
my $out_tem=$out_dir."/".$sample.".simply.annovar.txt";
my $output=$out_dir."/".$sample.".var.driver_gene.txt";



`/nfs2/pipe/Re/Software/bin/csvcut -t -c Gene.knownGene,Chr,Start,Ref,Alt,ExonicFunc.knownGene,AAChange.knownGene $annovar | /nfs2/pipe/Re/Software/bin/csvformat -T > $out_tem`;

my %hash=();
open (DRIVER, '<', $driver_gene);
my $head;
while (<DRIVER>) {
	chomp;
	my $line=$_;
	my @line=split (/\t/,$line);
	if (/^#/) {
		$head=join("\t",@line[1..@line-1]);
		next;
	}
	$hash{$line[0]}=join("\t",@line[1..@line-1]);
}
close DRIVER;

open (IN, '<', $out_tem);
open (OUT, '>', $output);
while (<IN>) {
	chomp;
	my $line=$_;
	if (/^Gene.knownGene/){
		print OUT "#Gene\tChr\tPos\tRef\tAlt\tExonicFunc\tAAChange\t$head\n";
		next;
	}
	my @line=split (/\t/,$line);
	if (exists $hash{$line[0]}) {
		print OUT "$line\t$hash{$line[0]}\n";
	}
}
close IN;
close OUT;

`rm $out_tem`;



($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> DONE $mon $day $ht $year\n";



















