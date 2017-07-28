#!/bin/bash

# @wxian2017Mar31

# generate produce_log 

[[ $# -eq 0 ]] && echo "Usage: sh $0 <project_dir> <out_file>" && exit 0

DIR=$(readlink -e $1)
OUTPUT="$2"
if [[ -f $OUTPUT ]] ; then
	rm $OUTPUT
fi

# === function
## add blank line
function blank_line() {
	in_file="$1"
	out_file="$2"
	while read line
	do
		echo -e "$line \n" >> $out_file
	done < $in_file
}

## analysis time
function date_format_ch() {
	analysis_date="$1"	
	YYMMDD_date=${analysis_date:0:8}
	HHMMSS_date=${analysis_date:8:6}
	HH=${HHMMSS_date:0:2}
	MM=${HHMMSS_date:2:2}
	SS=${HHMMSS_date:4:2}
	HHMMSS_ch="$HH:$MM:$SS"
	YYMMDD_ch=$(date -d $YYMMDD_date)
	echo $YYMMDD_ch | awk -v k=$HHMMSS_ch '{print $1" "$2" "$3" "k" "$5" "$6}' 
}

project_name=$(basename $DIR)
echo -e "Project_id: $project_name \n " >> $OUTPUT
echo -e "# 同步与拆分\n" >> $OUTPUT
raw_path=$(grep "^#/p299/" "$DIR/project_info.txt" | cut -d "#" -f 2)
cn500_path="/p299/raw/2016/cn500/fq/fq/"
for raw_i in $raw_path
do
	raw_dir=$(readlink -e $raw_i)
	split_dir=$(dirname $raw_dir)
	raw_name=${split_dir##*/}
	echo -e "## raw date: $raw_name \n" >> $OUTPUT

	## sync time
	echo -e "sync time\n" >> $OUTPUT
	sync_start=$(grep "^start:" ${cn500_path}${raw_name}.done| cut -d " " -f 2-)
	sync_start_s=`date -d "$sync_start" +%s`
	sync_end=$(grep "^finish:" ${cn500_path}${raw_name}.done | cut -d " " -f 2-)
	sync_end_s=`date -d "$sync_end" +%s`
	sync_long=$(awk -v k1=$sync_start_s -v k2=$sync_end_s 'BEGIN{print (k2-k1)/3600}')
	echo -e "- Start:   $sync_start \n" >> $OUTPUT
	echo -e "- Finish:  $sync_end \n" >> $OUTPUT
	echo -e "- Time:    ${sync_long}h \n" >> $OUTPUT
	sync_data=$(grep "^sent" ${cn500_path}${raw_name}.log | cut -d " " -f 2)
	sync_speed=$(grep "^sent" ${cn500_path}${raw_name}.log | cut -d " " -f 9)
	echo -e "- data_size:  $sync_data ;  speed: ${sync_speed}/s \n" >> $OUTPUT

	## split time
	echo -e "split time \n" >> $OUTPUT
	split_start=$(grep "^> START:" $split_dir/Result.log | cut -d "@" -f 2)
	split_start_s=`date -d "$split_start" +%s`
	split_end=$(grep "^> DONE" $split_dir/Result.log | cut -d "@" -f 2)
	split_end_s=`date -d "$split_end" +%s`
	split_long=$(awk -v k1=$split_start_s -v k2=$split_end_s 'BEGIN{print (k2-k1)/3600}')
	echo -e "- Start:   $split_start \n" >> $OUTPUT
	echo -e "- Finish:  $split_end \n" >> $OUTPUT
	echo -e "- Time:    ${split_long}h \n" >> $OUTPUT

	## split data
	echo -e "split data \n" >> $OUTPUT
	unmatched=$(grep "^#unmatched" $split_dir/Result.txt | cut -f 1,3 | cut -d "#" -f 2)
	echo -e "- $unmatched Mb \n" >> $OUTPUT
	matched=$(grep "^#matched" $split_dir/Result.txt | cut -f 1,3 | cut -d "#" -f 2)
	echo -e "- $matched Mb \n" >> $OUTPUT
	total=$(grep "^#total" $split_dir/Result.txt | cut -f 1,3 | cut -d "#" -f 2)
	echo -e "- $total Mb \n" >> $OUTPUT
	low_data_n=$(grep "K CA-PM" $split_dir/file_size_human.log | wc -l )
	echo -e "- low_data samples	$low_data_n \n" >> $OUTPUT
	tem_date=$(date "+%Y%m%d_%H%M%S")
	grep "K CA-PM" $split_dir/file_size_human.log > ${OUTPUT}.$tem_date
	blank_line ${OUTPUT}.$tem_date $OUTPUT
	rm ${OUTPUT}.$tem_date
done
echo "" >> $OUTPUT


echo -e "# 分析\n" >> $OUTPUT
echo -e "## analysis time \n" >> $OUTPUT
run_id=1
snakejob_log=$(ls $DIR | grep "^snakejob.*.log")
if [[ -n $snakejob_log ]]; then
	for i in $DIR/snakejob.*.log
	do
		echo $i
		log_time=$(basename $i | cut -d "." -f 2)
		echo -e "- Round $run_id: `date_format_ch $log_time` \n" >> $OUTPUT
		if [[ $run_id -eq 1 ]]; then
			analysis_round1=`date_format_ch $log_time`
			analysis_round1_s=`date -d "$analysis_round1" +%s`
		fi
		#echo $log_time | awk -v k=$run_id '{print "> Round "k": "$1" "$2" "$3" "$4" CST "$5}' >> $OUTPUT
		run_id=$[$run_id+1]
	done
fi
#analysis_start=$(grep "^#START" $DIR/project.done | cut -d " " -f 2 | cut -d "@" -f 2)
last_start_time=$(ls $DIR/snakejob/ | grep "^snakejob.*.log" | tail -n 1)
if [[ -n $last_start_time ]]; then
    analysis_start=$(basename $last_start_time | cut -d "." -f 2)
    echo -e "- Round $run_id: `date_format_ch $analysis_start` \n" >> $OUTPUT
    if [[ $run_id -eq 1 ]]; then
	    analysis_round1=`date_format_ch $analysis_start`
	    analysis_round1_s=`date -d "$analysis_round1" +%s`
    fi
fi
analysis_end=$(grep "^#finish" $DIR/project.done | cut -d " " -f 2 | cut -d "@" -f 2)
analysis_finish=`date_format_ch $analysis_end`
analysis_finish_s=`date -d "$analysis_finish" +%s`
analysis_long=$(awk -v k1=$analysis_round1_s -v k2=$analysis_finish_s 'BEGIN{print (k2-k1)/3600}')
echo -e "- Finish:  `date_format_ch $analysis_end` \n" >> $OUTPUT
echo -e "- Time:    ${analysis_long}h \n" >> $OUTPUT   
echo " " >> $OUTPUT

## qc
reject_sample=$(grep "^> filtered samples strict" $DIR/qc/qc_summary_check.log | cut -d ":" -f 2)
reject_sample_loose=$(grep "^> filtered samples loose" $DIR/qc/qc_summary_check.log | cut -d ":" -f 2)
all_sample_list=$(grep -v "#" $DIR/qc/qc_summary_brief.txt | cut -f 1 )
echo -e "## pass samples: \n" >> $OUTPUT
for s in $all_sample_list
do
	if [[ ${reject_sample[@]} =~ $s ]];then
		continue	
	else
		echo -e "$s \n" >> $OUTPUT
	fi
done

echo -e "## reject samples: \n" >> $OUTPUT
for s_reject in $reject_sample
do
	echo -e "- $s_reject \n" >> $OUTPUT
	tem_date=$(date "+%Y%m%d_%H%M%S")
	grep "^>> reject: $s_reject" $DIR/qc/qc_summary_check.log | cut -d ":" -f 2 > ${OUTPUT}.$tem_date
	blank_line ${OUTPUT}.$tem_date $OUTPUT
	rm ${OUTPUT}.$tem_date
done

echo -e "## reject samples (loose): \n" >> $OUTPUT
for s_reject_loose in $reject_sample_loose
do
	echo -e "- $s_reject_loose \n" >> $OUTPUT
	tem_date=$(date "+%Y%m%d_%H%M%S")
	grep "^>> reject loose: $s_reject_loose" $DIR/qc/qc_summary_check.log | cut -d ":" -f 2 > ${OUTPUT}.$tem_date
	blank_line ${OUTPUT}.$tem_date $OUTPUT
	rm ${OUTPUT}.$tem_date
done










