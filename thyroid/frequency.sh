#!/bin/bash

#extract the alt frequency form mutect varscan speedseq
# @wxian2016JULY21

[[ $# -eq 0 ]] && echo "Usage: sh $0 <in_file(Chr     Start   End     Ref     Alt)> <project_dir>  <sample_prefix> <out_dir|in_file_dir>" && exit 0

IN="$1"
VAR="$2"
PREFIX="$3"

if [[ $# -gt 3 ]]; then
	OUT="$4"/$PREFIX.frequency.txt
else
	OUT=$(dirname $IN)/$PREFIX.frequency.txt
fi

mutect=$VAR/var_mutect/${PREFIX}.snv.mutect_all.vcf
speedseq=$VAR/var/${PREFIX}.var.vcf
varscan=$VAR/var_varscan/${PREFIX}.snv.txt

echo "#CHR	PO	REF	ALT	mutect_ref,alt	mutect_fre	speedseq_ref,alt	speedseq_fre	varscan_ref,alt	varscan_fre" >$OUT
while read line
do
	key1=$(echo $line | awk -F " " '{print $1}')
	key2=$(echo $line | awk -F " " '{print $2}')
	key3=$(echo $line | awk -F " " '{print $4}')
	key4=$(echo $line | awk -F " " '{print $5}')
	mutect_line=$(grep  ^$key1$'\t'$key2$'\t' $mutect | grep  $key3$'\t'$key4$'\t')
	if [[ -z $mutect_line ]]; then
		mutect_fre="."
	else
		mutect_fre_all=$(echo $mutect_line | cut -d " " -f 11)
		mutect_fre0=$(echo $mutect_fre_all | awk -F ":" '{print $5}')
		mutect_fre0=$(printf "%f\n" $mutect_fre0)
		mutect_fre00=$(echo "scale=2; $mutect_fre0*100" | bc)
		mutect_ref_alt=$(echo $mutect_fre_all | awk -F ":" '{print $2}')
		mutect_fre="$mutect_ref_alt	$mutect_fre00%"
	fi
	speedseq_line=$(grep ^$key1$'\t'$key2$'\t' $speedseq | grep $key3$'\t'$key4$'\t')
	if [[ -z $speedseq_line ]]; then
		speedseq_fre="."
	else
		speedseq_fre_all=$(echo $speedseq_line | cut -d " " -f 11)
		speedseq_ref=$(echo $speedseq_fre_all | awk -F ":" '{print $4}')
		speedseq_alt=$(echo $speedseq_fre_all | awk -F ":" '{print $6}')
		speedseq_fre0=$(echo "scale=4; ${speedseq_alt}/$[${speedseq_ref}+${speedseq_alt}]*100" | bc)
		speedseq_fre="$speedseq_ref,$speedseq_alt	${speedseq_fre0}%"
	fi
	varscan_line=$(grep ^$key1$'\t'$key2$'\t' $varscan | grep $key3$'\t'$key4$'\t')
	if [[ -z $varscan_line ]]; then
		varscan_fre="."
	else
		varscan_fre=$(echo $varscan_line | awk -F " " '{print $9","$10"\t"$11}')	
	fi
	echo "$key1	$key2	$key3	$key4	$mutect_fre	$speedseq_fre	$varscan_fre" >> $OUT
done < $IN










