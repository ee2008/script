#!/bin/bash 

# plot gc_content 
# @wxian2017Feb17

# == need scripts
#GC_COUNT=$(dirname $0)/GC_count_panel.pl
PLOT_R="$(dirname $0)/plot_gc_depth.R"

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 [options]
	-o <out_dir>  
	-c [gc/depth |all]
	-ng [gc_output_name | CA-PM.gc_content.png] 
	-nd [depth_output_name | CA-PM.depth.png] 
	-p [project_dir | /p299/user/og04/shenzhongji/CA-PM/] 
	-s [project_sample_index | /p299/project/og04/shenzhongji2/CA-PM/all_qc_stats/project_sample_index.txt] 
	-b [batch1,batch2..batch10| all] 
	-t [CFD/LEUD/.. | all]  
	-f [boxplot/scatter |all]
EOF
exit 0
fi

PROJECT="/p299/user/og04/shenzhongji/CA-PM/"
SAMPLE_INDEX="/p299/project/og04/shenzhongji2/CA-PM/all_qc_stats/project_sample_index.txt"
CONTENT="all"
BATCH="all"
TYPE=" "
IMAGE="all"
NAME_GC="CA-PM.gc_content.png"
NAME_DEPTH="CA-PM.depth.png"

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-o) OUT_dir="$2"
			[[ ! -d $OUT_dir ]] && mkdir -pv $OUT_dir
			shift; ;;
		-c) CONTENT="$2"
			shift; ;;
		-ng) NAME_GC="$2"
			shift; ;;
		-nd) NAME_DEPTH="$2"
			shift; ;;
		-p) PROJECT="$2"
			shift; ;;
		-s) SAMPLE_INDEX="$2"
			shift; ;;
		-b) BATCH="$2"
			shift; ;;
		-t) TYPE="$2"
			shift; ;;
		-f) IMAGE="$2"
			shift; ;;
	esac
	shift
done

echo "> START  @$(date)"

## processing batch
tem_date=$(date "+%Y%m%d_%H%M%S")
tem_sample_list="$OUT_dir/tem.sample_list_${tem_date}.txt"
if [[ $BATCH != "all" ]]; then
	BATCH=${BATCH//,/ }
	for i in $BATCH
	do
		if [[ $i =~ \.\. ]]; then
			START=$(echo $i | cut -d "." -f 1 |cut -d "_" -f 1 | cut -d "-" -f 3)	
			END=$(echo $i | cut -d "." -f 3 | cut -d "_" -f 1 | cut -d "-" -f 3)
			if [[ -z $END ]]; then
				END=$(tail -n 1 $SAMPLE_INDEX | cut -d " " -f 1 | cut -d "_" -f 1 | cut -d "-" -f 3)	
			fi
			while read line
			do
				TIME=$(echo $line | cut -d " " -f 1 | cut -d "_" -f 1 | cut -d "-" -f 3)
				if [[ $TIME -ge $START ]] && [[ $TIME -le $END ]] && [[ $line =~ $TYPE ]]; then
					echo -e "$line" >> $tem_sample_list
				fi
			done < $SAMPLE_INDEX
		else 
			grep "$i" $SAMPLE_INDEX | grep "$TYPE" >> $tem_sample_list
		fi
	done
else
	cp $SAMPLE_INDEX $tem_sample_list
fi

GC_COUNT="$OUT_dir/CA-PM.gc_depth_${tem_date}.txt"
while read line
do
	CA_PM=$(echo $line | cut -d " " -f 1)
	SAMPLE=$(echo $line | cut -d " " -f 2)
	sampel_path=$PROJECT/$CA_PM/${SAMPLE}.gc_content.txt
	#sampel_path=$PROJECT/$CA_PM/qc/panel/${SAMPLE}.gc_content.txt
	cat $sampel_path >> $GC_COUNT
done < $tem_sample_list
rm $tem_sample_list

# == plot 
echo "> PLOTTING  @$(date)"
$PLOT_R $GC_COUNT $OUT_dir $NAME_GC $NAME_DEPTH $IMAGE $CONTENT

#rm $GC_COUNT

echo "> DONE  @$(date)"














