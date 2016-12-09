#!/bin/bash

# find pathway via genome MuSiC pathscan
# @wxian2016Apr07


export PATH="/lustre/project/og04/pub/biosoft/bin:/nfs2/pipe/Re/Software/miniconda/bin:"$PATH

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 <bam_dir> <maf_dir> [-p] [-o <out_dir>|maf_dir] [-s <normal_sample_prefix_1-VS-tumor_sample_prefix_1,normal_sample_prefix_2-VS-tumor_sample_prefix_2,...>]

Options:
	-p plot
	-o out_dir, default: maf_dir
	-s sample_name_prefix,for example: TC01B-VS-TC01T,TC02B-VS-TC02T

the output including:
	file:bam_list
	file: all_patients.maf
	dir: gene_covgs
	dir: roi_covgs
	file: total_covgs
	file: Pathway
	file: Pathway_detailed
[-p] file: matrix
	 file: mutation
	 pdf: plot.pdf

EOF
exit 0
fi

# == env
FA="/lustre/project/og04/pub/database/human_genome_hg19/reference/human_g1k_v37.fasta"
ROI="/lustre/project/og04/pub/biosoft/MuSiC/testdata/roi_testdata_ensembl_67_cds_ncrna_and_splice_sites_hg19"
KEGG="/lustre/project/og04/pub/biosoft/MuSiC/testdata/inputs/kegg_db_120910"
MAF_pl="$(dirname $0)/merge_maf.pl"
GENOME="/nfs2/pipe/Re/Software/miniconda/bin/genome"
p=0
s=0

echo "> START $0 @$(date)"

BAM_DIR=$(readlink -e $1)
MAF_DIR=$(readlink -e $2)
OUT=$MAF_DIR

while [[ $# -gt 2 ]]; do
	key="$3"
	case $key in
		-p) p=1
			;;
		-o) OUT="$4"
			[[ ! -d $OUT ]] && mkdir -pv $OUT
			shift; ;;
		-s) s=1
			BAM_prefix="$4"
			shift; ;;
	esac
	shift
done

echo ">> output dir: $OUT"

# == generate bam_list file
echo ">> generate bam_list file @$(date)"
BAM=$OUT/bam_list
if [[ $s == 1 ]]; then
	BAM_prefix=${BAM_prefix}.bam
	bamdir=${BAM_prefix//-VS-/.bam" "}
	bamdir=${bamdir//,/.bam" "}
else
	cd $BAM_DIR
	bamdir=$(ls *.bam | grep -v splitters | grep -v discordants)
	cd -
fi
n=0
for i in $bamdir
do
	n=$[$n+1]
	if [[ $n == 1 ]]; then
		P1=${BAM_DIR}/${i}
	fi
	prefix_bam=${i%.*}
	if [[ $n == 2 ]]; then
		P2=${BAM_DIR}/${i}
		echo -e "$prefix_bam\t$P1\t$P2" >> $BAM
		n=0
	fi
done
echo ">> finished: bam_list file @$(date)"


# == generate all_patients.maf file
echo ">> generate all_patients.maf file @$(date)"
MAF=$OUT/all_patients.maf
if [[ $s == 1 ]]; then
	mafdir=${BAM_prefix}.var.oncotator.maf
	mafdir=${mafdir//,/.var.oncotator.maf" "}
else
	mafdir=$(ls $MAF_DIR | awk '/.VS./ && /.maf$/ {print $NF}')
fi
m=0
for j in $mafdir
do
	m=$[$m+1]
	prefix=$(basename $j .var.oncotator.maf)
	tumor=${prefix##*-}
	normal=${prefix%%-*}
	IN_file=${MAF_DIR}/${j}
	OUT_file=${OUT}/${j}.new
	perl $MAF_pl $IN_file $OUT_file $tumor $normal
	if [[ $m == 1 ]]; then
		sed -n '1,$p' $OUT_file >> $MAF
	else
		sed -n '10,$p' $OUT_file >> $MAF
	fi
	rm $OUT_file
done
echo ">> finished: all_patients.maf file @$(date)"

# == generate gene-covg  
echo ">> generate gene-covg @$(date)"
TOTAL_COVGS=$OUT/total_covgs
GENE_COVGS=$OUT/gene_covgs
ROI_GOVGS=$OUT/roi_covgs
mkdir -pv $GENE_COVGS
mkdir -pv $ROI_GOVGS
# = split bam_list 
split_gene_covgs(){
	BAM_n="$1"
	TMP_dir=${OUT}/tpm_${BAM_n}
	mkdir -pv $TMP_dir
	BAM_LIST=$TMP_dir/bamlist
	sed -n ${BAM_n}p $BAM > $BAM_LIST
	$GENOME music bmr calc-covg --gene-covg-dir=$TMP_dir --roi-file=$ROI --reference-sequence=$FA --bam-list=$BAM_LIST --output-dir=$TMP_dir
}
n_bam=$(wc -l $BAM | awk '{print $1}')
for ((i=1; i<=$n_bam; i++))
do
	split_gene_covgs $i&
done
wait
# = merge the total_covgs
for ((i=1; i<=$n_bam; i++))
do
	TMP_dir=${OUT}/tpm_${i}
	mv ${TMP_dir}/gene_covgs/* $GENE_COVGS
	mv ${TMP_dir}/roi_covgs/* $ROI_GOVGS
	if [[ $i == 1 ]]; then
		sed -n '1,2p' $TMP_dir/total_covgs >> $TOTAL_COVGS
	else
		sed -n '2p' $TMP_dir/total_covgs >> $TOTAL_COVGS
	fi
	rm -r $TMP_dir
done

echo ">> finished: gene-covg @$(date)"

# == call MuSiC path-scan 
echo ">> call MuSiC to get pathway@$(date)"
$GENOME music path-scan --gene-covg-dir=$GENE_COVGS --bam-list=$BAM --pathway-file=$KEGG --maf-file=$MAF --output-file=$OUT/Pathway
echo ">> finished: pathway @$(date)"

# == Generate relevant plots and visualizations for MuSiC
if [[ $p == 1 ]]; then
	echo ">> Generate relevant plots and visualizations @$(date)"
	MATRIX=$OUT/matrix
	MUTATION=$OUT/mutation
	PDF=$OUT/plot.pdf
	$GENOME music mutation-relation --bam-list=$BAM --maf-file=$MAF --output-file=$MUTATION --mutation-matrix-file=$MATRIX
	$GENOME music plot mutation-relation --input-matrix=$MATRIX --output-pdf=$PDF
	echo ">> finished: plot @$(date)"
fi

echo ">> DONE $0 @$(date)"
