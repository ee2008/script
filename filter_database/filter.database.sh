#!/bin/bash

# seal the script:filter.database.pl 
# @wxian20160822

[[ $# -eq 0 ]] && echo "Usage: sh $0 <anno_dir/sample> <out_dir>" && exit 0

echo ">> START @$(date)"

perl_scr="$(dirname $0)/filter.database.pl"

in=$1
out=$2
[[ ! -d $out ]] && mkdir -pv $out

annovar=${in}.vcf.annovar.hg19_multianno.txt
annodb=${in}.snp.annodb.genome_summary.xls
oncotator=${in}.oncotator.tsv
sample=${in##*/}
out_file=${out}/$sample.suscepibility_gene.txt
out_file_n=${out}/$sample.suscepibility_new_gene.txt

# == cut the oncotator.tsv
grep -v "^#" $oncotator | /nfs2/pipe/Re/Software/bin/csvcut -t -e BIG5 -c genome_change,"HGNC_OMIM ID(supplied by NCBI)",CGC_GeneID | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.oncotator.tsv 

# == cut the annodb.genome_summary.xls
/nfs2/pipe/Re/Software/bin/csvcut -t -c Func,Gene,"Exonic|Biotype",Chr,Start $annodb | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.annodb.xls

# == cut the annovar file
/nfs2/pipe/Re/Software/bin/csvcut -t -c Chr,Start,End,Ref,Alt,Func.ensGene,Gene.ensGene,GeneDetail.ensGene,avsnp144,SIFT_score,SIFT_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,MutationTaster_score,MutationTaster_pred,CADD_raw,CADD_phred,COSMIC_ID,1000G_EAS,ESP6500siv2_ALL,cg46,cg69,clinvar_20150629,cosmic70 $annovar | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.annovar.txt

#filter the database
/nfs2/pipe/Re/Software/miniconda/bin/perl $perl_scr $out/simply.annovar.txt $out/simply.annodb.xls $out/simply.oncotator.tsv $out_file $out_file_n

rm $out/simply.annovar.txt $out/simply.annodb.xls $out/simply.oncotator.tsv

echo ">> DONE @$(date)"
