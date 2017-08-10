#!/bin/bash
# @wxian2017AUG09


[[ $# -eq 0 ]] && echo "Usage: sh $0 <panel_info> <panel_bed> <out_dir>" && exit 0

panel_info="$1"
panel_bed="$2"
out_dir="$3"
[[ ! -d $out_dir ]] && mkdir -pv $out_dir

#panel_info="/lustre/project/og04/wangxian/1705wxVisual/panel_discribe/ref/panel_info.txt"

CSVCUT="/nfs2/pipe/Re/Software/miniconda/bin/csvcut"
CSVF="/nfs2/pipe/Re/Software/miniconda/bin/csvformat"
gff3_scr="$(dirname $0)/filter_gff3.py"


### step 1: transform panel_info to vcf
VCF="${out_dir}/panel_info_target.vcf"
[[ -e $VCF ]] && rm $VCF


$CSVCUT -t -c "#chr,end,mut_type,ref,alt" $panel_info | $CSVF -T | sed -n '2,$p' | awk -F "\t" '{if (($3 == "snp") || ($3 == "indel")) print $1"\t"$2"\t.\t"$4"\t"$5"\t"$3}' >> ${VCF}_tem

while read line
do
	CHR=$(echo $line | cut -d " " -f 1)
	END=$(echo $line | cut -d " " -f 2)
	MUT_TYPE=$(echo $line | cut -d " " -f 6)
	REF=$(echo $line | cut -d " " -f 4)
	ALT=$(echo $line | cut -d " " -f 5)
	if [[ $ALT == */* ]];then
		ALTS=${ALT//// }
		for i in $ALTS
		do
			echo -e "$CHR	$END	.	$REF	$i	$MUT_TYPE" >> $VCF
		done
	else 
		echo -e "$CHR	$END	.	$REF	$ALT	$MUT_TYPE" >> $VCF
	fi
done < ${VCF}_tem
rm ${VCF}_tem


### step 2: transvar vcf
/p299/user/og04/ogsmor/Smor/software/bin/transvar ganno --vcf $VCF --ensembl --longest > $out_dir/panel_info_transvar.txt
rm $VCF

### step 3: filter gff3 with transcript
/lustre/project/og04/wangxian/anaconda3/bin/python $gff3_scr  $out_dir/panel_info_transvar.txt $out_dir/gff3_all.txt
rm $out_dir/panel_info_transvar.txt


### step 4: filter gff3 with panel.bed
/nfs2/biosoft/bin/bedtools intersect -a $out_dir/gff3_all.txt  -b $panel_bed  -wa > $out_dir/gff3_tem.txt
rm $out_dir/gff3_all.txt
echo -e "#CHR	START	END	GENE	TRANSCRIPT	EXON" > $out_dir/gff3_final.tsv_
sort $out_dir/gff3_tem.txt | uniq | sort -V -k 1 >> $out_dir/gff3_final.tsv_
rm $out_dir/gff3_tem.txt


### step 5: intersection of gff3 and panel_info/panel.bed
echo -e "CHR	START	END	GENE	TRANSCRIPT	EXON	chr	start	end" > $out_dir/panel_bed_final.tsv
/nfs2/biosoft/bin/bedtools intersect -a $out_dir/gff3_final.tsv_ -b $panel_bed -wa -wb >> $out_dir/panel_bed_final.tsv

echo -e "CHR	START	END	GENE	TRANSCRIPT	EXON	chr	start	end	source	mut_type	gene	ref	alt	c_anno	p_anno	mut_info	exon_anno	panel" > $out_dir/panel_info_final.tsv
/nfs2/biosoft/bin/bedtools intersect -a $out_dir/gff3_final.tsv_ -b $panel_info -wa -wb >> $out_dir/panel_info_final.tsv



echo -e "CHR	START	END	GENE	TRANSCRIPT	EXON" > $out_dir/gff3_final.tsv
sed -n '2,$p' $out_dir/gff3_final.tsv_ >> $out_dir/gff3_final.tsv
rm $out_dir/gff3_final.tsv_


