#!/usr/bin/perl -w

my $in=$ARGV[0];
my $out=$ARGV[1];

open (IN, '<', $in);
open (OUT,'>', $out);
print OUT "##fileformat=VCFv4.1\n";
while (<IN>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (/^Chrom/) {
		my $OUTPUT=join("\t",@line[2..18]);
		print OUT "#$line[0]\t$line[1]\tID\t$OUTPUT\n";
	#	print OUT "#$line\n";
		next;
	}
	my $alt=$line[18];
	#if (!$alt) {
	#	my $OUTPUT=join("\t",@line[2..17]);
	#	print OUT "$line[0]\t$line[1]\t.\t$OUTPUT\t.\n";
	#} else {
	#	my $OUTPUT=join("\t",@line[2..18]);
	#	print OUT "$line[0]\t$line[1]\t.\t$OUTPUT\n";
	#}
	if ($alt) {
		my $type=$line[3];
		@line[3]=$line[18];
		@line[18]=$type;
	 	my $OUTPUT=join("\t",@line[2..18]);
		print OUT "$line[0]\t$line[1]\t.\t$OUTPUT\n";
	}
}
close IN;
close OUT;






