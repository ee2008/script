DIR="/p299/user/og04/ogsmor/CA-PM/CA-PM-20170627_gDNA_sub_p1p4/qc/align"

cd $DIR
tt=$(ls *.samtools_stat.txt)
cd -
for i in $tt
do
    sh insert_size.sh $DIR/$i /lustre/project/og04/wangxian/pipeline_script/insert_size/CA-PM-20170627_gDNA_p1p4
done




