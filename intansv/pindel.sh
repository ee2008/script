#!/bin/bash

# change the output position 
# @wxian2016Apr07

PINDEL="$(dirname $0)/pindel.prepare.sh"

# ===argv
[[ $# -lt 2 ]] && echo "usage: sh $0 <bam> <fasta> [-chr <chromosome>] [-outpre <output_prefix> | output] [out_dir|bam_dir]" && exit

BAM="$1"
PARA="$1 $2"

OUT=$(dirname $BAM)

while [[ $# -gt 2 ]]; do
	key="$3"
	case $key in 
		-chr) PARA="$PARA $3 $4" 
			  shift; 
			  ;;
		-outpre) PARA="$PARA $3 $4" 
				 shift; 
				 ;;
		*) OUT="$3"
		   ;;
	esac
	shift
done

[[ ! -d $OUT ]] && mkdir $OUT
echo ">> out file: $OUT"

cd $OUT
ln -s $PINDEL ./temp.pindel.sh
sh ./temp.pindel.sh $PARA
rm ./temp.pindel.sh
cd -
