#!/bin/bash

[[ $# -eq 0 ]] && echo "Usage: sh $0 <project_dir> [output_dir | project_dir/qc/]" && exit 0

DIR=$(readlink -e "$1")
if [[ $# -eq 2 ]];then
	out_dir="$2"
	[[ ! -d $out_dir ]] && mkdir -pv $out_dir
else
	out_dir="$DIR/qc"
fi

output="$out_dir/qc_summary_warning.txt"
warning_sample="$out_dir/warning_sample.txt"
note_sample="$out_dir/note_sample.txt"
warning_info="$out_dir/warning_info.txt"

#===parameter
p1p4_LEUD=0.1
p1p4_CFD=0.1
p1p4_other=1
p1p2p4_LEUD=0.2
p1p2p4_CFD=2
p1p2p4_other=0.2
morgene_LEUD=0.025
cancer50_other=0.07
lungcancer7_CFD=0.15
lungcancer7_other=0.03

#===function
function qc_warning() {
	sample=$1
	echo "$sample" >> $warning_info	
	project_index=$(basename $DIR | awk -F "_" '{print $NF}')
	if [[ $project_index == "p1p4" ]];then
		if [[ $sample =~ "CFD" ]];then
			size_thr=$p1p4_CFD
		elif [[ $sample =~ "LEUD" ]];then
			size_thr=$p1p4_LEUD
		else
			size_thr=$p1p4_other
		fi
	elif [[ $project_index == "p1p2p4" ]];then
		if [[ $sample =~ "CFD" ]];then
			size_thr=$p1p2p4_CFD
		elif [[ $sample =~ "LEUD" ]];then
			size_thr=$p1p2p4_LEUD
		else
			size_thr=$p1p2p4_other
		fi
	elif [[ $(basename $DIR) =~ "morgene" ]];then
		if [[ $project_index == "morgene" ]];then
			size_thr=$morgene_LEUD
		elif [[ $project_index == "lungcancer7" ]];then
			if [[ $sample =~ "CFD" ]];then
				size_thr=$lungcancer7_CFD
			else
				size_thr=$lungcancer7_other
			fi
		elif [[ $project_index == "cancer50" ]];then
			size_thr=$cancer50_other
		fi
	else
		size_thr=100
	fi
	
	size_sample=$(grep "$sample" $DIR/qc/qc_summary_brief.txt | cut -f 2 )
	size_thr_5=$(echo "scale=4;0.5*$size_thr" | bc)
	size_thr_8=$(echo "scale=4;0.8*$size_thr" | bc)
	if [ $(echo "$size_sample < $size_thr_5" | bc) -eq 1 ];then
		echo "$sample" >> $warning_sample
		echo -e "!!!Warning: ${sample} on size_Gb with $size_sample smaller than $size_thr_5" >> $warning_info 
	elif [ $(echo "$size_sample < $size_thr_8" | bc) -eq 1 ];then
		echo "$sample" >> $note_sample
		echo -e "Note: ${sample} on size_Gb with $size_sample smaller than $size_thr_8" >> $warning_info
	fi
	
	coverage=$(grep "$sample" $DIR/qc/qc_summary_brief.txt | cut -f 18 )
	if [ $(echo "$coverage < 0.9" | bc) -eq 1 ];then
		echo "$sample" >> $warning_sample
		echo -e "!!!Warning: ${sample} on coverage_cent with $coverage smaller than 0.9" >> $warning_info
	elif [ $(echo "$coverage < 0.95" | bc) -eq 1 ];then
		echo "$sample" >> $note_sample
		echo -e "Note: ${sample} on coverage_cent with $coverage smaller than 0.95" >> $warning_info
	fi
	
	mut_dep=$(grep "$sample" $DIR/qc/qc_summary_brief.txt | cut -f 26)
	if [[ $sample =~ "LEUD" ]];then
		continue
	elif [[ $sample =~ "CFD" ]];then
		if [[ $mut_dep -lt 1000 ]];then
			echo "$sample" >> $warning_sample
			echo -e "!!!Warning: ${sample} on mut_dep with $mut_dep smaller than 1000" >> $warning_info
		elif [[ $mut_dep -lt 1500 ]];then
			echo "$sample" >> $note_sample
			echo -e "Note: ${sample} on mut_dep with $mut_dep smaller than 1500" >> $warning_info
		fi
	else
		if [[ $mut_dep -lt 200 ]];then
			echo "$sample" >> $warning_sample
			echo -e "!!!Warning: ${sample} on mut_dep with $mut_dep smaller than 200" >> $warning_info
		elif [[ $mut_dep -lt 500 ]];then
			echo "$sample" >> $note_sample
			echo -e "Note: ${sample} on mut_dep with $mut_dep smaller than 500" >> $warning_info
		fi
	fi
	
	insert_size=$(grep "$sample" $DIR/qc/qc_summary_brief.txt | cut -f 23)
	if [ $(echo "$insert_size > 300" | bc) -eq 1 ];then
		echo "$sample" >> $warning_sample
		echo -e "!!!Warning: ${sample} on insert_size with $insert_size larger than 300" >> $warning_info
	elif [ $(echo "$insert_size > 250" | bc) -eq 1 ];then
		echo "$sample" >> $note_sample
		echo -e "Note: ${sample} on insert_size with $insert_size larger than 250" >> $warning_info
	fi
	
	mut_num=$(($(wc -l $DIR/var_intevar/${sample}.var.panel.tsv | cut -d " " -f 1)-1))
	if [[ $mut_num -lt 50 ]];then
		echo "$sample" >> $warning_sample
		echo -e "!!!Warning: ${sample} on mut_num with $mut_num smaller than 50" >> $warning_info
	elif [[ $mut_num -lt 100 ]];then
		echo "$sample" >> $note_sample
		echo -e "Note: ${sample} on mut_num with $mut_num smaller than 100" >> $warning_info
	fi
}


#===main
echo "Warning message:" > $output
echo " " >> $output
echo ">> sample info:" > $warning_info

# == split data
raw_path=$(grep "^#/p299/" "$DIR/project_info.txt" | cut -d "#" -f 2)
cn500_path="/p299/raw/2016/cn500/fq/fq/"
for raw_i in $raw_path
do
	raw_dir=$(readlink -e $raw_i)
	split_dir=$(dirname $raw_dir)
	raw_name=${split_dir##*/}
	unmatch=$(grep "^#unmatched" $split_dir/Result.txt | cut -f 3)
	total=$(grep "^#total" $split_dir/Result.txt | cut -f 3)
	unmatch_cent=$(echo "scale=1;$unmatch*100/$total" | bc)
	if [ $(echo "$unmatch_cent > 30" | bc) -eq 1 ];then
		echo "!!!Warning: split data $raw_name on unmatch_cent with ${unmatch_cent}% larger than 30%" >> $output
	elif [ $(echo "$unmatch_cent > 25" | bc) -eq 1 ];then
		echo "Note: split data $raw_name on unmatch_cent with ${unmatch_cent}% larger than 25%" >> $output
	else
		echo "Split data passed!" >> $output
	fi
done
echo "" >> $output

#== qc warning
BED=$(grep "#panel_bed" $DIR/project_info.txt | cut -f 2)
BED_info="${BED}.info"
[[ ! -d $out_dir/panel/ ]] && mkdir -pv $out_dir/panel/
BED_PO=$out_dir/panel/tem_bed.info.txt
grep -P "\tsnp\t" $BED_info > $BED_PO
grep -P "\tindel\t" $BED_info >> $BED_PO
echo ">> Depth smaller than 1000" > $out_dir/tem_head_po_depth_1000.txt 
echo " " > $out_dir/tem_tail_po_depth_1000.txt
while read line
do
	sample=$(echo $line |cut -d " " -f 1 )
	if [[ $sample == \#* ]];then
		continue
	fi
	qc_warning $sample
	echo " " >> $warning_info
	if [[ $sample =~ "CFD" ]];then
		awk -F "\t" '{print $1"\t"$2-1"\t"$2"\t"$3}' $DIR/qc/panel/${sample}.samtools_depth_bed.txt > $out_dir/panel/${sample}.samtools_depth_po.txt
		/nfs2/biosoft/bin/bedtools intersect -a $BED_PO -b $out_dir/panel/${sample}.samtools_depth_po.txt -wa -wb > $out_dir/panel/${sample}.samtools_depth_bed_intersection.txt
		/nfs2/biosoft/bin/bedtools intersect -a $BED_PO -b $out_dir/panel/${sample}.samtools_depth_po.txt -wa > $out_dir/panel/${sample}.tem_depth_bed_intersection.txt
		cat $out_dir/panel/${sample}.tem_depth_bed_intersection.txt $out_dir/panel/${sample}.tem_depth_bed_intersection.txt $BED_PO | sort -n | uniq -u | awk -F "\t" '{print $0"\t"$1"\t"$2"\t"$3"\t"0}' >> $out_dir/panel/${sample}.samtools_depth_bed_intersection.txt
		awk '{if ($NF < 1000) print $0}' $out_dir/panel/${sample}.samtools_depth_bed_intersection.txt > $out_dir/panel/${sample}.samtools_depth_1000.txt
		if [[ -s $out_dir/panel/${sample}.samtools_depth_1000.txt ]];then
			nrow=$(wc -l $out_dir/panel/${sample}.samtools_depth_1000.txt | cut -d " " -f 1)
			echo "!!!Warning: $sample with $nrow po's depth smaller than 1000" >> $out_dir/tem_head_po_depth_1000.txt
			echo "$sample" >> $out_dir/tem_tail_po_depth_1000.txt
			cat $out_dir/panel/${sample}.samtools_depth_1000.txt >> $out_dir/tem_tail_po_depth_1000.txt
			echo " " >> $out_dir/tem_tail_po_depth_1000.txt
		fi
		rm $out_dir/panel/${sample}.samtools_depth_po.txt $out_dir/panel/${sample}.samtools_depth_bed_intersection.txt $out_dir/panel/${sample}.tem_depth_bed_intersection.txt
	fi
done < $DIR/qc/qc_summary_brief.txt
rm $BED_PO

if [[ ! -e $warning_sample ]];then
	echo "No warning sample!" >> $warning_sample
fi
if [[ ! -e $note_sample ]];then
	echo "No note sample!" >> $note_sample
fi

uniq $warning_sample > ${warning_sample}_tem
uniq $note_sample > ${note_sample}_tem
echo -e "Warning sample:" >> $output
cat ${warning_sample}_tem >> $output
echo " " >> $output

echo -e "Note sample:" >> $output
cat ${note_sample}_tem ${warning_sample}_tem ${warning_sample}_tem | sort -n | uniq -u >> $output

echo " " >> $output

cat $warning_info >> $output
rm $warning_sample $note_sample ${note_sample}_tem ${warning_sample}_tem $warning_info

if [ $(wc -l $out_dir/tem_head_po_depth_1000.txt | cut -d " " -f 1) -gt 1 ];then
#if [[ -e $out_dir/tem_head_po_depth_1000.txt ]];then
	cat $out_dir/tem_head_po_depth_1000.txt $out_dir/tem_tail_po_depth_1000.txt > $out_dir/qc_summary_depth.txt 
	rm $out_dir/tem_head_po_depth_1000.txt $out_dir/tem_tail_po_depth_1000.txt
else
	echo "All samples' depth passed!" > $out_dir/qc_summary_depth.txt 
fi

