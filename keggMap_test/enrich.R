
library(org.Hs.eg.db)
library(clusterProfiler)

input <- "/p299/user/og04/wangxian/PM-TJ-X-20160720-02/pathway/H6_HGV3FALXX.var.gene.uniq.txt"
out_dir <- "/p299/user/og04/wangxian/PM-TJ-X-20160720-02/pathway"
path <- strsplit(input,'/')[[1]]
file_name <- strsplit(path[length(path)],"\\.")[[1]]
sample <- file_name[1]
gene_list=read.table(input)
#gene_list=read.table("/p299/user/og04/wangxian/KF-ZZ-XHG-20161226-01/anno/test.txt")[-1,]

gene_name=unlist(gene_list$V1)
gene_id=unlist(mget(x=as.character(gene_name),envir=org.Hs.egALIAS2EG,ifnotfound = NA))

#enrichGO(id, OrgDb, keytype = "ENTREZID", ont = "MF",pvalueCutoff = 0.05, pAdjustMethod = "BH", universe, qvalueCutoff = 0.2,minGSSize = 10, maxGSSize = 500, readable = FALSE, pool = FALSE)

#GO
getgo <- enrichGO(gene_id, 'org.Hs.eg.db', ont="BP", pvalueCutoff=0.05)
out_go <- paste0(out_dir,"/",sample,".var.go.txt")
write.table(getgo,out_go,col.names = TRUE, row.names = FALSE,quote=F,sep="\t")


#KEGG
getkegg <- enrichKEGG(gene_id, pvalueCutoff=0.05)
out_kegg <- paste0(out_dir,"/",sample,".var.kegg.txt")
write.table(getkegg,out_kegg,col.names = TRUE, row.names = FALSE,quote=F,sep="\t")


#viewKEGG(getkegg)


