#!/bin/bash

[[ $# -eq 0 ]] && echo "Usage: sh $0 <pathway_dir>" && exit 0

DIR="$1"

cd $DIR
n=$(ls *.kegg_gene.txt| wc -l)
cat *.kegg_gene.txt > ./intersection.kegg_gene.tsv
sort -k 1 ./intersection.kegg_gene.tsv | uniq -c | sed 's/^[ \t]*//g'> intersection.pathway0.tsv
sort -r -n -k 1 intersection.pathway0.tsv > tem_intersection.pathway.tsv
grep "^$n" tem_intersection.pathway.tsv | cut -d " " -f 2- > intersection.pathway.tsv
rm ./intersection.kegg_gene.tsv intersection.pathway0.tsv tem_intersection.pathway.tsv



cat *.var.gene.uniq.txt > intersection.gene_all.tsv
sort intersection.gene_all.tsv | uniq -c | sed 's/^[ \t]*//g'> intersection.gene0.tsv
sort -r -n -k 1 intersection.gene0.tsv > tem_intersection.gene.tsv
grep "^$n" tem_intersection.gene.tsv | cut -d " " -f 2- > intersection.gene.tsv
rm intersection.gene_all.tsv intersection.gene0.tsv tem_intersection.gene.tsv


cd -



