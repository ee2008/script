#!/bin/bash

DIR_PATH="/p299/project/og04/shenzhongji2/CA-PM/"
while read line
do
	DIR=$(echo $line | /bin/cut -d " " -f 1)
	SAMPLE=$(echo $line | /bin/cut -d " " -f 2)
	FILE="/p299/user/og04/wangxian/GC_percent_test/GC_output/${DIR}/${SAMPLE}.gc_content.txt"
	if [ ! -s $FILE ]; then
		echo "/nfs2/pipe/Re/Software/miniconda/bin/perl /lustre/project/og04/wangxian/pipeline_script/GC_percent/scripts/GC_count_panel.pl ${DIR} ${DIR_PATH}${DIR}/qc/align/${SAMPLE}.itools_depth.gz /p299/user/og04/wangxian/GC_percent_test/GC_output/${DIR}" > /p299/user/og04/wangxian/GC_percent_test/GC_output/${DIR}_${SAMPLE}.sh
		/opt/gridengine/bin/linux-x64/qsub -cwd -S /bin/bash -m abes -l vf=2G,p=1 -q dna.q,rna.q,all.q /p299/user/og04/wangxian/GC_percent_test/GC_output/${DIR}_${SAMPLE}.sh
		rm /p299/user/og04/wangxian/GC_percent_test/GC_output/${DIR}_${SAMPLE}.sh
	fi
done < "/p299/project/og04/shenzhongji2/CA-PM/all_qc_stats/project_sample_index.txt"



