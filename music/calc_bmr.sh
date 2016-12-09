#!/bin/bash

# Calculates mutation rates given per-gene coverage (from "music bmr calc-covg"), and a mutation list
# @wxian2016Apr13

export PATH="/lustre/project/og04/pub/biosoft/bin:"$PATH
if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 <music_dir>
Warning: this script must be ran in test node(Connected to the Internet) 

there will be 2 output files:
	gene_mrs
	overall_bmrs

EOF
exit 0
fi

IN="$1"
GENOME="/nfs2/pipe/Re/Software/miniconda/bin/genome"
BAM=$IN/bam_list
MAF=$IN/all_patients.maf
MR=$IN/gene_mr
BMR=$IN/bmr
ROI="/lustre/project/og04/pub/biosoft/MuSiC/testdata/roi_testdata_ensembl_67_cds_ncrna_and_splice_sites_hg19"
FA="/lustre/project/og04/pub/database/human_genome_hg19/reference/human_g1k_v37.fasta"


$GENOME music bmr calc-bmr --bmr-output=$BMR --roi-file=$ROI --gene-mr-file=$MR --reference-sequence=$FA --bam-list=$BAM --output-dir=$IN --maf-file=$MAF
