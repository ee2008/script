#!/bin/bash

[[ $# -eq 0 ]] && echo "Usage: sh $0 <*.samtools_stat.txt> <out_dir>" && exit 0

IN="$1"
OUT="$2"
[[ ! -d $OUT ]] && mkdir -pv $OUT

plot_scr="$(dirname $(readlink -e $0))/plot_insert_size_dis.R"

SAMPLE=$(basename $IN .samtools_stat.txt)

grep "^IS" $IN | cut -f 2- > $OUT/$SAMPLE.txt

## == plot
$plot_scr $OUT/$SAMPLE.txt $OUT
rm $OUT/$SAMPLE.txt







