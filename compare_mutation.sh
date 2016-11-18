#!/bin/bash

#cpmpare different depth's mutation
# @wx20160701

[ $# -eq 0 ] && echo "Usage: sh $0 <var_dir> [out_dir|$0_dir]" && exit 0

perl_script="$(dirname $0)/call_diff_from_vcf.pl"

IN_dir="$1"
if [[ $# -gt 1 ]]; then
	OUT="$2"
else
	OUT=$(dirname $0)
fi

out_tem=${OUT}/depth_mutation_tem.txt
out_file=${OUT}/depth_mutation.txt

echo "> START $0 @$(date)"
echo ">> the output: $out_file"

echo "depth(sv)	STANDARD	mutation	intersetion	percent(%)" > $out_tem
ST_sv=$(ls $IN_dir | grep "sv.vcf" | grep -v "_" | grep -v "00")
STAND_sv=${IN_dir}/${ST_sv}
SV=$(ls $IN_dir | grep "sv.vcf" | grep "_" | grep "00")
for i in $SV
do 
	prefix_sv=${i%%.*}
	depth_sv=${prefix_sv##*_}
	sv=$IN_dir/${i}
	/nfs2/pipe/Re/Software/miniconda/bin/perl $perl_script $sv $STAND_sv $depth_sv >> $out_tem
done

echo "depth(var) STANDARD    mutation    intersetion percent(%)" >> $out_tem
ST_var=$(ls $IN_dir | grep "var.vcf" | grep -v "_" | grep -v "00")
STAND_var=${IN_dir}/${ST_var}
VAR=$(ls $IN_dir | grep "var.vcf" | grep "_" | grep "00")
for j in $VAR
do
	prefix_var=${j%%.*}
	depth_var=${prefix_var##*_}
	var=$IN_dir/${j}
	/nfs2/pipe/Re/Software/miniconda/bin/perl $perl_script $var $STAND_var $depth_var >> $out_tem
done

n=$(cat $out_tem | wc -l)  
n=$[n/2]
head -n $n $out_tem |sort -k 1n > $out_file
tail -n $n $out_tem | sort -k 1n >> $out_file

rm $out_tem
echo "> DONE $0 @$(date)"



