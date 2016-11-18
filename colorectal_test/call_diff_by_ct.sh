#!/bin/bash

[[ $# -eq 0 ]] && echo -e "Usage: $0 <input1> <input2> " && exit 1

file1="$1"
file2="$2"

cat $file1 | grep -v "^#" | grep -v "^GL" | sort -n -u -k 1 -k 2 | awk '{print $1,$2}' > ./tem1.txt
cat $file2 | grep -v "^#" | grep -v "^GL" | sort -n -u -k 1 -k 2|awk '{print $1,$2}' > ./tem2.txt

name_file=$(basename $file1)
prefix=${name_file:0:4}

cat tem1.txt tem2.txt | sort -n | uniq -d > ${prefix}_ct1_ct2_both.pos
cat tem1.txt tem2.txt tem2.txt | sort -n | uniq -u > ${prefix}_ct1.pos
cat tem2.txt tem1.txt tem1.txt | sort -n | uniq -u > ${prefix}_ct2.pos

rm ./tem1.txt ./tem2.txt

