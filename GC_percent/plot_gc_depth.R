#!/nfs/pipe/Re/Software/bin/Rscript --vanilla

# plot gc content
# @wxian2017Feb17

argv <- commandArgs(TRUE)
if (length(argv) == 0) {
	cat ("Usage: /PATH/plot_gc_content.R <input_file> <out_dir> <pic_name_gc> <pic_name_depth> <image_type(boxplot/scatter/all)> <content(gc/depth/all)>\n")
	q()
}

standard_data <- "/lustre/project/og04/pub/pipeline/plot_gc_depth/panel_design.txt"
.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
library("ggplot2")
options(bitmapType='cairo')
data_path <- as.character(argv[1])
#data_path="/p299/user/og04/wangxian/GC_percent_test/GC_output/CA-PM-20160918.gc_content.txt"
out_dir <- as.character(argv[2])
name_gc <- as.character(argv[3])
name_depth <- as.character(argv[4])
image <- as.character(argv[5])
content <- as.character(argv[6])


if (!file.exists(out_dir) ) {
	dir.create(out_dir)
}

  
data_panel <- read.table(data_path)[,c(3,4,5,6,7,8)]
colnames(data_panel)=c("chr","start","end","index","depth","gc")
if (!is.numeric(data_panel$gc)) {
  data_panel <- subset(data_panel,gc != "-")
  data_panel$gc <- as.numeric(levels(data_panel$gc)[data_panel$gc])
}
if (image == "boxplot") {
  data_panel$color <- "NA"
} else {
  data_panel$color <- "blue"
}

standard <- read.table(standard_data)
standard$panel <- paste0(standard$V1,standard$V2,standard$V3)
standard$depth <- 0
standard <- data.frame(standard$V1,standard$V2,standard$V3,standard$panel,standard$depth,standard$V4)
colnames(standard) <- c("chr","start","end","index","depth","gc")
standard$color <- "red"


data_all <- rbind(data_panel,standard)
data_all <- data_all[order(data_all$index),]
panel_bed_index <- unique(data_all[,1:3])
panel_bed_index$no <- c(1:nrow(panel_bed_index))
panel_bed_index <- panel_bed_index[,c(4,1,2,3)]
output_index <- paste0(out_dir, "/index_panel_design.bed")
write.table(panel_bed_index,output_index,row.names = F,quote=FALSE,sep="\t")

data_index <- table(data_all$index)
nu_data_inde <- length(data_index)
data_all$panel <- rep(c(1:nu_data_inde),data_index)

n=100
no_no <- ceiling(max(data_all$panel)/n)
no_data_all <- rep(c(1:n),no_no)[1:max(data_all$panel)]
no_panel <- table(data_all$panel)
data_all$no <- rep(no_data_all,no_panel)                   
  

g_data_all <- floor((data_all$panel-1)/n)
data_all$group <-  paste0((g_data_all+1)*n-n+1," ~ ",(g_data_all+1)*n)
group_factor=c()
for (i in (1:no_no)) {
  group_n <- paste0((i-1)*n+1," ~ ",i*n)
  group_factor <- c(group_factor,group_n)
}
data_all$group <- ordered(data_all$group,levels=group_factor)
 

#++++++
library("ggplot2")

if (content == "gc") {
  output <- paste0(out_dir, "/", name_gc)
  png(output,width=2000,height=4000,units="px")
  if (image == "boxplot") {
    p <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$gc)) + geom_boxplot() + geom_jitter(color=data_all$color) + facet_grid(data_all$group~.) + ylab("GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "scatter") {
    p <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$gc)) + geom_jitter(color=data_all$color) + facet_grid(data_all$group~.) + ylab("GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "all") {
    p <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$gc)) + geom_boxplot() + geom_jitter(color=data_all$color) + facet_grid(data_all$group~.) + ylab("GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  }
  
  print (p)
  dev.off()
} else if (content == "depth") {
  output <- paste0(out_dir, "/", name_depth)
  png(output,width=2000,height=4000,units="px")
  data_all <- subset(data_all,color != "red")
  if (image == "boxplot") {
    p <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$depth)) + geom_boxplot() +  facet_grid(data_all$group~.) + ylab("Depth") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "scatter") {
    p <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$depth)) + geom_jitter(color=data_all$color) + facet_grid(data_all$group~.) + ylab("Depth") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "all") {
    p <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$depth)) + geom_boxplot() + geom_jitter(color=data_all$color) + facet_grid(data_all$group~.) + ylab("Depth") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  }
  
  print (p)
  dev.off()
} else if (content == "all") {
  output_gc <- paste0(out_dir, "/", name_gc)
  png(output_gc,width=2000,height=4000,units="px")
  if (image == "boxplot") {
    p1 <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$gc)) + geom_boxplot() + geom_jitter(color=data_all$color) + facet_grid(data_all$group~.) + ylab("GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "scatter") {
    p1 <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$gc)) + geom_jitter(color=data_all$color) + facet_grid(data_all$group~.) + ylab("GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "all") {
    p1 <- ggplot(data_all,aes(x=as.factor(data_all$no),y=data_all$gc)) + geom_boxplot() + geom_jitter(color=data_all$color) + facet_grid(data_all$group~.) + ylab("GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  }
  print (p1)
  dev.off()
  output_depth <- paste0(out_dir, "/", name_depth)
  png(output_depth,width=2000,height=4000,units="px")
  data_depth <- subset(data_all,color != "red")
  if (image == "boxplot") {
    p2 <- ggplot(data_depth,aes(x=as.factor(data_depth$no),y=data_depth$depth)) + geom_boxplot() +  facet_grid(data_depth$group~.) + ylab("Depth") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "scatter") {
    p2 <- ggplot(data_depth,aes(x=as.factor(data_depth$no),y=data_depth$depth)) + geom_jitter(color=data_depth$color) + facet_grid(data_depth$group~.) + ylab("Depth") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "all") {
    p2 <- ggplot(data_depth,aes(x=as.factor(data_depth$no),y=data_depth$depth)) + geom_boxplot() + geom_jitter(color=data_depth$color) + facet_grid(data_depth$group~.) + ylab("Depth") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  }
  print (p2)
  dev.off()
}





  
  



