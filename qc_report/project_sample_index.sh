# @szj^17Dec10

[[ $# -eq 0 ]] && echo "sh $0  <OUT_file | /p299/project/og04/shenzhongji2/CA-PM/all_qc_stats/project_sample_index.txt>" && exit 0


IN="/p299/project/og04/shenzhongji2/CA-PM"
OUT=${1:-"/p299/project/og04/shenzhongji2/CA-PM/all_qc_stats/project_sample_index.txt"}
echo "> START $0 @$(date)"
echo "IN: $IN"
echo "OUT: $OUT"

[[ ! -d $(dirname $OUT) ]] && mkdir -pv $(dirname $OUT)
[[ -f $OUT ]] && rm -vf $OUT && touch $OUT
cd $IN
for i in CA-PM-*/align/*.splitters.bam; do
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

echo "> DONE $0 @$(date)"
