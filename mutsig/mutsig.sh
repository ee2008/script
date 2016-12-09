#!/bin/bash
# @wxian2016Mar25
# MutSig analyzes lists of mutations discovered in DNA sequencing, to identify genes that were mutated more often than expected by chance given background mutation processes.

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: $0 <in.maf_dir or all_patients.maf> [out_dir/prefix|in_dir/in_prefix]

This script will call MutSig to calc sig gene
from MAF input to 6 or 5 output files:
.all_patients.maf(ignore it if input a maf file)
.categs.txt
.coverage.txt
.mutations.txt
.mutcateg_discovery.txt
.sig_genes.txt
EOF
exit 0
fi


MAF="$(dirname $0)/merge_maf.pl"
WD="/lustre/project/og04/pub/biosoft/MutSig"
MTR="/lustre/project/og04/pub/biosoft/MATLAB_Runtime/v81"


IN="$1"
IN=$(readlink -e $1)
postfix=${IN:0-4:4}
if [[ $postfix == ".maf" ]]; then
	INPUT=$IN
	if [[ $# -gt 1 ]]; then
		OUT="$2"
		[[ ! -d $(dirname $OUT) ]] && mkdir -pv $(dirname $OUT)
	else
		OUT=$(dirname $INPUT)/$(basename $INPUT .maf)
	fi
else
	if [[ $# -gt 1 ]]; then
		OUT="$2"
		[[ ! -d $(dirname $OUT) ]] && mkdir -pv $(dirname $OUT)
		OUT_dir=${OUT%/*}
	else
		OUT_prefix=$(basename $IN)
		OUT=$IN/$OUT_prefix
		OUT_dir=$IN
	fi
	INPUT=$OUT.all_patients.maf
	indir=$(ls  $IN | awk '/.VS./ && /.maf$/ {print $NF}')
	n=0
	for i in $indir
	do
		n=$[$n+1]
		prefix=$(basename $i .var.oncotator.maf)
		tumor=${prefix##*-}
		normal=${prefix%%-*}
		IN_file=${IN}/${i}
		OUT_file=${OUT_dir}/${i}.new
		perl $MAF $IN_file $OUT_file $tumor $normal
		if [[ $n == 1 ]]; then
			sed -n '1,$p' $OUT_file >> $INPUT
		else
			sed -n '10,$p' $OUT_file >> $INPUT
		fi
		rm $OUT_file
	done
	[[ $n == 1 ]] && echo "ERROR: mutsig can not analysis single patient" && exit 
fi
echo "> START $0 @$(date)"
echo ">> IN: $INPUT"
echo ">> OUT prefix: $OUT"

$WD/install/MutSigCV_1.4/run_MutSigCV.sh $MTR $INPUT $WD/install/exome_full192.coverage.txt $WD/install/gene.covariates.txt $OUT $WD/install/mutation_type_dictionary_file.txt $WD/install/chr_files_hg19

echo "> DONE $0 @$(date)"
exit 0
