cat *.kegg_gene.txt > intersection.kegg_gene.txt
sort -k 1 intersection.kegg_gene.txt | uniq -c | sed 's/^[ \t]*//g'> intersection.pathway0.txt
sort -r -n -k 1 intersection.pathway0.txt > intersection.pathway.txt


cat *.var.gene.uniq.txt > intersection.gene_all.txt
sort intersection.gene_all.txt | uniq -c | sed 's/^[ \t]*//g'> intersection.gene0.txt
sort -r -n -k 1 intersection.gene0.txt > intersection.gene.txt


