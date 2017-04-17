#!/bin/bash

# main for qc_stats
# 1. generate project sample index
# 2. summary all analysis sample qc stats
# 3. generate HTML report
# @szj^16Dec12
# @wxian2017Mar24


# ==== env
export PATH='/nfs/pipe/Re/Software/bin':$PATH
RSCRIPT='/nfs/pipe/Re/Software/bin/Rscript'
CSVSTAT='/nfs/pipe/Re/Software/bin/csvstat'

# ==== args
# project dir and optional output path
[[ $# -eq 0 ]] && echo "Usage: sh $0 <out_dir> [project_id | latest] " && exit 0
#project_dir="$1"
OUTDIR="$1"
[[ ! -d $OUTDIR ]] && mkdir -pv $OUTDIR
OUTDIR=$(readlink -e "$1")
if [[ $# -eq 2 ]] ;then
	project_id="$2"
else 
	project_id=" "
fi


WD=$(dirname $(readlink -e $0))
DIR='/p299/project/og04/shenzhongji2/CA-PM'
echo "OUTDIR: $OUTDIR"
GEN_INDEX=$WD/project_sample_index.sh
INDEX=$OUTDIR/project_sample_index.txt

# ==== 1
echo "sh $WD/project_sample_index.sh $INDEX $project_id"
sh $WD/project_sample_index.sh $INDEX $project_id
latest=$(head -n 1 $INDEX | cut -d ' ' -f 1)

# ==== 2
echo "> START summary all qc stats @$(date)"
if [[ -f $OUTDIR/all_qc_stats.tsv ]]; then
    rm -vf $OUTDIR/all_qc_stats.tsv
    [[ $? -ne 0 ]] && echo "! fail to overwrite: $OUTDIR/all_qc_stats.tsv" && exit 1
fi
while read line; do
    prj=$(echo $line | cut -d ' ' -f1)
    sample=$(echo $line | cut -d ' ' -f2)
    echo ">> proccessing on: $prj : $sample"

    qc=$(grep $sample $DIR/$prj/qc/qc_summary_brief.txt)

    # adapt to previous result without mut_dep
    grep -q 'mut_dep$' $DIR/$prj/qc/qc_summary_brief.txt
    if [[ $? -ne 0 ]]; then

        #mut=$DIR/$prj/output/$sample.var.panel.tsv
        mut_normal=$DIR/$prj/output/$sample.var.panel.tsv
        mut_tumor=$(find $DIR/$prj/output -name "*-VS-$sample.svar.panel.tsv")
        [[ -f $mut_tumor && $(wc -l $mut_tumor | cut -d ' ' -f 1) -ne 1 ]] && mut=$mut_tumor || mut=$mut_normal
        echo ">>> use mut result file: $mut"
        mut_dep='NA'
        if [[ -f $mut && $(wc -l $mut | cut -d ' ' -f 1) -ne 1 ]]; then
            mut_dep=$($CSVSTAT -t -c 'DP' $mut | grep 'Mean' | sed 's/\,//g' | cut -d ':' -f 2 | awk '{printf "%.f", $0}')
            #mut_dep0=$($CSVSTAT -c 'DP' $DIR/$prj/output/$sample.var.panel.tsv)
        fi
        #[[ ! -s $mut_dep || $mut_dep == '' ]] && mut_dep='NA'
        [[ $mut_dep == '' ]] && mut_dep='NA'
        echo ">>> mut_dep: $mut_dep"
        echo ">>> mut_count: $(wc -l $mut)"
        echo -e "$prj/$sample\t$qc\t$mut_dep" >> $OUTDIR/all_qc_stats.tsv
    else
        echo -e "$prj/$sample\t$qc" | sed 's/\-$/NA/g' >> $OUTDIR/all_qc_stats.tsv
    fi
done < $INDEX

cat $WD/all_qc_stats.header $OUTDIR/all_qc_stats.tsv | sed 's/\-$/NA/g' > $OUTDIR/${latest}_qc_stats.tsv
echo "> generated all_qc_stats: $(readlink -e $OUTDIR/${latest}_qc_stats.tsv)"

# ==== 3
echo "generating time of all process@$(date)"
echo ">> COMMAND: sh $WD/produce_log.sh $DIR/$latest $OUTDIR/${latest}_produce_log.txt"

sh $WD/produce_log.sh $DIR/$latest $OUTDIR/${latest}_produce_log.txt
echo "> generated produce_log: $(readlink -e $OUTDIR/${latest}_produce_log.txt)"

# ==== 4
echo "> generating html report @$(date)"
echo ">> COMMAND: $RSCRIPT $WD/convert_rmd.R $OUTDIR/${latest}.Rmd $OUTDIR/${latest}_qc_stats.html $OUTDIR/${latest}_qc_stats.tsv"

export LD_LIBRARY_PATH=/nfs/pipe/Re/Software/miniconda/lib:$LD_LIBRARY_PATH
#cp $WD/all_qc_stats_report.Rmd $OUTDIR/all_qc_stats_report.Rmd
head -n 20 $WD/all_qc_stats_report.Rmd > $OUTDIR/${latest}.Rmd
cat $OUTDIR/${latest}_produce_log.txt >> $OUTDIR/${latest}.Rmd
sed -n '21,$p' $WD/all_qc_stats_report.Rmd >> $OUTDIR/${latest}.Rmd

$RSCIPRT $WD/convert_rmd.R $OUTDIR/${latest}.Rmd $OUTDIR/${latest}_qc_stats.html $OUTDIR/${latest}_qc_stats.tsv
[[ $? -ne 0 ]] && echo "! fail to generate report" && exit 1

echo ">> generated report: $(readlink -e $OUTDIR/${latest}_qc_stats.html)"
rm -v $OUTDIR/all_qc_stats.tsv
#ln -s $OUTDIR/${latest}_qc_stats.tsv $OUTDIR/all_qc_stats.tsv
#ln -s $OUTDIR/${latest}_qc_stats.html $OUTDIR/all_qc_stats.html

#if [[ ! -z $OUT_report ]]; then
#    cp -v $OUTDIR/${latest}_qc_stats.html $OUT_report
#    echo "> OUTPUT to: $OUT_report"
#fi
echo "> DONE $0 @$(date)"
# sh /p299/user/og04/shenzhongji/dev_tumor_ref/all_stat.sh > all_stat.txt
# sed 's/\ /\t/g' all_stat.txt > all_stat.tsv_
# head -1 all_stat.tsv > all_stat.header
# cat all_stat.header all_stat.tsv_ >all_stat.tsv
# rm all_stat.header all_stat.tsv_ all_stat.txt
