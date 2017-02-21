#!/bin/bash 

# plot gc_content 
# @wxian2017Feb17-20

# == need scripts
#GC_COUNT=$(dirname $0)/GC_count_panel.pl
PLOT_R="$(dirname $0)/plot_gc_depth.R"

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 [options]
	-i <gc_depth.txt>
	-o <out_dir> 
	-c [gc/depth |all]
	-ng [gc_output_name | CA-PM.gc_content.png] 
	-nd [depth_output_name | CA-PM.depth.png] 
	-b [batch1,batch2..batch10| all] 
	-t [CFD/LEUD/.. | all]  
	-f [boxplot/scatter |all]
EOF
exit 0
fi

CONTENT="all"
BATCH="all"
TYPE=""
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
		-i) INPUT="$2"
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

echo "> INPUT: $INPUT"

## processing batch
tem_date=$(date "+%Y%m%d_%H%M%S")
GC_COUNT="$OUT_dir/CA-PM.gc_depth_${tem_date}.txt"
if [[ $BATCH != "all" ]]; then
	BATCH=${BATCH//,/ }
	for i in $BATCH
	do
		if [[ $i =~ \.\. ]]; then
			START=$(echo $i | cut -d "." -f 1 |cut -d "_" -f 1)	
			END=$(echo $i | cut -d "." -f 3 | cut -d "_" -f 1)
			if [[ -z $END ]]; then
				END=$(tail -n 1 $INPUT  | cut -f 1)	
			fi
			START_LINE=$(grep -n "$START" $INPUT | cut -d ":" -f 1 | head -n 1)
			END_LINE=$(grep -n "$END" $INPUT | cut -d ":" -f 1 | tail -n 1)
			sed -n $START_LINE,${END_LINE}p $INPUT | grep "$TYPE"  >> $GC_COUNT
		else 
			grep "$i" $INPUT | grep "$TYPE" >> $GC_COUNT
		fi
	done
else
	GC_COUNT=$INPUT	
fi

# == plot 
echo "> PLOTTING  @$(date)"
$PLOT_R $GC_COUNT $OUT_dir $NAME_GC $NAME_DEPTH $IMAGE $CONTENT

if [[ $BATCH != "all" ]]; then
	rm $GC_COUNT
fi

echo "> DONE  @$(date)"














