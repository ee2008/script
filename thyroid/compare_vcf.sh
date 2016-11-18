#!/bin/bash

# for somatic results
# from freebayes, mutect, varscan
# @szj^16May05

# ==== env
VAWK="/nfs/pipe/Re/Software/bin/python2.7 /lustre/project/og04/pub/biosoft/vawk/vawk"

# ==== arg
[[ $# -eq 0 ]] && echo 'Usage: $0 <project_dir> <sample_prefix> [out_dir|pwd/sample_prefix_snv_pos]' && exit 2
DIR="$1"
[[ ! -d $DIR ]] && echo "> not valid dir: $DIR" && exit 2
SAMPLE="$2"
OUT="$3"
[[ -z $OUT ]] && OUT=$PWD/$2_snv_pos
echo "> START $0 @$(date)"
echo -e "> DIR: $(readlink -e $DIR)\n> SAMPLE: $SAMPLE\n> OUT: $OUT\n"

# ==== candidate file
freebayes_snp=$DIR/var_speedseq/$SAMPLE.var.vcf.gz
mutect_snp=$DIR/var_mutect/$SAMPLE.snv.mutect_all.vcf
mutect_high_snp=$DIR/var_mutect/$SAMPLE.snv.mutect.vcf
varscan_snp=$DIR/var_varscan/$SAMPLE.snv.vcf
varscan_high_snp=$DIR/var_varscan/$SAMPLE.snv.filter.txt

fb_pos=$OUT/$SAMPLE.freebayes.pos
mt_pos=$OUT/$SAMPLE.mutect.pos
vs_pos=$OUT/$SAMPLE.varscan.pos
mt_high_pos=$OUT/$SAMPLE.mutect.high.pos
vs_high_pos=$OUT/$SAMPLE.varscan.high.pos

# ==== extract pos
[[ ! -d $OUT ]] && mkdir -pv $OUT
[[ ! -f $fb_pos ]] && zcat $freebayes_snp | $VAWK '{if (I$TYPE == "snp") print $1, $2}' | sort > $fb_pos &  # to filter snp out
[[ ! -f $fb_pos.detail ]] && zcat $freebayes_snp | $VAWK '{if (I$TYPE == "snp") print $1, $2, $4, $5}' | sort > $fb_pos.detail &  # to filter snp out
[[ ! -f $mt_pos ]] && cat $mutect_snp | $VAWK '{print $1, $2}' | sort > $mt_pos &
[[ ! -f $mt_pos.detail ]] && cat $mutect_snp | $VAWK '{print $1, $2, $4, $5}' | sort > $mt_pos.detail &
[[ ! -f $mt_high_pos ]] && cat $mutect_high_snp | $VAWK '{print $1, $2}' | sort > $mt_high_pos &
[[ ! -f $mt_high_pos.detail ]] && cat $mutect_high_snp | $VAWK '{print $1, $2, $4, $5}' | sort > $mt_high_pos.detail &
[[ ! -f $vs_pos ]] && cat $varscan_snp | $VAWK '{print $1, $2}' | sort > $vs_pos &
[[ ! -f $vs_pos.detail ]] && cat $varscan_snp | $VAWK '{print $1, $2, $4, $5}' | sort > $vs_pos.detail &
[[ ! -f $vs_high_pos ]] && cat $varscan_high_snp | tail -n +2 | $VAWK '{print $1, $2}' | sort > $vs_high_pos &
[[ ! -f $vs_high_pos.detail ]] && cat $varscan_high_snp | tail -n +2 | $VAWK '{print $1, $2, $3, $4}' | sort > $vs_high_pos.detail &
wait

# ==== inter pos
inter_pos="$OUT/$SAMPLE.inter.pos"
if [[ ! -f $inter_pos ]]; then
    comm -12 $fb_pos $mt_pos > $inter_pos.tmp
    comm -12 $inter_pos.tmp $vs_pos > $inter_pos.tmp2
    grep -v '^GL' $inter_pos.tmp2 | sort -k1 -V > $inter_pos
    rm $inter_pos.tmp $inter_pos.tmp2
    cat $fb_pos $mt_pos $vs_pos | sort -k1 -V | uniq > $OUT/$SAMPLE.union.pos
fi

inter_high_pos="$OUT/$SAMPLE.inter.high.pos"
if [[ ! -f $inter_high_pos ]]; then
    comm -12 $fb_pos $mt_high_pos > $OUT/tmp.inter.pos
    comm -12 $OUT/tmp.inter.pos $vs_high_pos > $inter_high_pos.tmp
    grep -v '^GL' $inter_high_pos.tmp | sort -k1 -V > $inter_high_pos
    rm $OUT/tmp.inter.pos $inter_high_pos.tmp
    cat $mt_high_pos $vs_high_pos | sort -k1 -V | uniq > $OUT/$SAMPLE.union.high.pos
fi

inter_pos_detail="$OUT/$SAMPLE.inter.pos.detail"
if [[ ! -f "$inter_pos_detail" ]]; then
    comm -12 $fb_pos.detail $mt_pos.detail > $OUT/tmp.inter.pos.detail
    comm -12 $OUT/tmp.inter.pos.detail $vs_pos.detail > $inter_pos_detail.tmp
    grep -v '^GL' $inter_pos.detail.tmp | sort -k1 -V > $inter_pos_detail
    rm $OUT/tmp.inter.pos.detail $inter_pos_detail.tmp
    cat $fb_pos.detail $mt_pos.detail $vs_pos.detail | sort -k1 -V | uniq > $OUT/$SAMPLE.union.pos.detail
fi

inter_high_pos_detail="$OUT/$SAMPLE.inter.high.pos.detail"
if [[ ! -f $inter_high_pos_detail ]]; then
    comm -12 $fb_pos.detail $mt_high_pos.detail > $OUT/tmp.inter.high.pos.detail
    comm -12 $OUT/tmp.inter.high.pos.detail $vs_high_pos.detail > $inter_high_pos_detail.tmp
    grep -v '^GL' $inter_high_pos.detail.tmp | sort -k1 -V > $inter_high_pos_detail
    rm $OUT/tmp.inter.high.pos.detail $inter_high_pos_detail.tmp
    #cat $fb_pos.detail $mt_high_pos.detail $vs_high_pos.detail | sort -k1 -V | uniq > $OUT/$SAMPLE.union.high.pos.detail
fi

# == stats
stats=$OUT/$SAMPLE.stats
if [[ ! -f $stats ]]; then
[[ -f $stats ]] && mv $stats $stats.bkp
for i in $OUT/$SAMPLE.*.pos*; do
    line=$(wc -l $i | awk '{print $1}')
    echo -e "$(basename $i)\t$line" >> $stats.tmp
done
sort -k2n $stats.tmp > $stats
rm $stats.tmp
fi

# ==== finish
echo "> DONE $0 @$(date)"
