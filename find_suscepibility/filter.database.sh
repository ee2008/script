#!/bin/bash

# seal the script:filter.database.pl 
# @wxian20160822

[[ $# -eq 0 ]] && echo "Usage: sh $0 <anno_dir/sample.var/sv> <out_dir>" && exit 0

echo ">> START @$(date)"

perl_scr="$(dirname $0)/filter.database.pl"

in=$1
out=$2
[[ ! -d $out ]] && mkdir -pv $out

annovar=${in}*.annovar.hg19_multianno.txt
annodb=${in}*.annodb.genome_summary.xls
oncotator=${in}*.oncotator.tsv
sample=${in##*/}
out_file=${out}/$sample.suscepibility_gene.txt
out_file_n=${out}/$sample.suscepibility_new_gene.txt

# == cut the oncotator.tsv
#code=$(chardetect $oncotator | cut -d " " -f 2)
#grep -v "^#" $oncotator | /nfs2/pipe/Re/Software/bin/csvcut -t -e BIG5 -c genome_change,"HGNC_OMIM ID(supplied by NCBI)",CGC_GeneID | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.oncotator.tsv 

onco1=$(sed -n '4p' $oncotator | awk  -F "\t" '{for(i=1;i<=NF;i++) {if($i=="genome_change") {print i} }}')
onco2=$(sed -n '4p' $oncotator | awk  -F "\t" '{for(i=1;i<=NF;i++) {if($i=="HGNC_OMIM ID(supplied by NCBI)") {print i} }}')
onco3=$(sed -n '4p' $oncotator | awk  -F "\t" '{for(i=1;i<=NF;i++) {if($i=="CGC_GeneID") {print i} }}')


grep -v "^#" $oncotator | cut -f $onco1,$onco2,$onco3 > $out/${sample}.simply.oncotator.tsv 

# == cut the annodb.genome_summary.xls
/nfs2/pipe/Re/Software/bin/csvcut -t -c Func,Gene,"Exonic|Biotype",Chr,Start $annodb | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/${sample}.simply.annodb.xls

# == cut the annovar file
/nfs2/pipe/Re/Software/bin/csvcut -t -c Chr,Start,End,Ref,Alt,Func.ensGene,Gene.ensGene,GeneDetail.ensGene,avsnp144,SIFT_score,SIFT_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,MutationTaster_score,MutationTaster_pred,CADD_raw,CADD_phred,COSMIC_ID,1000G_EAS,ESP6500siv2_ALL,cg46,cg69,clinvar_20150629,cosmic70 $annovar | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/${sample}.simply_database.annovar.txt

otherinfo=$(head -n 1 $annovar | awk  -F "\t" '{for(i=1;i<=NF;i++) {if($i=="Otherinfo") {print i} }}')
depth=$[$otherinfo+2]
cut -f $depth $annovar | sed '1c depth' > $out/${sample}.simply_depth.annovar.txt
paste $out/${sample}.simply_database.annovar.txt $out/${sample}.simply_depth.annovar.txt > $out/${sample}.simply.annovar.txt
rm $out/${sample}.simply_database.annovar.txt $out/${sample}.simply_depth.annovar.txt

#filter the database
/nfs2/pipe/Re/Software/miniconda/bin/perl $perl_scr $out/${sample}.simply.annovar.txt $out/${sample}.simply.annodb.xls $out/${sample}.simply.oncotator.tsv $out_file $out_file_n

rm $out/${sample}.simply.annovar.txt $out/${sample}.simply.annodb.xls $out/${sample}.simply.oncotator.tsv

echo ">> DONE @$(date)"
