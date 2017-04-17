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
	-a <panel.bed>: Format[chr start end standard_gc(%)];sorted by chr start
	-c <panel.bed>: Format[chr start end];sorted by chr start 
	-fa [in.fa | /lustre/project/og04/pub/database/human_genome_hg19/noGL/human_g1k_v37_noGL.fasta]
	-n [output_name | CA-PM.gc_depth.png] 
	-b [batch1,batch2..batch10 | all] 
	-t [CFD/LEUD/.. | all]  
	-f [boxplot/violin/scatter | violin+scatter]
	-ab [1/2/3 | 1]: 1: only plot gc and depth distribution; 2: only export abnormal result; 3: both 1 & 2 
EOF
exit 0
fi

BATCH="all"
TYPE=""
IMAGE="all"
NAME="CA-PM.gc_depth.png"
FA="/lustre/project/og04/pub/database/human_genome_hg19/noGL/human_g1k_v37_noGL.fasta"
AB=1

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-o) OUT_dir="$2"
			[[ ! -d $OUT_dir ]] && mkdir -pv $OUT_dir
			shift; ;;
		-a) BED="$2"
			gc=1
			shift; ;;
		-c) BED="$2"
			gc=0
			shift; ;;
		-fa) FA="$2"
			 shift; ;;	
		-n) NAME="$2"
			shift; ;;
		-i) INPUT="$2"
			shift; ;;
		-b) BATCH="$2"
			shift; ;;
		-t) TYPE="$2"
			shift; ;;
		-f) IMAGE="$2"
			shift; ;;
		-ab) AB="$2"
			shift; ;;
	esac
	shift
done

echo "> START  @$(date)"

echo "> INPUT: $INPUT"
echo "> TYPE: $TYPE"

## processing batch
tem_date=$(date "+%Y%m%d_%H%M%S")
GC_COUNT="$OUT_dir/CA-PM.gc_depth_${tem_date}.txt"
if [[ $BATCH != "all" ]] ; then
	BATCH=${BATCH//,/ }
	for i in $BATCH
	do
		if [[ $i =~ \.\. ]]; then
			START=$(echo $i | cut -d "." -f 1 |cut -d "_" -f 1)	
			START_LINE=$(grep -n "$START" $INPUT | cut -d ":" -f 1 | head -n 1)
			END=$(echo $i | cut -d "." -f 3 | cut -d "_" -f 1)
			if [[ -z $END ]]; then
				#END=$(tail -n 1 $INPUT  | cut -f 1)	
				sed -n $START_LINE,\$p $INPUT | grep "$TYPE"  >> $GC_COUNT
			else
				END_LINE=$(grep -n "$END" $INPUT | cut -d ":" -f 1 | tail -n 1) 
				sed -n $START_LINE,${END_LINE}p $INPUT | grep "$TYPE"  >> $GC_COUNT
			fi
		else 
			grep "$i" $INPUT | grep "$TYPE" >> $GC_COUNT
		fi
	done
elif [[ $TYPE != "" ]]; then
	grep "$TYPE" $INPUT >> $GC_COUNT
else
	GC_COUNT=$INPUT	
fi


## processing panel.bed
if [[ $gc != 1 ]]; then
	echo "> COOMPUTING gc_content  @$(date)"
	BED_base="$OUT_dir/bed_base.txt"
	BED_GC="$OUT_dir/panel_bed_gc_content.txt"
	[[ -e $BED_GC ]] && rm $BED_GC
	/nfs2/biosoft/bin/itools Fatools extract -InPut $FA -OutPut $BED_base -MRegion $BED
	gunzip -c ${BED_base}.gz > $BED_base
	while read line
	do
		if [[ ${line:0:1} == ">" ]]; then
			CHR_=${line%%_*}
			CHR=${CHR_#*>}
			RANGE=${line#*_}
			START=${RANGE%%_*}
			END=${RANGE#*_}
			LENGTH=$[$END-$START+1]
			BASE=""
			continue
		fi
		BASE=${BASE}$line
		LENGTH_BASE=$(echo $BASE | wc -L)
		if [[ $LENGTH -eq $LENGTH_BASE ]]; then
			BASE=${BASE//G/}
			BASE=${BASE//C/}
			AT_content=$(echo $BASE | wc -L)
			GC_content=$[$LENGTH_BASE-$AT_content]
			GC_percent=$(awk 'BEGIN{printf "%.4f\n",('$GC_content'/'$LENGTH_BASE')*100}')
			echo -e "$CHR   $START  $END    $GC_percent" >> $BED_GC
		fi
	done < $BED_base
	rm $BED_base ${BED_base}.gz
	IN_BED=$BED_GC
else
	IN_BED=$BED
fi


# == plot 
echo "> PLOTTING  @$(date)"
$PLOT_R $GC_COUNT $OUT_dir $NAME $IMAGE $IN_BED $AB 

#if [[ $BATCH == "all" ]] && [[ $TYPE == "" ]]; then
#	rm $GC_COUNT
#fi

echo "> DONE  @$(date)"














