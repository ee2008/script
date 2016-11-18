#!/bin/bash

# merge all anno.txt
# @wxian20160908

[[ $# -eq 0 ]] && echo "Usage: sh $0 <anno_dir/sample> <out_dir | anno_dir>" && exit 0

echo ">> START @$(date)"


in=$1

if [[ $# -lt 2 ]]; then
	out=$(dirname $in)
else 
	out=$2
	[[ ! -d $out ]] && mkdir -pv $out
fi

annovar=${in}*.annovar.hg19_multianno.txt
#annodb=${in}.snp.annodb.genome_summary.xls
oncotator=${in}*.oncotator.tsv
gemini=${in}*.gemini.query.txt
sample=${in##*/}
out_file=${out}/$sample.anno.tsv

# == cut the oncotator.tsv
code=$(chardetect $oncotator | cut -d " " -f 2)
grep -v "^#" $oncotator | /nfs2/pipe/Re/Software/bin/csvcut -t -e $code -c genome_change,"HGNC_OMIM ID(supplied by NCBI)",CGC_GeneID,gencode_xref_refseq_mRNA_id,"HGNC_UCSC ID(supplied by UCSC)",dbNSFP_phastCons46way_primate,ESP_GWAS_PUBMED | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.${sample}.oncotator.tsv 

# == cut the annodb.genome_summary.xls
#/nfs2/pipe/Re/Software/bin/csvcut -t -c Func,Gene,"Exonic|Biotype",Chr,Start $annodb | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.annodb.xls

# == cut the annovar.hg19_multianno.txt
/nfs2/pipe/Re/Software/bin/csvcut -t -c Chr,Start,End,Ref,Alt,Func.ensGene,Gene.ensGene,Gene.knownGene,GeneDetail.ensGene,ExonicFunc.ensGene,AAChange.ensGene,avsnp144,genomicSuperDups,SIFT_score,SIFT_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,MutationTaster_score,MutationTaster_pred,CADD_raw,CADD_phred,COSMIC_ID,1000G_EAS,1000G_EUR,1000G_AFR,1000G_AMR,1000G_SAS,1000G_ALL,ESP6500siv2_ALL,cg46,cg69,clinvar_20150629,cosmic70 $annovar | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.${sample}.annovar.txt

# == cut the gemini.query.txt
/nfs2/pipe/Re/Software/bin/csvcut -t -c chrom,start,end,qual,cyto_band,in_cpg_island,encode_tfbs,encode_dnaseI_cell_count,encode_dnaseI_cell_list,encode_consensus_gm12878,encode_consensus_h1hesc,encode_consensus_helas3,encode_consensus_hepg2,encode_consensus_huvec,encode_consensus_k562 $gemini | /nfs2/pipe/Re/Software/bin/csvformat -T > $out/simply.${sample}.gemini.txt


# == opt germline or somatic
opt1=$(sed -n '2p' $out/simply.${sample}.oncotator.tsv | awk '{print $1}')
opt2=$(sed -n '3p' $out/simply.${sample}.oncotator.tsv | awk '{print $1}')
if [[ $opt1 -eq $opt2 ]]; then
	awk 'NR%2==1' $out/simply.${sample}.oncotator.tsv > $out/simply.${sample}.oncotator.uniq.tsv
	paste $out/simply.${sample}.annovar.txt $out/simply.${sample}.oncotator.uniq.tsv > $out/simply.${sample}.annovar.oncotator.tsv
	rm $out/simply.${sample}.annovar.txt $out/simply.${sample}.oncotator.tsv
else
	paste $out/simply.${sample}.annovar.txt $out/simply.${sample}.oncotator.tsv > $out_file
	rm $out/simply.${sample}.annovar.txt $out/simply.${sample}.oncotator.tsv
fi




#rm $out/simply.annovar.txt $out/simply.gemini.xls $out/simply.oncotator.tsv

echo ">> DONE @$(date)"
