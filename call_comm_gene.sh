#!/bin/bash
# @wxian

[[ $# -eq 0 ]] && echo -e "Usage: sh $0 <input1> <input2> ..." && exit 1

n=$#
intersection1="$1"
cp $intersection1 intersection1.gene.txt

for ((i=2;i<=${n};i++)) 
do
	file2="$2"
	j=$(($i-1))
	tem=intersection${j}.gene.txt
	cat $tem $file2 | sort | uniq -d > ./intersection${i}.gene.txt
	shift
	rm $tem
done

mv intersection${n}.gene.txt intersection.gene.txt


