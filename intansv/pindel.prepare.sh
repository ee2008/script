#!/bin/bash
# call D(deletion) SI(short insertion) INV(inversion) TD(tandem duplication) LI(large insersion) BP(unassigned breakpoints) from bam via pindel
# @wxian^16Feb12

# === env

PINDEL="/lustre/project/og04/pub/biosoft/pindel/pindel"
PERL="/nfs2/pipe/Cancer/Software/BreakDancer/perl/perl-5.12.5/perl"
SAMTOOLS="/nfs2/pipe/Re/Software/miniconda/bin/samtools"


# ===argv
[[ $# -lt 2 ]] && echo "usage: sh $0 <bam> <fasta> [-chr <chromosome>] [-outpre <output_prefix> | output]" && exit 

BAM="$1"
FASTA="$2"

# == BAM
[[ ! -f $BAM ]] && echo "! no such bam: $BAM" && exit 1
prefix=$(basename $BAM .bam)
IN_DIR=$(dirname $BAM)

# == check bam index
BAI="$BAM.bai"
if [[ ! -f $BAI ]]; then 
	echo "!! no bam index, will generate now"
	$SAMTOOLS index $BAM
fi

# == FASTA
[[ ! -f $FASTA ]] && echo "! no such fasta: $FASTA" && exit 1

# == check fasta index
FAI="$FASTA.fai"
if [[ ! -f $FAI ]]; then
        echo "!! no fasta index, will generate now"
        $SAMTOOLS faidx $FASTA
fi

# == CHROMOSOME and OUT-PREFIX and OUT_DIR
CHR=0
OUT_PREFIX="output"
OUT_DIR=$(dirname $0)
while [[ $# -gt 2 ]]; do
	key="$3"
	case $key in
		-chr) CHR="$4"
			  echo "! specific on chr: $CHR"
			  shift; ;;
		-outpre) OUT_PREFIX="$4"
				 echo "! specific on out_prefix: $OUT_PREFIX"
				 shift; ;;
	esac
	shift
done
if [[ $CHR -eq 0 ]]; then
	echo ">> for all chr"
	CHR_PRA="-c ALL"
else
	CHR_PRA="-c $CHR"
fi

# get configuration text file
CONFIG=$(dirname $0)/config.txt
echo "$BAM 250 $prefix" > $CONFIG


echo "> START $0 "`date`
echo ">> bam: $BAM"
echo ">> fasta: $FASTA"
echo ">> out_prefix: $OUT_PREFIX"
echo ">> out_dir: $(dirname $0)"
echo ">> chr: $CHR"

# == PINDEL
echo ">start Pindel"`date`
echo "$PINDEL -f $FASTA -i $CONFIG $CHR_PRA -o $OUT_PREFIX"
$PINDEL -f $FASTA -i $CONFIG $CHR_PRA -o $OUT_PREFIX 

echo "> DONE $0"`date`
