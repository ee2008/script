#!/nfs2/pipe/Re/Software/miniconda/bin/Rscript --vanilla
# plot mutation fraction
# @wxian2016Aug22

library("pheatmap")
library ("ggplot2")

argv <- commandArgs(TRUE)
if (length(argv) < 3) {
  cat (
    "Usage: Rscript $0 <mutation_data_bar> <mutation_data_heat> <out_dir>\n")
  q()
}


mutation_data_bar <- as.character(argv[1])
mutation_data_heat <- as.character(argv[2])
#mutation_data_bar="/lustre/project/og04/wangxian/snake_test/test1.fra"
#mutation_data_heat="/lustre/project/og04/wangxian/snake_test/test2.fra"
out_dir <- as.character(argv[3])

# plot the mutation fraction
png(paste0(out_dir, "/", "mutation_spectrum_bar.png"))
data_mu_bar=read.table(mutation_data_bar, header = T)
ggplot (data_mu_bar,aes(x=Sample,y=Mutation_fra,fill=Mutation_type))+geom_bar(stat="identity", colour = "black",size=0.5) + guides(fill = guide_legend(reverse = TRUE)) + scale_fill_brewer(palette = "Pastel1") + ylab("Fraction of Mutation") + ggtitle("Mutation Spectrum")
dev.off()

#plot the mutation spectrum heat picture
png(paste0(out_dir, "/", "mutation_spectrum_heat.png"))
data_mu_heat=read.table(mutation_data_heat,sep='\t',header=T)
rowname=as.character(data_mu_heat[,1])
data_mu_heat1=data_mu_heat[,-1]
rownames(data_mu_heat1)=rowname
colnames(data_mu_heat1)=c("C>T/G>A","T>C/A>G","C>G/G>C","C>A/G>T","T>G/A>C","T>A/A>T")
pheatmap(data_mu_heat1,color=colorRampPalette(c('pink','mediumpurple','darkslateblue'))(100), cluster_cols = F, fontsize_row = 8,main="Mutation Spectrum") 
dev.off()



