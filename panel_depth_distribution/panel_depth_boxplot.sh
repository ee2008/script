#!/bin/bash

# @wxian2017Jan04

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 -i <sample.samtools_depth_bed.txt/sample.bedtools_intersect.txt> -o <out_dir> [-p <panel.bed> |if input data from samtools] [-n <output_prefix> | "panel_depth_boxplot"] [-t <png/svg/pdf/...> | png]

options:
	-i Input File: sample.samtools_depth_bed.txt or sample.bedtools_intersect.txt
	-o out_dir
	-p Panel_bed: only need when input data from samtools
	-n output_prefix: for example: ABC.bedtools_boxplot(default: panel_depth_boxplot)
	-t Image Format: png/svg/pdf...(default: png)

EOF
exit 0
fi

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-i) IN="$2"
			shift; ;;	
		-p) PANEL="$2"
			shift; ;;
		-o) OUT_dir="$2"
			[[ ! -d $OUT_dir ]] && mkdir -pv $OUT_dir
			shift; ;;
		-n) OUTPUT="$2"
			shift; ;;
		-t) TYPE="$2"
			shift; ;;
	esac
	shift
done

LD_LIBRARY_PATH="/nfs2/pipe/Re/Software/miniconda/lib"
R_boxplot=$(dirname $(readlink -e $0))/panel_depth_boxplot.R

file=$(basename $IN)
sample=$(echo $file | cut -d "." -f 1)
tools=$(echo $file | cut -d "." -f 2 | cut -d "_" -f 1 )


[[ -z $OUTPUT ]] && OUTPUT=${sample}.${tools}_panel_depth_boxplot
[[ -z $TYPE ]] && TYPE="png"

echo ">> BEGINNING @$(date)"

if [[ $tools == "bedtools" ]]; then
	SUM=$(cut -f 1,2,3 $IN | uniq | wc -l)
else
	if [[ -z $PANEL ]]; then
		echo "!Error: NO FILE: panel.bed"
		exit 1
	else
		SUM=$(wc -l $PANEL)
	fi
fi

echo "> total_bed: $SUM"



if [[ $SUM -gt 2000 ]]; then
	echo "> PLOT by chr"
	for i in `seq 1 22` X Y
	do
		echo "> PROCESSING CHR$i"
		INPUT_chr=$OUT_dir/${sample}.chr${i}.txt
		INPUT_panel=$OUT_dir/panel.chr${i}.bed
		if [[ $tools == "bedtools" ]]; then
			grep -P "^${i}\t" $IN | awk -F "\t" '{print $1"\t"$2"\t"$3"\t"$(NF-1)"\t"$NF}'> $INPUT_chr
			if [[ ! -s $INPUT_chr ]]; then
				echo "> !NO DATA: CHR$i"
				rm $INPUT_chr
				continue
			fi
			cut -f 1,2,3 $INPUT_chr |uniq -c | sed 's/^[ \t]*//g' > $INPUT_panel
		else 
			grep -P "^${i}\t" $IN > $INPUT_chr
			grep -P "^${i}\t" $PANEL > $INPUT_panel
		fi
		$R_boxplot $INPUT_chr $tools $OUT_dir/${OUTPUT}_chr${i}.$TYPE $TYPE $i $INPUT_panel
		rm $INPUT_chr
		rm $INPUT_panel
	done
else
	if [[ $tools == "bedtools" ]]; then
		INPUT=$OUT_dir/${sample}.txt
		PANEL=$OUT_dir/panel.bed
		awk -F "\t" '{print $1"\t"$2"\t"$3"\t"$(NF-1)"\t"$NF}' $IN > $INPUT
		cut -f 1,2,3 $INPUT | uniq -c | sed 's/^[ \t]*//g' > $PANEL
		$R_boxplot $INPUT $tools $OUT_dir/${OUTPUT}.$TYPE $TYPE all $PANEL
		rm $INPUT
		rm $PANEL
	else
		$R_boxplot $IN $tools $OUT_dir/${OUTPUT}.$TYPE $TYPE all $PANEL
	fi
fi

echo "DONE" > $OUT_dir/${sample}.${tools}_boxplot_done.txt
echo ">> ALL DONE @$(date)"








