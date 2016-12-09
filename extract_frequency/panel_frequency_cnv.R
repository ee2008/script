#!/nfs2/pipe/Re/Software/miniconda/bin/Rscript --vanilla
# CNV: filter the panel
# @wxian2016Sep18

library("plyr")


panel1.ad="/lustre/project/og04/pub/dev/panel_design_tumor_drug/result_r5/pick_out/panel1.info"
panel2.ad="/lustre/project/og04/pub/dev/panel_design_tumor_drug/result_r5/pick_out/panel2.info"


argv <- commandArgs(TRUE)
if (length(argv) < 3) {
  cat (
    "Usage: Rscript $0 <project_dir> <sample_prefix> <out_dir>\n")
  q()
}

in_dir=as.character(argv[1])
sample=as.character(argv[2])
out_dir=as.character(argv[3])

#in_dir="/lustre/project/og04/wangxian/human_tumor/cancer_gastric-20160409_fujian/"
#sample="GC03B-VS-GC03T"
#out_dir="."


panel1=read.csv(panel1.ad,sep="\t")
#panel1=panel1[-1,]
panel1=subset(panel1,panel1[,7]=="cnv")
#colnames(panel1)=c("chromsome")
#panel2=read.csv(panel2.ad,sep="\t)
#panel2=subset(panel2,panel2[,7]=="cnv")

cns.sig=paste0(in_dir,"/cnv/",sample,"/",sample,".cns.sig")
cns=read.csv(cns.sig,sep="\t")
cns=cns[,-6:-7]
colnames(cns)=c("X.chr","start","end","gene","log2")

data=rbind.fill(cns,panel1)
data=data[order(data[,1],data[,2]),]
sort_index=data[,2]
data_start=data.frame(sort_index,data)
sort_index=cns[,3]
cns_end=data.frame(sort_index,cns)
data_sort=rbind.fill(cns_end,data_start)
data_sort=data_sort[order(data_sort[,2],data_sort[,1]),]
data=data_sort[,-1]
data_test=data[!duplicated(data$X.chr,data$start,data$end),]













