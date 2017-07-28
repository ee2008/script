# @szj^17Dec10

[[ $# -eq 0 ]] && echo "sh $0  <OUT_file> [project_id | latest] " && exit 0


#IN="/p299/project/og04/shenzhongji2/CA-PM"
IN="/p299/user/og04/ogsmor/CA-PM"  #update at 2017June15
OUT_file="$1"
OUT_dir=$(/bin/readlink -e $(dirname $OUT_file))
OUT=$OUT_dir/$(basename $OUT_file)
echo "> START $0 @$(date)"
echo "IN: $IN"
echo "OUT: $OUT"


[[ ! -d $(dirname $OUT) ]] && mkdir -pv $(dirname $OUT)
[[ -f $OUT ]] && rm -vf $OUT && touch $OUT
cd $IN
latest_project=$(ls | grep "^CA-PM-" | sort -r)
if [[ $# -eq 2 ]]; then
	project_id="$2"
	p_order=1
	for p_id in $latest_project;do
		if [[ $p_id == $project_id ]]; then
			latest_project=$(echo $latest_project | cut -d " " -f ${p_order}-)
			break
		else
			p_order=$[$p_order+1]
		fi
	done
fi
limit_p=0
for p in $latest_project;do
	if [[ ! -e ${p}/project.done ]];then
		continue
	else
		limit_p=$limit_p+1
	fi
	if [[ $limit_p -gt 5 ]]; then
		break
	fi
	for i in ${p}/align/*.splitters.bam; do
	    prj=${i%%/*}
	    sample=$(basename $i .splitters.bam)
	    #echo $i | grep -q 'test' || echo ${i%%/*} $(basename $i .log) >> $out
	    echo ">> prj: $prj"
		[[ "$prj" =~ 'test' ]] && continue
	    [[ "$prj" == 'CA-PM-*' ]] && continue
	    grep -w -q $sample $OUT
	    if [[ $? -eq 0 ]]; then
	        echo "exists: $sample in $(grep -w $sample $OUT)"
	        if [[ $prj =~ 'P2' ]]; then
	            echo "dup: $sample in $prj"
	            grep -v $sample $OUT > $OUT.tmp
	            rm $OUT
	            mv $OUT.tmp $OUT
	        fi
	    fi
	    echo $prj $sample >> $OUT
	done
done

echo "> DONE $0 @$(date)"
