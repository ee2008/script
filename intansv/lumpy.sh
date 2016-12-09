#!/bin/bash
# call SV from bam via lumpy
# @wxian^16Feb03

# === env

SPEEDSEQ="/lustre/project/og04/pub/biosoft/speedseq/bin/speedseq"
ENV_SH="/nfs2/pipe/Cancer/Bin/Flamingo/source.sh"
LUMPY="/lustre/project/og04/pub/biosoft/speedseq/bin/lumpy"
SAMTOOLS="/nfs2/pipe/Re/Software/miniconda/bin/samtools"
SAMBLASTER="/lustre/project/og04/pub/biosoft/speedseq/bin/samblaster"
SAMBAMBA="/lustre/project/og04/pub/biosoft/speedseq/bin/sambamba"
PYTHON="/nfs2/pipe/Cancer/Software/Python/Python-2.7.8/python"
pairend_distro_py="/lustre/project/og04/pub/biosoft/speedseq/bin/pairend_distro.py"
extractSplitReads_BwaMen="/lustre/project/og04/pub/biosoft/speedseq/bin/extractSplitReads_BwaMem"

# === arg
[[ $# -lt 1 ]] && echo "usage: sh $0 <bam> [out_dir|bam_dir]" && exit

# == BAM
BAM="$1"
IN_DIR_bam=$(dirname $BAM)
prefix_bam=$(basename $BAM .bam)

# == check bam index
BAI="$BAM.bai"
[[ ! -f $BAM ]] && echo "! no such bam: $BAM" && exit 1
if [[ ! -f $BAI ]]; then
        echo "!! no bam index, will generate now"
        $SAMTOOLS index $BAM
fi

# == check discordants.bam and splitters.bam
DISCORDANTS=${IN_DIR_bam}/${prefix_bam}.discordants.bam
DISCORDANTS_unsorted=${IN_DIR_bam}/${prefix_bam}.discordants.unsorted.bam
SPLITTERS=${IN_DIR_bam}/${prefix_bam}.splitters.bam
SPLITTERS_unsorted=${IN_DIR_bam}/${prefix_bam}.splitters.unsorted.bam
if [[ ! -f $DISCORDANTS ]]; then
	echo "!! no discordants.bam file, will generate now"
	$SAMTOOLS view -b -F 1294 $BAM > $DISCORDANTS_unsorted
	$SAMTOOLS sort -o $DISCORDANTS $DISCORDANTS_unsorted
fi
if [[ ! -f $SPLITTERS ]]; then
	echo "!! no splitters.bam file, will generate now"
	$SAMTOOLS view -h $BAM | $extractSplitReads_BwaMen -i stdin | $SAMTOOLS view -Sb - > $SPLITTERS_unsorted
	$SAMTOOLS sort -o $SPLITTERS $SPLITTERS_unsorted
fi

#Align the data with Speedseq
#$SPEEDSEQ align -p -R "@RG\tID:id\tSM:$prefix\tLB:lib" $FASTA $FASTQ
#DISCORDANTS=${IN_DIR_fq}/${prefix_fq}.discordants.bam
#SPLITTERS=${IN_DIR_fq}/${prefix_fq}.splitters.bam

# == output
OUT_DIR=$IN_DIR_bam
if [[ $# -eq 2 ]]; then
        OUT_DIR="$2"
        last_char=${OUT_DIR:0-1:1}
        if [[ $last_char == '/' ]]; then
                num_out_dir=$[${#OUT_DIR}-1]
                OUT_DIR=${OUT_DIR:0:$num_out_dir}
        fi
fi
OUT_file=${OUT_DIR}/${prefix_bam}.bedpe
echo ">> output file: $OUT_file"


HISTO=${OUT_DIR}/${prefix_bam}.lib.histo
MEAN_SD=${OUT_DIR}/${prefix_bam}.mean_sd
$SAMTOOLS view -r $prefix_bam $BAM | tail -n+100000 | $pairend_distro_py -r 101 -X 4 -N 10000 -o $HISTO > $MEAN_SD
MEAN_C=$(sed -n '1p' $MEAN_SD)
MEAN=${MEAN_C#*:}
STDEV_C=$(sed -n '2p' $MEAN_SD) 
STDEV=${STDEV_C#*:}
rm $MEAN_SD

echo "> START $0 "`date`
echo ">> bam: $BAM"
echo ">> discordants file: $DISCORDANTS"
echo ">> splitters file: $SPLITTERS"

# == LUMPY
$LUMPY -b -mw 4 -tt 0 -pe id:$prefix_bam,bam_file:$DISCORDANTS,histo_file:$HISTO,mean:$MEAN,stdev:$STDEV,read_length:101,min_non_overlap:101,discordant_z:5,back_distance:10,weight:1,min_mapping_threshold:20 -sr id:$prefix_bam,bam_file:$SPLITTERS,back_distance:10,weight:1,min_mapping_threshold:20 > $OUT_file

echo "> DONE $0"`date`
