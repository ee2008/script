#!/bin/bash

# call SV from <sort.bam> by breakdancer
# output <sv>
# @szj^15Dec16

# ==== env
PERL="/nfs2/pipe/Cancer/Software/BreakDancer/perl/perl-5.12.5/perl"
BAM2CFG_PL="/nfs2/pipe/Cancer/Software/BreakDancer/breakdancer-1.1.2/perl/bam2cfg.pl"
SAMTOOLS="/nfs2/pipe/Re/Software/miniconda/bin/samtools"
BREAKDANCER="/lustre/project/og04/pub/biosoft/bin/breakdancer-max"

# ==== argv
[[ $# -eq 0 ]] && echo "Usage: sh $0 <bam> [out_dir|bam_dir] [out_sv|bam_prefix]" && exit

BAM="$1"
OUT="$2"
SV="$3"

echo "> START $0 "`date`

# ==== assert argv

# == BAM
# TODO: to support multiple bam input argv
[[ ! -f $BAM ]] && echo "! no such bam: $BAM" && exit 1
echo "> input bam: $BAM"
#BAM=$(readlink -e $BAM)
prefix=$(basename $BAM)
prefix=${prefix%%.bam}

# == OUT
[[ $# -lt 2 ]] && OUT=$(dirname $BAM)
#BAM=$(readlink -e $BAM)
OUT=$(readlink -e $OUT)
[[ ! -d $OUT ]] && mkdir -pv $OUT
echo "> out dir: $OUT"

# == SV
[[ $# -lt 3 ]] && SV="$OUT/${prefix}.sv"

CFG="$OUT/${prefix}.cfg"

# ==== main

# == cfg
echo "> generate cft file: $CFG"
$PERL $BAM2CFG_PL -g -h $BAM > $CFG
# `-g` `-h` will generate histogram and plot under $PWD
if [[ "$PWD" != "$OUT" ]]; then
    mv -v $PWD/${prefix}.bam*insertsize_histogram $PWD/${prefix}.bam*insertsize_histogram.png $OUT
fi
# NOTE: bam2cfg will through a 'Use of uninitialized value in printf at /nfs2/pipe/Cancer/Software/BreakDancer/breakdancer-1.1.2/perl/bam2cfg.pl line 247.' warning
# TODO: modify library:NA in $CFG to avoid error for multiple bam input

# == check bam index
BAI="$BAM.bai"
if [[ ! -f $BAI ]]; then
    echo "!! no bam index, will generate now"
    $SAMTOOLS index $BAM
fi

# == breakdancer
echo "> call sv: $SV"
$BREAKDANCER $CFG > $SV

# == anno
# TODO

echo "> DONE $0 $prefix"`date`
