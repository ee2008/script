#!/usr/bin/perl

# add the length of sv to DELLY output 
# @wxian2016Mar10

die "Usage: perl $0 [delly_in_dir] [delly_out_dir]\n" unless (@ARGV == 2);

use strict;
my $dir = $ARGV[0];
my $out = $ARGV[1];
my $file;
my @dir;
opendir(DIR,$dir) or die "can't open the directory!";
@dir=readdir DIR;
foreach $file (@dir) {
	if ($file=~/^\./) {
		next;
	}
	
	my $input = $dir."/".$file;
	my $output = $out."/".$file;
	open (IN,'<',$input);
	open (OUT,'>', $output);
	while (<IN>) {
		chomp;
		my $line=$_;
		if (/#/) {
			print OUT "$line\n";
			next;
		}
		my @line = split(/\t/,$line);
		my $start = @line[1];
		my $info = @line[7];
		my @info = split(/;/,$info);
		my $end = substr(@info[6],4);
		my $svlen = $end-$start;
		@info[6] = @info[6].";SVLEN=".$svlen;
		@line[7] = join(";",@info);
		my $out = join("\t",@line);
		print OUT "$out\n";
	}
	close IN;
}




