#!/bin/bash

# @wxian2017Jan20
# separate .bed into small part for saving compute time




l=1
p=50
for i in {1..21}
do
	echo "sed -n '$l,${p}p' /lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/designed_panel12_sort_uniq.bed > /lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/panel_gc_percent/designed_panel12_sort_uniq${i}.bed" >> /lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/panel_gc_percent/sub.${i}.sh
	echo "sh /lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/panel_standard_gc_percent.sh /lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/panel_gc_percent/designed_panel12_sort_uniq${i}.bed /lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/panel_gc_percent/panel_gc_percent${i}.txt" >> /lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/panel_gc_percent/sub.${i}.sh
	qsub -cwd -S /bin/bash -m abes -l vf=2G,p=1 -q dna.q,rna.q,all.q /lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/panel_gc_percent/sub.${i}.sh
	l=$[$l+50]
	p=$[$p+50]
done















