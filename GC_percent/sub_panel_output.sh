#!/bin/bash


for i in {1..1033}
do
	while read line
	do
		DIR=$(echo $line | /bin/cut -d " " -f 1)
		SAMPLE=$(echo $line | /bin/cut -d " " -f 2)
		FILE=/lustre/project/og04/wangxian/pipeline_script/GC/GC_output/${DIR}/${SAMPLE}.gc_content.txt
#		if [ ! -s $FILE ]; then
		echo "grep -P \"\t${i}$\" $FILE >> /lustre/project/og04/wangxian/pipeline_script/GC/panel_output/panel_${i}.txt" >> /lustre/project/og04/wangxian/pipeline_script/GC/panel_output/sub.panel${i}.sh
#		fi
	done < "/p299/project/og04/shenzhongji2/CA-PM/all_qc_stats/project_sample_index.txt"
	qsub -cwd -S /bin/bash -m abes -l vf=2G,p=1 -q dna.q,rna.q,all.q /lustre/project/og04/wangxian/pipeline_script/GC/panel_output/sub.panel${i}.sh
	rm /lustre/project/og04/wangxian/pipeline_script/GC/panel_output/sub.panel${i}.sh
done











