#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# @wxian2017Aug02

argv <- commandArgs(TRUE)
if (length(argv) == 0) {
  cat ("Usage: /PATH/plot.R <sample_id_list> <cancer.txt> <out_dir>\n")
  q()
}
.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')

## parameter
input <- as.character(argv[1])
cancer_panno <- as.character(argv[2])
s_type <- as.character(argv[3])
out_dir <- as.character(argv[4])

if (!file.exists(out_dir) ) {
   dir.create(out_dir)
}


#dd=read.csv("/lustre/project/og04/wangxian/1705wxVisual/cancer_vf/gastric/all.var.panel_cons.txt",sep="\t")
#cancer_panno="/lustre/project/og04/wangxian/1705wxVisual/cancer_vf/gastric.txt"

dd=read.csv(input,sep="\t")
cancer <- read.table(cancer_panno)
cancer_path <- strsplit(cancer_panno,'/')[[1]]
c_path <- strsplit(cancer_path[length(cancer_path)],"\\.")[[1]]
cancer_name <- c_path[1]

VF_break <- c(0, 0.01, 0.05, 1)
ddd <- subset(dd,dd$panno %in% cancer$V1)
ddd$AF <-  cut(ddd$VF, right=T, breaks=VF_break) 
ddd$anno <- paste0(ddd$gene,"_",ddd$panno)
#tt <- table(dd$index)
#n_tt <- length(tt)
#tt_sort <- sort(tt)[(n_tt-n_panno+1):n_tt]
#p_anno_index <- names(tt_sort)
#ddd <- subset(dd,dd$index %in% p_anno_index)



library(ggplot2)
png(paste0(out_dir, "/",cancer_name, "_AF (", s_type, ").png"),width=1000,height=1000,units="px")
if (s_type == "consistency") {
  p <- ggplot() + 
    geom_point(data=ddd,aes(y=sample,x=anno,color= AF)) + 
    ylab("Sample") + xlab("Gene_panno") + 
    ggtitle(paste0(cancer_name," cancer")) +
    theme(axis.title.y = element_text(face="bold",size=15),axis.title.x = element_text(face="bold",size=15), axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),legend.title=element_text(face="bold",size=10),title=element_text(face="bold",size=20)) + facet_grid(ID~.,scales = c('free_y')) 
} else {
  p <- ggplot() + 
    geom_point(data=ddd,aes(x=sample,y=anno,color= AF)) + 
    ylab("Gene_panno") + xlab("Sample") + 
    ggtitle(paste0(cancer_name," cancer")) +
    theme(axis.title.y = element_text(face="bold",size=15),axis.title.x = element_text(face="bold",size=15), axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),legend.title=element_text(face="bold",size=10),title=element_text(face="bold",size=20)) 
}
print (p)  
dev.off()





#facet_grid(ddd$type~.,scales = c('free')) 
