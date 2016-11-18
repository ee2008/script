#!/bin/bash

[[ $# -eq 0 ]] && echo "Usage: sh $0 <in_dir/sample> <out_dir>" && exit 0

perl_scr="$(dirname $0)/filter.database.pl"

in=$1
out=$2
annovar=${in}.vcf.annovar.hg19_multianno.txt
annodb=${in}.snp.annodb.genome_summary.xls
oncotator=${in}.oncotator.tsv
sample=${in##*/}
out_file=${out}/$sample.suscepibility_gene.txt
out_file_n=${out}/$sample.suscepibility_new_gene.txt

# == cut the annovar file
/nfs2/pipe/Re/Software/bin/csvcut -t -c Chr,Start,End,Ref,Alt,Func.ensGene,Gene.ensGene,GeneDetail.ensGene,avsnp144,SIFT_score,SIFT_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,MutationTaster_score,MutationTaster_pred,CADD_raw,CADD_phred,COSMIC_ID,1000G_EAS,ESP6500siv2_ALL,cg46,cg69,clinvar_20150629,cosmic70 $annovar | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.annovar.txt

#filter the database

/nfs2/pipe/Re/Software/miniconda/bin/perl $perl_scr $out/simply.annovar.txt $annodb $oncotator $out_file $out_file_n

#rm $out/simply.annovar.txt
