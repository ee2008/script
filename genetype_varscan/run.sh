#!/bin/bash

sample_sheet="/p299/project/og04/shenzhongji2/CA-PM/all_qc_stats/project_sample_index.txt"
scr="/lustre/project/og04/wangxian/pipeline_script/genetype_varscan/supply_alt.pl"

[[ $# -eq 0 ]] && echo "Usage: sh $0 <sample.mpileup> <out_dir>" && exit 0

FILE="$1"
OUT_dir="$2"
if [[ ! -d $OUT_dir ]]; then
	mkdir -pv $OUT_dir
fi

PANEL1="/lustre/project/og04/pub/database/panel_ca_pm/panel1.bed.info"

OUT_cns=$OUT_dir/$(basename $FILE)_genotype.cns.txt
OUT_vcf=$OUT_dir/$(basename $FILE)_genotype.cns.vcf

export PATH=/nfs2/pipe/Re/Software/miniconda/bin:$PATH
cat $FILE | /nfs2/pipe/Re/Software/miniconda/bin/varscan pileup2cns - --min-coverage 2 --min-reads2 2 --min-avg-qual 15 --min-var-freq 0.001 --p-value 0.99 > $OUT_cns

perl $scr $OUT_cns $OUT_vcf
 

OUT_panel=$OUT_dir/$(basename $FILE)_genotype.panel.vcf
OUT_transvar=$OUT_dir/$(basename $FILE)_genotype.transvar.vcf

/nfs2/biosoft/bin/bedtools intersect -a $OUT_vcf -b $PANEL1 | uniq > $OUT_panel


/nfs/pipe/Re/Software/bin/transvar ganno --vcf $OUT_panel --ensembl --longest > $OUT_transvar


#/nfs2/pipe/Re/Software/bin/transvar ganno -i \'chr$chr:g.${start}\' --ensembl   > $tem_out



#OUTPUT=$(basename $FILE).txt
#	sh /lustre/project/og04/wangxian/tem_script/check_po/filter.sh $OUT $OUTPUT 









