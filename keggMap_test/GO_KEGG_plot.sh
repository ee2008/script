#!/bin/bash

[[ $# -eq 0 ]] && echo -e "Usage: $0 <in.snpeff.vcf> <out_dir>" && exit 1

perl_scr="$(dirname $0)/call_gene_in_var_snpeff.pl"
kegg_scr="$(dirname $0)/KEGG_data_plot.pl"

input="$1"
out="$2"
prefix=$(basename $input .snpeff.vcf)

[[ ! -d $out ]] && mkdir -pv $out

echo ">> START @$(date)"

gene_tem=${out}/${prefix}.gene.txt
pathway_tem=${out}/${prefix}.pathway.txt
pathway_tem2=${out}/${prefix}.pathway.uniq_tem.txt
pathway=${out}/${prefix}.pathway.uniq.txt
gene=${out}/${prefix}.gene.uniq.txt


perl $perl_scr $input $out

sort -n -k 1 $pathway_tem | uniq > $pathway_tem2
sort $gene_tem | uniq > $gene 

sed -e '1i\GeneID\tPathway\tGO Component\tGO Function\tGO Process\tBlast nr' $pathway_tem2 > $pathway

rm $pathway_tem $gene_tem $pathway_tem2

/nfs2/pipe/Re/Software/miniconda/bin/perl $kegg_scr $pathway $out

echo ">> DONE @$(date)"

