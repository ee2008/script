#!/bin/bash

# Identify significantly mutated genes
# @wxian2016Apr14

export PATH="/lustre/project/og04/pub/biosoft/bin:/nfs2/pipe/Re/Software/miniconda/bin:"$PATH

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 <music_dir>

warning: before using the script, you should run ./calc_bmr.sh at test node 

there will be 2 output files:
	smg
	smg_detailed

EOF
exit 0
fi

IN="$1"
GENOME="/nfs2/pipe/Re/Software/miniconda/bin/genome"
MR=$IN/gene_mrs
SMG=$IN/smg

echo ">> Identify significantly mutated genes @$(date)"
echo ">> the output dir: $IN"

$GENOME music smg --gene-mr-file=$MR --output-file=$SMG

echo ">> finished: smg @$(date)"
