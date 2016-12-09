#!/bin/bash
# call SV(DEL/DUP/INV/TRA/INS) from bam via delly
# @wxian^16Feb03

# === env

DELLY="/nfs2/pipe/Re/Software/miniconda/bin/delly"
SAMTOOLS="/nfs2/pipe/Re/Software/miniconda/bin/samtools"

# === argv
[[ $# -lt 2 ]] && echo "usage: sh $0 <bam> <fasta> [out_dir|bam_dir] [-type <DEL DUP INV TRA INS>]" && exit

# == BAM
BAM="$1"
[[ ! -f $BAM ]] && echo "! no such bam: $BAM" && exit 1
prefix=$(basename $BAM .bam)

# == check bam index
BAI="$BAM.bai"
if [[ ! -f $BAI ]]; then
        echo "!! no bam index, will generate now"
        $SAMTOOLS index $BAM
fi

# == FASTA
FASTA="$2"
[[ ! -f $FASTA ]] && echo "! no such fasta: $FASTA" && exit 1

# == output_dir
OUT_DIR=$(dirname $BAM)

echo "> START $0 "`date`

# == SV type
TYPE="DEL"
if [[ $# -gt 2 ]]; then
	if [[ "$3" != '-type' ]]; then
		OUT_DIR="$3"
		last_char=${OUT_DIR:0-1:1}
			if [[ $last_char == '/' ]]; then
				num_out_dir=$[${#OUT_DIR}-1]
				OUT_DIR=${OUT_DIR:0:$num_out_dir}
			fi
		shift
	fi
	if [[ $# -gt 2 ]] && [[ "$3" == '-type' ]]; then
		if [[ -z "$4" ]]; then
			echo "no specific type after -type" && exit 1
		else
			TYPE="$4"
			OUT=${OUT_DIR}/${prefix}.${TYPE}.vcf
			echo ">> discover $TYPE type SV" 
			$DELLY -t $TYPE -o $OUT -g $FASTA $BAM
			shift
		fi
		if [[ -n "$4" ]]; then
			TYPE="$4"
                	OUT=${OUT_DIR}/${prefix}.${TYPE}.vcf
			echo ">> discover $TYPE type SV"
                	$DELLY -t $TYPE -o $OUT -g $FASTA $BAM
			shift
		fi
		if [[ -n "$4" ]]; then
                        TYPE="$4"
                        OUT=${OUT_DIR}/${prefix}.${TYPE}.vcf
			echo ">> discover $TYPE type SV"
                        $DELLY -t $TYPE -o $OUT -g $FASTA $BAM
                        shift
                fi
		if [[ -n "$4" ]]; then
                        TYPE="$4"
                        OUT=${OUT_DIR}/${prefix}.${TYPE}.vcf
			echo ">> discover $TYPE type SV"
                        $DELLY -t $TYPE -o $OUT -g $FASTA $BAM
                        shift
                fi
		if [[ -n "$4" ]]; then
                        TYPE="$4"
                        OUT=${OUT_DIR}/${prefix}.${TYPE}.vcf
			echo ">> discover $TYPE type SV"
                        $DELLY -t $TYPE -o $OUT -g $FASTA $BAM
                        shift
                fi
	else
		echo ">> output SV type:DEL"
		OUT=${OUT_DIR}/${prefix}.${TYPE}.vcf
                $DELLY -t $TYPE -o $OUT -g $FASTA $BAM
	fi
fi

echo ">> bam: $BAM"
echo ">> fasta: $FASTA"
echo ">> out_dir: $OUT_DIR"

DEL=${OUT_DIR}/${prefix}.DEL.vcf
DUP=${OUT_DIR}/${prefix}.DUP.vcf
INV=${OUT_DIR}/${prefix}.INV.vcf
TRA=${OUT_DIR}/${prefix}.TRA.vcf
INS=${OUT_DIR}/${prefix}.INS.vcf

[[ ! -f $DEL ]] && echo ">> no deletion type SV found!"
[[ ! -f $DUP ]] && echo ">> no duplication type SV found!"
[[ ! -f $INV ]] && echo ">> no inversion type SV found!"
[[ ! -f $TRA ]] && echo ">> no translocation type SV found!"
[[ ! -f $INS ]] && echo ">> no insertion type SV found!"

echo "> DONE $0"`date`
