#!/bin/bash

[[ $# -eq 0 ]] && echo "Usage: sh $0 <project_dir> <sample_name> <out_dir>" && exit 0

IN_dir="$1"
sample_name="$2"
OUT_dir="$3"
perl_scr="$(dirname $0)/QC_plot_data.pl"
R_scr="$(dirname $0)/QC_plot.R"

echo "> START $0 @$(date)"

#get the base content data and output file
base_r1=$IN_dir/qc/raw/${sample_name}_R1_fqstat.txt
base_r2=$IN_dir/qc/raw/${sample_name}_R2_fqstat.txt
out_base=$OUT_dir/${sample_name}_fqstat.txt

# unzip the quality data and defind output file
unzip -d $OUT_dir $IN_dir/qc/raw/${sample_name}_R1_fastqc.zip
unzip -d $OUT_dir $IN_dir/qc/raw/${sample_name}_R2_fastqc.zip
quality_r1=$OUT_dir/${sample_name}_R1_fastqc/fastqc_data.txt
quality_r2=$OUT_dir/${sample_name}_R2_fastqc/fastqc_data.txt
out_quality=$OUT_dir/${sample_name}_fastqc.txt

# get the depth data
depth_data=$IN_dir/qc/panel/${sample_name}.samtools_depth_bed.txt
t_base=$(wc -l $depth_data | cut -d " " -f 1)
out_depth=$OUT_dir/${sample_name}_depth.txt

# get the depth and coverage data from every chromosome
chr_data=$IN_dir/qc/align/${sample_name}.itools_stat.txt
out_chr=$OUT_dir/${sample_name}_chr.txt
echo -e "Chr\tDepth\tCov" > $out_chr
sed -n '2,25p' $chr_data | awk '{print $1"\t"$2"\t"$3}' >> $out_chr

#prepare data for plot
/nfs2/pipe/Re/Software/miniconda/bin/perl $perl_scr $base_r1 $base_r2 $out_base $quality_r1 $quality_r2 $out_quality $depth_data $out_depth $t_base 
rm -r $OUT_dir/${sample_name}_R1_fastqc $OUT_dir/${sample_name}_R2_fastqc

# plot in Rscript
/nfs2/pipe/Re/Software/miniconda/bin/Rscript $R_scr $out_base $out_quality $out_depth $out_chr $sample_name $OUT_dir 
rm $out_base $out_quality $out_depth $out_chr

echo "> DONE $0 @$(date)"


