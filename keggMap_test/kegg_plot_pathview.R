#!/nfs2/pipe/Re/Software/miniconda/bin/Rscript --vanilla 

library("pathview")
data(gse16873.d)

filename=system.file("extdata/gse16873.demo", package = "pathview")
gse16873=read.delim(filename, row.names=1)
gse16873.d=gse16873[,2*(1:6)]-gse16873[,2*(1:6)-1]

data(demo.paths)

data(paths.hsa)
head(paths.hsa,3)

i <- 1
pv.out <- pathview(gene.data = gse16873.d[, 1], pathway.id = demo.paths$sel.paths[i],species = "hsa", out.suffix = "gse16873", kegg.native = T)

list.files(pattern="hsa04110", full.names=T)

str(pv.out)

head(pv.out$plot.data.gene)


pv.out <- pathview(gene.data = gse16873.d[, 1], pathway.id = demo.paths$sel.paths[i], species = "hsa", out.suffix = "gse16873.2layer", kegg.native = T, same.layer = F)

pv.out <- pathview(gene.data = gse16873.d[, 1], pathway.id = demo.paths$sel.paths[i],species = "hsa", out.suffix = "gse16873", kegg.native = F, sign.pos = demo.paths$spos[i])
#pv.out remains the same
dim(pv.out$plot.data.gene)

head(pv.out$plot.data.gene)

