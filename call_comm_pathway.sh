#!/bin/bash
# @wxian

[[ $# -eq 0 ]] && echo -e "Usage: sh $0 <input1> <input2> ..." && exit 1

n=$#
intersection1="$1"
cp $intersection1 intersection1.pathway.txt

for ((i=2;i<=${n};i++)) 
do
	file2="$2"
	j=$(($i-1))
	tem=intersection${j}.pathway.txt
	cat $tem $file2 | sort -k 1 | uniq -d > ./intersection${i}.pathway.txt
	shift
	rm $tem
done

sed -e '1i\GeneID\tPathway\tGO Component\tGO Function\tGO Process\tBlast nr' intersection${n}.pathway.txt > intersection.pathway.txt

rm intersection${n}.pathway.txt

