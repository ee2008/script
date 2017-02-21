#!/usr/bin/perl -w

my %hash=();
open (IN, '<', "./SMG127_2.txt");
open (IN2, '<', "./driver_gene.txt");
while 	(<IN>) {
	chomp;
	my $line=$_;
	next if /^Gene/;
	my @line=split(/\t/,$line);
	if (exists $hash{$line[0]}) {
		$hash{$line[0]}=$hash{$line[0]}.",".$line[1];
	} else {
		$hash{$line[0]}=$line[1];
	}
}
close IN;


open (OUT, '>', "./driver_gene_new.txt");
while (<IN2>) {
	chomp;
	my $line=$_;
	my @line=split(/\t/,$line);
	if (/^#Gene/) {
		my $head=join("\t",@line[0,1,3..(@line-1)]);
		print OUT "$head\n";
		next;
	}
	if (exists $hash{$line[0]}) {
		my @cancer=split(/,/,$hash{$line[0]});
		my %count;
		my @cancer_uniq=grep { ++$count{ $_ } < 2; } @cancer;
		$line[7]=join(",",@cancer_uniq[0..(@cancer_uniq-1)]);
	}
	my $output=join("\t",@line[0,1,3..(@line-1)]);
	print OUT "$output\n";
}
close IN2;
close OUT;
	







