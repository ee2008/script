#!/bin/bash

# @wxian2017Aug01

[[ $# -eq 0 ]] && echo "Usage: sh $0 <sample_list> <cancer_panno> <out_dir> [cfd/tissue/cons | all]" && exit 0


SAMPLE_LIST="$1"
cancer_panno="$2"
OUT_dir="$3"
if [[ $# -eq 4 ]];then
	if [[ $4 == "cfd" ]]; then
		t=1
	elif [[ $4 == "tissue" ]];then
		t=2
	elif [[ $4 == "cons" ]];then
		t=3
	fi
else
	t=0
fi

[[ ! -d $OUT_dir ]] && mkdir -pv $OUT_dir

SAMPLE_REF="/p299/user/og04/ogsmor/CA-PM/all_qc_stats/project_sample_index.txt"
SAMPLE_REF_old="/p299/user/og04/ogsmor/CA-PM/all_qc_stats/project_sample_index_old.txt"
plot_script="$(dirname $0)/plot.R"
CSVCUT="/nfs2/pipe/Re/Software/miniconda/bin/csvcut"
CSVF="/nfs2/pipe/Re/Software/miniconda/bin/csvformat"

## function
#function sample_type() {
#	if [[ $1 == *CFD* ]];then
#		echo "CFD"
#	elif [[ $1 == *LEUD* ]];then
#		echo "LEUD"
#	else 
#		echo "tissue"
#	fi
#}



## sample path
[[ -e $OUT_dir/tem_sample_path.txt ]] && rm $OUT_dir/tem_sample_path.txt
while read line
do 
	grep "$line" $SAMPLE_REF | grep -v "LEUD" | awk -v k=$line '{print "/p299/user/og04/ogsmor/CA-PM/"$1"/output/ "$2" "k}'>> $OUT_dir/tem_sample_path.txt
	grep "$line" $SAMPLE_REF_old | grep -v "LEUD"| awk -v k=$line '{print "/p299/project/og04/shenzhongji2/CA-PM/"$1"/output/ "$2" "k}' >> $OUT_dir/tem_sample_path.txt
	l1=$(grep "$line" $SAMPLE_REF | grep -v "LEUD" | wc -l)
	l2=$(grep "$line" $SAMPLE_REF_old | grep -v "LEUD"| wc -l)
	if [ $[$l1+$l2] -gt 1 ];then
		grep "$line" $SAMPLE_REF | grep -v "LEUD" | awk -v k=$line '{print "/p299/user/og04/ogsmor/CA-PM/"$1"/output/ "$2" "k}'>> $OUT_dir/tem_sample_path_cons.txt
		grep "$line" $SAMPLE_REF_old | grep -v "LEUD"| awk -v k=$line '{print "/p299/project/og04/shenzhongji2/CA-PM/"$1"/output/ "$2" "k}' >> $OUT_dir/tem_sample_path_cons.txt
	fi
done < $SAMPLE_LIST

grep "CFD" $OUT_dir/tem_sample_path.txt > $OUT_dir/tem_sample_path_CFD.txt
grep -v "CFD" $OUT_dir/tem_sample_path.txt > $OUT_dir/tem_sample_path_tissue.txt
rm $OUT_dir/tem_sample_path.txt

## function--extract data/merge sample
function ms() {
	IN="$1"
	OUT="$2"
	s_type="$3"
	[[ -e $OUT ]] && rm $OUT
	while read line
	do
		sample=$(echo $line | cut -d " " -f 2)
		output_path=$(echo $line | cut -d " " -f 1)
		ID=$(echo $line | cut -d " " -f 3)
		file_path=$(ls $output_path/*${sample}*var.panel.tsv | grep -v "LEUD")
		colname=$(head -n 1 $file_path)
		n1=1
		for i in $colname
		do
			if [[ $i == "panno" ]];then
				break
			else
				n1=$[$n1+1]
			fi
		done
		n2=1
		for j in $colname
		do
			if [[ $j == "VF" ]];then
				break
			else
				n2=$[$n2+1]
			fi
		done
		n_colname=$(echo $colname | awk '{print NF}')
		if [ $n1 -eq $[$n_colname + 1] ] || [ $n2 -eq $[$n_colname + 1] ];then
			continue
		fi
		if [[ -n $file_path ]];then
			$CSVCUT -t -c "gene,panno,VF" $file_path | $CSVF -T | sed -n '2,$p' | awk -F "\t" -v k1=$sample -v k2=$ID '{if (($2 != ".") && ($3 != ".")) print k1"\t"$0"\t"k2}' >> ${OUT}_unsort
	#		sed -n '2,$p' $file_path| cut -f $n1,$n2,$n3 | awk -F "\t" -v k1=$sample '{if (($1 != ".") && ($2 != ".")) print k1"\t"$0}' >> $OUT_dir/all.var.panel.tsv
		fi
	done < $IN
	
	echo -e "sample	gene	panno	VF	ID" > $OUT
	sort -k 3 ${OUT}_unsort | uniq >> $OUT 
	rm ${OUT}_unsort	
	## === plot
	$plot_script $OUT $cancer_panno $s_type $OUT_dir  
}

if [[ $t -eq 1 ]];then
	[[ -e $OUT_dir/tem_sample_path_CFD.txt ]] && ms $OUT_dir/tem_sample_path_CFD.txt $OUT_dir/all.var.panel_CFD.txt CFD 
elif [[ $t -eq 2 ]];then
	[[ -e $OUT_dir/tem_sample_path_tissue.txt ]] && ms $OUT_dir/tem_sample_path_tissue.txt $OUT_dir/all.var.panel_tissue.txt tissue 
elif [[ $t -eq 3 ]];then
	[[ -e $OUT_dir/tem_sample_path_cons.txt ]] && ms $OUT_dir/tem_sample_path_cons.txt $OUT_dir/all.var.panel_cons.txt consistency 
elif [[ $t -eq 0 ]];then
	[[ -e $OUT_dir/tem_sample_path_CFD.txt ]] && ms $OUT_dir/tem_sample_path_CFD.txt $OUT_dir/all.var.panel_CFD.txt CFD 
	[[ -e $OUT_dir/tem_sample_path_tissue.txt ]] && ms $OUT_dir/tem_sample_path_tissue.txt $OUT_dir/all.var.panel_tissue.txt tissue 
	[[ -e $OUT_dir/tem_sample_path_cons.txt ]] && ms $OUT_dir/tem_sample_path_cons.txt $OUT_dir/all.var.panel_cons.txt consistency 
fi

rm $OUT_dir/tem_sample_path_CFD.txt $OUT_dir/tem_sample_path_tissue.txt $OUT_dir/tem_sample_path_cons.txt


