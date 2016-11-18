#!/nfs2/pipe/Re/Software/miniconda/bin/perl -w
# @wxian2016Aug15

use strict;

die "Usage: $0 <min> <max> <interval> <out_dir>\n" unless (@ARGV == 4);

my $min=$ARGV[0];
my $max=$ARGV[1];
my $int=$ARGV[2];
my $out_dir=$ARGV[3];

# parameters
my $input="/lustre/project/og04/yukaicheng/test/PstI_MseI.fa";
my %hash=();
my $output=$out_dir."\/PstI_MseI.fa.stat";
my $output2=$out_dir."\/PstI_MseI.fa.result";
my $i=0;
my $l;
my $min_f=0;
my $max_f=0;
my $n=0;
my $in_b;

open (IN, '<', $input);
while (<IN>) {
	chomp;
	next if /^>/;
	my $line=$_;
	$i=$i+1;
	$l=length($line);
	if (not exists $hash{$l}) {
		$hash{$l}=1;
	} else {
		$hash{$l}=$hash{$l}+1;
	}
	if ($min_f eq 0) {
		$min_f=$l;
	}
	if ($l < $min_f) {
		$min_f=$l;
	}
	if ($l > $max_f) {
		$max_f=$l;
	}
}
close IN;

for (my $j=$min_f; $j<=$max_f; $j++) {
	if (exists $hash{$j}) {
		$n=$n+1;
		for (my $in=$min; $in<$max; $in=$in+$int) {
			if (not exists $hash{int}{$in}) {
				$hash{int}{$in}=0;
			}
			$in_b=$in+$int;
			if (($j>=$in) && ($j<$in_b)) {
				$hash{int}{$in}=$hash{int}{$in}+$hash{$j};
			}
		}
	}
}


open (OUT, '>>', $output);		
print OUT "Total_num_of_frags:$i\n";
print OUT "Total_type_of_frags:$n\n";
print OUT "The_shortest_frag:$min_f\n";
print OUT "The_longest_frag:$max_f\n";
print OUT "\n";
print OUT "Region\tFrags_num\n";

for (my $in=$min; $in<$max; $in=$in+$int) {
	$in_b=$in+$int;
	print OUT "region_[$in,$in_b):\t$hash{int}{$in}\n";
}
close OUT;

my $id;
my $ll;
my $ii_b;
my $out;
open (IN2, '<', $input);
while (<IN2>) {
	chomp;
	if (/^>/) {
		my $line=$_;
		$id=substr($line,1,length($line));
	} else {
		$ll=length($_);
		for (my $ii=$min; $ii<$max; $ii=$ii+$int ) {
			$ii_b=$ii+$int;
			if (not exists $hash{id}{$ii}) {
				$hash{id}{$ii}="|";
			}
			if (($ll >= $ii) && ($ll < $ii_b)) {
				$hash{id}{$ii}=$hash{id}{$ii}."|".$id;
			}
		}
	}
}
close IN2;

open (OUT2, '>', $output2);
for (my $ii=$min; $ii<$max; $ii=$ii+$int) {
	$ii_b=$ii+$int;
	print OUT2 "region_[$ii,$ii_b):\n";
	$out=substr($hash{id}{$ii},2,length($hash{id}{$ii}));
	print OUT2 "$out\n";
}
close OUT2;
				
