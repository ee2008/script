#!/nfs2/pipe/Re/Software/miniconda/bin/perl -w
# @wxian2016Agu15

use strict;

die "Usage: perl $0 <fa> <gff> <out_file>\n" unless (@ARGV == 3);

my $fa=$ARGV[0];
my $gff=$ARGV[1];
my $out=$ARGV[2];

# parameter
my %hash=();
my $key;
my $id;
my @id;
my @id_no;
my $ID;
my $output;
my $start;
my $end;

open (FA, '<', $fa);
while (<FA>) {
	chomp;
	if (/^>/) {
		$key=substr($_,1,length($_));
	} else {
		$hash{$key}=$_;
	}
}
close FA;

open (GFF, '<', $gff);
open (OUT, '>', $out);
while (<GFF>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if ($line[2] ne "CDS") {
		@id=split(/;/,$line[8]);
		@id_no=split(/=/,$id[0]);
		$ID=$id_no[1];
		$start=$line[3];
		$end=$line[4];
		$output=substr($hash{$line[0]},$start-1,$end-$start+1);
		if ($line[2] =~ /^UTR/) {
			$output=lc($output);
		}
		print OUT "$line[0]:$ID\n";
		print OUT "$output\n";
	}
}







