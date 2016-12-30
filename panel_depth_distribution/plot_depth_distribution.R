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
#data_path <- "/p299/user/og04/wangxian/CA-PM/depth_plot/CA-PM-20160918/OG165712015T1CFD.bedtools_depth100_depth.txt"
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
software <- file_name[2]
tools <- substr(software,1,8)


data=read.table(data_path,header = T)
data$CHR=ordered(data$CHR,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))


## find abnormal value 
in_panel <- subset(data, data$PANEL == "red")
out_panel <- subset(data, data$PANEL == "blue")
if ((nrow(in_panel)>1) & (nrow(out_panel)>1)) {
  mean_panel_chr <- tapply(in_panel$DEPTH,in_panel$CHR,mean)
  sd_panel_chr <- tapply(in_panel$DEPTH,in_panel$CHR,sd)
  threshhold_chr <- mean_panel_chr+2*sd_panel_chr
  threshhold_min <- min(threshhold_chr[-which(is.na(threshhold_chr))])
  threshhold_chr[which(is.na(threshhold_chr))] <- threshhold_min
  no_out_panel_chr <- table(out_panel$CHR)
  out_panel$threshhold <- rep(round(threshhold_chr),no_out_panel_chr)
  abnormal_data <- subset(out_panel,out_panel$DEPTH > out_panel$threshhold)
  if (nrow(abnormal_data) > 1) {
    ab_chr <- as.character(abnormal_data[1,2])
    ab_po <- abnormal_data[1,3]-1
    bed_chr <- c(ab_chr)
    bed_start <- c(abnormal_data[1,3])
    bed_end <- c()
    for (i in 1:nrow(abnormal_data)) {
      if ((abnormal_data[i,2] != ab_chr) || ((abnormal_data[i,3]-1) != ab_po)) {
        bed_chr <- c(bed_chr,as.character(abnormal_data[i,2]))
        bed_start <- c(bed_start,abnormal_data[i,3])
        bed_end <- c(bed_end,ab_po)
      }
      ab_chr <- as.character(abnormal_data[i,2])
      ab_po <- abnormal_data[i,3]
    }
    bed_end <- c(bed_end,abnormal_data[nrow(abnormal_data),3])
    abnormal_out_data <- data.frame(bed_chr,bed_start,bed_end)
    colnames(abnormal_out_data) <- c("CHR","START","END")
    row_abnormal_data <- as.numeric(row.names(abnormal_data))
    data$PANEL <- ordered(data$PANEL,levels=c("red","blue","green"))
    data[row_abnormal_data,5] <- "green"
  } else {
    abnormal_out_data <- data.frame()
  }
} else {
  abnormal_out_data <- data.frame()
}
abnormal_out <- paste0(out_dir, "/", sample,".panel_abnormal_",tools,".bed")
write.table(abnormal_out_data,abnormal_out,col.names = FALSE, row.names = FALSE,quote=F,sep="\t")
 
if (length(argv) == 5) {
  p=ggplot(data, aes(NO, DEPTH)) + geom_line(colour = data$PANEL, size = 0.5) + ylab("Depth") + xlab("")  + ggtitle(paste0("Depth_Distribution_",depth,"_",tools," (", sample, ")")) + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),title=element_text(family="myFont2",face="bold",size=20)) + facet_grid(data$CHR~.) 
} else if (length(argv) == 6) {
  if (data[2,1] == data[2,3]) {
  	po1=v_line1
  } else {
  	po1=data[v_line1,3]
  }
  p=ggplot(data, aes(NO, DEPTH)) + geom_line(colour = data$PANEL, size = 0.5) + ylab("Depth") + xlab("")  + ggtitle(paste0("Depth_Distribution_",depth,"_",tools," (", sample, ") : ",po1)) + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),title=element_text(family="myFont2",face="bold",size=20)) + facet_grid(data$CHR~.) + geom_vline(xintercept = rep(v_line1,nrow(data)), linetype = 1, colour = "black", size =0.6) 
} else {
  if (data[2,1] == data[2,3]) {
  	po1=v_line1
	po2=v_line2
  } else {
    po1=data[v_line1,3]
    po2=data[v_line2,3]
  }
  p=ggplot(data, aes(NO, DEPTH)) + geom_line(colour = data$PANEL, size = 0.5) + ylab("Depth") + xlab("")  + ggtitle(paste0("Depth_Distribution_",depth,"_",tools," (", sample, ") : ",po1,"-",po2)) + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),title=element_text(family="myFont2",face="bold",size=20)) + facet_grid(data$CHR~.) + geom_vline(xintercept = rep(v_line1,nrow(data)), linetype = 1, colour = "black", size =0.6) + geom_vline(xintercept = rep(v_line2,nrow(data)), linetype = 1, colour = "black", size =0.6)
}

if (type_plot == "png") {
	png(paste0(out_dir, "/", name,".png"),width=1000,height=1000,units="px")
} else {
	output_path <- paste0(type_plot,"(\"",out_dir,"/",name,".",type_plot,"\")")
	eval(parse(text = output_path))
}
print (p)
dev.off()
