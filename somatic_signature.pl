#!/usr/bin/perl -w

# merge all maf file
# @wxian20160825

die "Usage: perl $0 <cancer_type:somatic.oncotator.maf> <cancer_name:somatic.oncotator.maf> ...[-o <out_dir> | ./] [-s <n_sign> | 5]

note: must input more than one cancer_type

cancer_type:
	gbm: Glioblastoma multiforme
	hnsc: Head and Neck squamous cell carcinoma
	kirc: Kidney Chromophobe
	luad: Lung adenocarcinoma
	lusc: Lung squamous cell carcinoma
	ov: Ovarian serous cystadenocarcinoma
	skcm: Skin Cutaneous Melanoma
	thca: Thyroid carcinoma
	
output including:
	mutation_signature.maf
	fitted_spectrum.png
	mutation_spectrum.png
	number_signatures.png
	sample_map.png
	samples.png
	signatures.png
	somatic_signatures_barchart_NMF.png
	somatic_signatures_heatmap_NMF.png\n\n" unless (@ARGV >0);

use FindBin qw($Bin);


my $somatic_signature_R = $Bin."/somatic_signature_plot.R";
my $out=".";
my $s;
my $i;
my $s_name;
my @s_name;
my $Verification_Status="NA";
my $Validation_Status="Untested";
my $Mutation_Status="Somatic";
my $n_sign=5;

if (($ARGV[@ARGV-4] eq "-o") || ($ARGV[@ARGV-4] eq "-s")) {
	$s=@ARGV-5;
	if ($ARGV[@ARGV-4] eq "-o") {
		$out=$ARGV[@ARGV-3];
		$n_sign=$ARGV[@ARGV-1];
	} else {
		$out=$ARGV[@ARGV-1];
		$n_sign=$ARGV[@ARGV-3];
	}
} elsif (($ARGV[@ARGV-2] eq "-o") || ($ARGV[@ARGV-2] eq "-s")) {
	$s=@ARGV-3;
	if ($ARGV[@ARGV-2] eq "-o") {
		$out=$ARGV[@ARGV-1];
	} else {
		$n_sign=$ARGV[@ARGV-1];
	}
} else {
	$s=@ARGV-1;
}


my $out_file=$out."/mutation_signature.maf";
my @sample=@ARGV[0..$s];
my $n = 0;
open (OUT, '>', $out_file);
print OUT "disease\tseqnames\tstart\tend\tHugo_Symbol\tEntrez_Gene_Id\tVariant_Classification\tVariant_Type\tReference_Allele\tTumor_Seq_Allele1\tTumor_Seq_Allele2\tVerification_Status\tValidation_Status\tMutation_Status\tPatient_ID\tSample_ID\tindex\n";
for my $sample0(@sample) {
	my $disease = (split /:/, $sample0)[0];
	my $sample = (split /:/, $sample0)[1];
	open (IN, '<', $sample);
	my @s_name = (split/\//,$sample);
	my $s_name = $s_name[@s_name-1];
	my $patient_id = (split /\./, $s_name)[0];
	while (<IN>) {
		chomp;
		my $line = $_;
		next if (/^#/);
		if (/^Hugo_Symbol/) {
			my @index = split(/\t/,$line);
			my @chr = grep {$index[$_] =~ m/Chromosome/} 0..$#index;
			our $chr = $chr[0];
			my @start = grep {$index[$_] =~ m/Start_position/} 0..$#index;
			our $start = $start[0];
			my @end = grep {$index[$_] =~ m/End_position/} 0..$#index;
			our $end = $end[0];
			my @hugo = grep {$index[$_] =~ m/Hugo_Symbol/} 0..$#index;
			our $hugo = $hugo[0];
			my @entrez = grep {$index[$_] =~ m/Entrez_Gene_Id/} 0..$#index;
			our $entrez = $entrez[0];
			my @Variant_Classification = grep {$index[$_] =~ m/Variant_Classification/} 0..$#index;
			our $Variant_Classification = $Variant_Classification[0];
			my @Variant_Type = grep {$index[$_] =~ m/Variant_Type/} 0..$#index;
			our $Variant_Type = $Variant_Type[0];
			my @Reference_Allele = grep {$index[$_] =~ m/Reference_Allele/} 0..$#index;
			our $Reference_Allele = $Reference_Allele[0];
			my @Tumor_Seq_Allele1 = grep {$index[$_] =~ m/Tumor_Seq_Allele1/} 0..$#index;
			our $Tumor_Seq_Allele1 = $Tumor_Seq_Allele1[0];
			my @Tumor_Seq_Allele2 = grep {$index[$_] =~ m/Tumor_Seq_Allele2/} 0..$#index;
			our $Tumor_Seq_Allele2 = $Tumor_Seq_Allele2[0];
			$i=0;
			next;
		}
		$i=$i+1;
		if (($i%2 ne 0)) {
			$n = $n + 1;
			my @line = split(/\t/,$line);
			my $output=join("\t",$disease,$line[$chr],$line[$start],$line[$end],$line[$hugo],$line[$entrez],$line[$Variant_Classification],$line[$Variant_Type],$line[$Reference_Allele],$line[$Tumor_Seq_Allele1],$line[$Tumor_Seq_Allele2],$Verification_Status,$Validation_Status,$Mutation_Status,$patient_id,$s_name,$n);
			print OUT "$output\n";
		}
	}
	close IN;
}
close OUT;

# plot somatic_signature
system("/nfs2/pipe/Re/Software/miniconda/bin/Rscript $somatic_signature_R $out_file $out $n_sign");


