#!/bin/bash

[[ $# -eq 0 ]] && echo "Usage: sh $0 <*.samtools_stat.txt> <out_dir>" && exit 0

IN="$1"
prefix=$(basename $IN .samtools_stat.txt)
OUT_dir="$2"
[[ ! -d $OUT_dir ]] && mkdir -pv $OUT_dir

grep "^IS" $IN | cut -f 2,3 > $OUT_dir/${prefix}_insert.size.txt




