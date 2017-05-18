
library(org.Hs.eg.db)
library(clusterProfiler)

gene_list=read.table("/p299/user/og04/wangxian/KF-ZZ-XHG-20161226-01/pathway/WGC100875.var.gene.uniq.txt")
#gene_list=read.table("/p299/user/og04/wangxian/KF-ZZ-XHG-20161226-01/anno/test.txt")[-1,]

gene_name=unlist(gene_list$V1)


#gene=c("ABCA5","ABCC5")
gene_id=unlist(mget(x=as.character(gene_name),envir=org.Hs.egALIAS2EG,ifnotfound = NA))

#enrichGO(id, OrgDb, keytype = "ENTREZID", ont = "MF",pvalueCutoff = 0.05, pAdjustMethod = "BH", universe, qvalueCutoff = 0.2,minGSSize = 10, maxGSSize = 500, readable = FALSE, pool = FALSE)

#GO
getgo <- enrichGO(gene_id, 'org.Hs.eg.db', ont="BP", pvalueCutoff=0.05)
write.table(getgo,"/p299/user/og04/wangxian/KF-ZZ-XHG-20161226-01/pathway/WGC100875.var.go.txt",col.names = TRUE, row.names = FALSE,quote=F,sep="\t")


#KEGG
getkegg <- enrichKEGG(gene_id, pvalueCutoff=0.05)
write.table(getkegg,"/p299/user/og04/wangxian/KF-ZZ-XHG-20161226-01/pathway/WGC100875.var.kegg.txt",col.names = TRUE, row.names = FALSE,quote=F,sep="\t")


#viewKEGG(getkegg)


