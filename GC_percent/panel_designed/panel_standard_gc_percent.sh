#!/bin/bash

[[ $# -eq 0 ]] && echo "sh $0 <in_file.bed> <out_file>" && exit 0


in_file="$1"
out_file="$2"


fa="/lustre/project/og04/pub/database/human_genome_hg19/noGL/human_g1k_v37_noGL.fasta"

echo ">> fa: $fa"
chr_po=0
i=1
while read line
do
	chr=$(echo $line| cut -d " " -f 1)
	if [[ $chr_po -ne $chr ]]; then
		chr_po=$(grep -P -n "^>${chr} " $fa | cut -d ":" -f 1 )
	fi
	start_po=$(echo $line| cut -d " " -f 2)
	end_po=$(echo $line| cut -d " " -f 3)
	start_row=$[$start_po/60]
	po_start=$[$start_po - $start_row*60-1]
	if [[ $po_start -eq -1 ]]; then
		line_start=$[$chr_po + $start_row]
		po_start=59
	else
		line_start=$[$chr_po + $start_row + 1]
	fi
	end_row=$[$end_po/60]
	po_end=$[$end_po-$end_row*60]
	if [[ $po_end -eq 0 ]]; then
		line_end=$[$chr_po+$end_row]
		po_end=60
	else
		line_end=$[$chr_po+$end_row+1]
	fi
	a="'${line_start}p'"
	ll=$(eval sed -n $a $fa)
	base=${ll:${po_start}}
	line_start=$[$line_start+1]
	while [[ $line_start -lt $line_end ]]
	do	
		b="'${line_start}p'"
		ll=$(eval sed -n $b $fa)
		base=${base}${ll}
		line_start=$[$line_start+1]
	done
	c="'${line_end}p'"
	ll=$(eval sed -n $c $fa)
	base=${base}${ll:0:${po_end}}
	echo -e "$i	$chr	$start_po	$end_po	$base" >> $out_file 
	i=$[$i+1]
done < $in_file 














