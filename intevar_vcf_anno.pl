#!/nfs2/pipe/Re/Software/miniconda/bin/perl -w

# @wxian2017Feb06
# adjust format of vcf from var_intevar for anno

# judgement standard of type:
## ref=alt=1 >> snp
## 1=ref<alt >> ins
## ref>alt=1 >> del
## others    >> delins


use strict;
use Tie::File;

die "Usage: perl $0 <fa> <intevar_vcf> <out_file>\n" unless (@ARGV>0);

my $fa=$ARGV[0];
my $in_vcf=$ARGV[1];
my $out_vcf=$ARGV[2];

tie my @array,'Tie::File', $in_vcf or die "$!";
die "Error: $in_vcf is empty! \n" unless (@array);

my($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> START $mon $day $ht $year\n";
print "> input: $in_vcf\n";
print "> output: $out_vcf\n";


my $output;
my ($DP,$AF);
open (IN, '<', $in_vcf);
open (OUT,'>', $out_vcf);
while (<IN>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (/^##/) {
		print OUT "$line\n";
		next;
	}
	if (/^#CHROM/) {
		print OUT "##reference=$fa\n";
		print OUT "$line\n";
		next;
	}
	#my $dp=(split /\,/, $line[7])[2];
	#my $DP=(split /\=/,$dp)[1];
	if ($line[7] =~ /dp=(\d+);/) {
		$DP=$1;
	}
	if ($line[7] =~ /vf=(\d+.*),/) {
		$AF=$1;
	}
	if((length($line[3]) == 1) && (length($line[3]) == length($line[4]))) {
		$output=join("\t",@line[0..6],"AF=$AF;DP=$DP;TYPE=snp");
		print OUT "$output\n";
	} elsif ((length($line[3]) <  length($line[4])) && (length($line[3]) ==1 )) {
		if (substr($line[4],0,1) eq $line[3]) {
			$output=join("\t",@line[0..6],"AF=$AF;DP=$DP;TYPE=ins");
			print OUT "$output\n";
		} else {
			$output=join("\t",@line[0..6],"AF=$AF;DP=$DP;TYPE=delins");
			print OUT "$output\n";
			print "!warning: $line\n";
		}
	} elsif ((length($line[3]) >  length($line[4])) && (length($line[4]) ==1 )) {
		if (substr($line[3],0,1) eq $line[4]) {
			$output=join("\t",@line[0..6],"AF=$AF;DP=$DP;TYPE=del");
			print OUT "$output\n";
		} else {
			$output=join("\t",@line[0..6],"AF=$AF;DP=$DP;TYPE=delins");
			print OUT "$output\n";
			print "!warning: $line\n";
		}
	} else {
		$output=join("\t",@line[0..6],"AF=$AF;DP=$DP;TYPE=delins");
		print OUT "$output\n";
	}
}
close IN;
close OUT;


($week,$mon,$day,$ht,$year)=split(" ",localtime(time()));
print ">> DONE $mon $day $ht $year\n";



