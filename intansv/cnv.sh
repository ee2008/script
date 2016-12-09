#!/bin/bash

# call CNV from bam via CNVnator
# @szj^15Dec17

# ==== env
ENV_SH="/nfs2/pipe/Cancer/Bin/Flamingo/source.sh"
CNVNATOR="/nfs2/pipe/Cancer/Software/CNVnator/CNVnator_v0.3/src/cnvnator"

# ==== argv
[[ $# -lt 2 ]] && echo "Usage: sh $0 <bam> <fa_dir> [-chr <chr_name>] [out_dir|bam_dir]" && exit

# == bam
BAM=$1
[[ ! -f $BAM ]] && echo "! no such bam: $BAM" && exit 1

# == fa split
FA_dir=$2
if [[ ! -d $FA_dir ]]; then
    echo "! no such fa_dir: $FA_dir"
    exit 1
fi

# == out and chr
OUT=$(dirname $BAM)
CHR=0
if [[ $# -gt 2 ]]; then
    if [[ "$3" == '-chr' ]]; then
        if [[ -z $4 ]]; then
            echo "no chr_name after -chr"
            exit
        fi
        CHR=$4
        echo "! specific on chr: $CHR"
        shift ; shift
    fi
    if [[ $# -eq 3 ]]; then
        OUT=$3
    fi
fi

if [[ "$CHR" == 0 ]]; then
    echo ">> for all chr"
    CHR_PAR=""
else
    #if [[ ! -f $FA_dir/${CHR}.fa ]]; then
        #echo "! no such fa: $FA_dir/$CHR.fa"
        #exit 1
    #fi
    CHR_PAR="-chrom $CHR"
fi

# == prepare
prefix=$(basename $BAM)
prefix=${prefix%%.bam}
if [[ "$CHR" != 0 ]]; then
    #chr=${CHR/\ /-}
    chr=${CHR//\ /-}
    prefix=${prefix}_$chr
fi

# == var
bin_size=1000
root=$OUT/${prefix}.root
LOG=$OUT/${prefix}.cnvnator.log
to_log="> $LOG 2>&1"

echo "> START $0 "`date`
echo ">> bam: $BAM"
echo ">> fa dir: $FA_dir"
echo ">> out dir: $OUT"
echo ">> chr: $CHR"
echo ">> root file: $root"
echo ">> log file: $LOG"

[[ ! -d $OUT ]] && mkdir -pv $OUT

echo "> START $0 "`date` > $LOG
echo ">> bam: $BAM" >> $LOG
echo ">> fa dir: $FA_dir" >> $LOG
echo ">> out dir: $OUT" >> $LOG
echo ">> chr: $CHR" >> $LOG
echo ">> root file: $root" >> $LOG

#exit  # for tes

# ==== main
source $ENV_SH

# == tree
echo "> tree "`date`
echo "> tree "`date` >> $LOG
$CNVNATOR -root $root $CHR_PAR -tree $BAM >> $LOG 2>&1

# == hist
echo "> hist "`date`
echo "> hist "`date` >> $LOG
$CNVNATOR -root $root $CHR_PAR -his $bin_size -d $FA_dir >> $LOG 2>&1

# == stat
echo "> stat "`date`
echo "> stat "`date` >> $LOG
$CNVNATOR -root $root $CHR_PAR -stat $bin_size >> $LOG 2>&1

# == partition
echo "> partition "`date`
echo "> partition "`date` >> $LOG
$CNVNATOR -root $root $CHR_PAR -partition $bin_size >> $LOG 2>&1

# == call
echo "> call "`date`
echo "> call "`date` >> $LOG
$CNVNATOR -root $root $CHR_PAR -call $bin_size > $OUT/${prefix}.cnv 2>>$LOG

# ==== output format
echo "
> OUTPUT FORMAT:
CNV_type coordinates CNV_size normalized_RD e-val1 e-val2 e-val3 e-val4 q0

normalized_RD -- normalized to 1.
e-val1 -- is calculated using t-test statistics.
e-val2 -- is from the probability of RD values within the region to be in
the tails of a gaussian distribution describing frequencies of RD values in bins.
e-val3 -- same as e-val1 but for the middle of CNV
e-val4 -- same as e-val2 but for the middle of CNV
q0 -- fraction of reads mapped with q0 quality
"

# ====
echo "> DONE "`date`
echo "> DONE "`date` >> $LOG
