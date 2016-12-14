#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# plot depth distribution
# @wxian2016Nov24

argv <- commandArgs(TRUE)
if (length(argv) == 0) {
  cat ("Usage: /PATH/plot_base_distribution.R <input> <out_dir> <output_name> <picture_type> <depth> [v_line1] [v_line2]\n")
  q()
}

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
library("ggplot2")
#fix X11
options(bitmapType='cairo')

data_path <- as.character(argv[1])
#data_path <- "/p299/user/og04/wangxian/script/aaa/OG165740011T1LEUD.depth100.samtools_depth.txt"
out_dir <- as.character(argv[2])
if (!file.exists(out_dir) ) {
  dir.create(out_dir)
}
name <- as.character(argv[3])
type_plot <- as.character(argv[4])
depth <- as.character(argv[5])


if (length(argv) == 6) {
  v_line1 <- as.numeric(argv[6])
}

if (length(argv) > 6) {
  v_line1 <- as.numeric(argv[6])
  v_line2 <- as.numeric(argv[7])
}

path <- strsplit(data_path,'/')[[1]]
file_name <- strsplit(path[length(path)],"\\.")[[1]]
sample=file_name[1]

data=read.table(data_path,header = T)
data$CHR=ordered(data$CHR,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))


if (length(argv) == 5) {
  p=ggplot(data, aes(NO, DEPTH)) + geom_line(colour = data$PANEL, size = 0.5) + ylab("Depth") + xlab("")  + ggtitle(paste0("Depth_Distribution_",depth," (", sample, ")")) + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),title=element_text(family="myFont2",face="bold",size=20)) + facet_grid(data$CHR~.) 
} else if (length(argv) == 6) {
  if (data[2,1] == data[2,3]) {
  	po1=v_line1
  } else {
  	po1=data[v_line1,3]
  }
  p=ggplot(data, aes(NO, DEPTH)) + geom_line(colour = data$PANEL, size = 0.5) + ylab("Depth") + xlab("")  + ggtitle(paste0("Depth_Distribution_",depth," (", sample, ") : ",po1)) + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),title=element_text(family="myFont2",face="bold",size=20)) + facet_grid(data$CHR~.) + geom_vline(xintercept = rep(v_line1,nrow(data)), linetype = 1, colour = "black", size =0.6) 
} else {
  if (data[2,1] == data[2,3]) {
  	po1=v_line1
	po2=v_line2
  } else {
    po1=data[v_line1,3]
    po2=data[v_line2,3]
  }
  p=ggplot(data, aes(NO, DEPTH)) + geom_line(colour = data$PANEL, size = 0.5) + ylab("Depth") + xlab("")  + ggtitle(paste0("Depth_Distribution_",depth," (", sample, ") : ",po1,"-",po2)) + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),title=element_text(family="myFont2",face="bold",size=20)) + facet_grid(data$CHR~.) + geom_vline(xintercept = rep(v_line1,nrow(data)), linetype = 1, colour = "black", size =0.6) + geom_vline(xintercept = rep(v_line2,nrow(data)), linetype = 1, colour = "black", size =0.6)
}

if (type_plot == "png") {
	png(paste0(out_dir, "/", name,".png"),width=1000,height=1000,units="px")
} else {
	output_path <- paste0(type_plot,"(\"",out_dir,"/",name,".",type_plot,"\")")
	eval(parse(text = output_path))
}
print (p)
dev.off()

#png(paste0(out_dir, "/", sample,"_depth_distribution.png"),width=1000,height=1000,units="px")
#print (p)
#dev.off()
#pdf(paste0(out_dir, "/", sample,"_depth_distribution.pdf"))
#print (p)
#dev.off()
#svg(paste0(out_dir, "/", sample,"_depth_distribution.svg"))
#print (p)
#dev.off()






