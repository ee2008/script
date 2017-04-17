#!/usr/bin/perl -w

# @wxian2016Nov23

use FindBin qw($Bin);
use Getopt::Long;
use strict;
#use Env;

$ENV{'LD_LIBRARY_PATH'} = "/nfs2/pipe/Re/Software/miniconda/lib:".$ENV{'LD_LIBRARY_PATH'};
my $plot_base_distribution=$Bin."/plot_depth_distribution.R";

#print $ENV{'LD_LIBRARY_PATH'};
#my $dir="/nfs2/pipe/Re/Software/miniconda/lib:";
#my @LD_LIBRARY_PATH;
#push @LD_LIBRARY_PATH, $dir;
#`echo $LD_LIBRARY_PATH`;

die "Usage: perl $0 
	-p <project_dir> 
	-s <sample> 
	-o <out_dir> 
	[-output <output_name|sample_depth_distribution >]
	[-t <picture_format>|png]
	[-tool <bedtools/samtools>|bedtools]
	[-d <depth>|100] 
	[-c <1,2..X,Y>|all] 
	[-min <min>|0] 
	[-max <max>|all]
	[-po <0/1>|0(not activated)]
	[-v_min <v_min>]: can only use when using -po or -c with one chromosome 
	[-v_max <v_max>]: can only use when using -po or -c with one chromosome 
	\n" unless (@ARGV > 0);

my ($project,$sample,$name,$type,$tools,$out_dir,$depth,$chr,@chr,$min,$max,$v_min,$v_max,$po);
GetOptions(
	'p=s' =>\$project,
	's=s' =>\$sample,
	'o=s' =>\$out_dir,
	'output=s' =>\$name,
	't=s' =>\$type,
	'tool=s' =>\$tools,
	'd=i' =>\$depth,
	'c=s' =>\$chr,
	'min=i' =>\$min,
	'max=i' =>\$max,
	'v_min=i' =>\$v_min,
	'v_max=i' =>\$v_max,
	'po=i' =>\$po,
#	'l=i' =>\$lpanel,
);


if (!-e $out_dir) {
	mkdir $out_dir;
}

if (!$tools) {
	$tools="bedtools"
}

if (!$name) {
	$name=$sample.".".$tools."_depth_distribution";
}

if (!$type) {
	$type="png";
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

my ($panel_po,$chr_po);
if ($tools eq "bedtools") {
	$panel_po=$project."/qc/panel/".$sample.".bedtools_intersect.txt";
	$chr_po=$project."/qc/align/".$sample.".itools_depth.gz";
} elsif ($tools eq "samtools") {
	$panel_po=$project."/qc/panel/".$sample.".samtools_depth_bed.txt";
	$chr_po=$project."/qc/align/".$sample.".samtools_depth.txt.gz";
} else {
	die "ERROR INPUT!\n";
}

my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START $mon $day $ht $year\n";
print ">  INPUT: $panel_po\n";

my %hash;
my $po_d;
open (PANEL, '<', $panel_po);
if ($tools eq "bedtools") {
	while (<PANEL>) {
		chomp;
		my $line=$_;
		my @line=split(/\t/,$line);
		my $d=$line[@line-1];
		next if ($line[@line-2] == 0);
		while ($d >= 1) {
			if ($line[@line-4] < $line[1]) {
				$po_d=$line[1]+$d;
			} elsif ($line[@line-3] > $line[2]) {
				$po_d=$line[2]-$d+1;
			} else {
				$po_d=$line[@line-4]+$d;
			}
			my $key=join("\t",$line[@line-5],$po_d);
			$hash{$key}=$line[@line-2];
			$d=$d-1;
		}
	}
} else {
	while (<PANEL>) {
		chomp;
		my $line=$_;
		my @line=split(/\t/,$line);
		my $key=join("\t",@line[0..1]);
		$hash{$key}=$line[2];
	}
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
my $out=$out_dir."/".$sample.".".$tools."_depth".$depth."_depth.txt";
open (OUT, '>', $out);
print OUT "NO\tCHR\tPO\tDEPTH\tPANEL\n";

my $itools_chr;
if ($tools eq "bedtools") {
	while (<CHR>) {
		chomp;
		my $line=$_;
		if ($line=~/^>(\w+)\s\s\s#/) {
			$itools_chr=$1;
			next;
		}
		next if /^>\*\s\s\s/;
		my @line=split(/\t/, $line);
		my $itools_po=$line[0];
		my $itools_depth=$line[1]+$line[2]+$line[3]+$line[4];
		next if (($itools_depth < $depth) || (not exists $hash_chr{$itools_chr}));
		next if ((($min) && ($itools_po < $min)) || (($max) && ($itools_po > $max)));
		my $index=join("\t",$itools_chr,$itools_po);
		$hash_chr{$itools_chr}=$hash_chr{$itools_chr}+1;
	#	my $out_name="TMP".$itools_chr;
		if (($po) && ($po == 1)) {
			if (exists $hash{$index}) {
				print OUT "$itools_po\t$itools_chr\t$itools_po\t$itools_depth\tred\n";
			} else {
				print OUT "$itools_po\t$itools_po\t$itools_chr\t$itools_po\t$itools_depth\tblue\n";
			}
		} else {
			if ($itools_po == $v_min) {
				$v_line1=$hash_chr{$itools_chr};
			}
			if ($itools_po == $v_max) {
				$v_line2=$hash_chr{$itools_chr};
			} 
			if (exists $hash{$index}) {
				print OUT "$hash_chr{$itools_chr}\t$itools_chr\t$itools_po\t$itools_depth\tred\n";
			} else {
				print OUT "$hash_chr{$itools_chr}\t$itools_chr\t$itools_po\t$itools_depth\tblue\n";
			}
		}	
	}
} else {	
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
print ">> PLOTTING $mon $day $ht $year\n";
print ">  OUTPUT: $out_dir/$name.$type\n";

#print "$plot_base_distribution $out $out_dir $name $type $depth $v_line1 $v_line2";
system("$plot_base_distribution $out $out_dir $name $type $depth $v_line1 $v_line2"); 

#unlink $out;

($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> DONE $mon $day $ht $year\n";


