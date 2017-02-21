#!/nfs/pipe/Re/Software/bin/Rscript --vanilla

# plot gc content
# @wxian2017Feb17

argv <- commandArgs(TRUE)
if (length(argv) == 0) {
	cat ("Usage: /PATH/plot_gc_content.R <input_file> <out_dir>\n")
	q()
}

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
library("ggplot2")
options(bitmapType='cairo')
data_path <- as.character(argv[1])
out_dir <- as.character(argv[2])
if (!file.exists(out_dir) ) {
	dir.create(out_dir)
}



  #in_data=read.table("/lustre/project/og04/wangxian/pipeline_script/GC/GC_output/all_sort.gc_content.txt")
  
  #data_nodata <- read.table("/lustre/project/og04/wangxian/pipeline_script/GC/GC_output/nodata_sort.gc_content.txt")
  #colnames(data_nodata)=c("panel","gc")
data_panel <- read.table("/p299/user/og04/wangxian/GC_percent_test/GC_output/gc_percent_needle.txt")
colnames(data_panel)=c("panel","gc")
  
mean_panel <- tapply(as.numeric(data_panel$gc),data_panel$panel,mean)
sd_panel <- tapply(as.numeric(data_panel$gc),data_panel$panel,sd)
threshhold_upper <- mean_panel+2*sd_panel
threshhold_lowwer <- mean_panel-2*sd_panel
no_data_panel <- table(data_panel$panel)
data_panel$threshhold_lowwer <- rep(round(threshhold_lowwer),no_data_panel)
data_panel$threshhold_upper <- rep(round(threshhold_upper),no_data_panel)
abnormal_data <- subset(data_panel,data_panel$gc > data_panel$threshhold_upper | data_panel$gc < data_panel$threshhold_lowwer)
abnormal_data$color <- "blue"
  #data_nodata$gc=-rep(table(data_nodata$panel),table(data_nodata$panel))/5
  #data_nodata$color="black"
standard=read.table("/p299/user/og04/wangxian/GC_percent_test/panel_designed/standard_gc_percent_needle.txt")
standard$color <- "red"
standard$V1 <- c(1:nrow(standard))
colnames(standard) <- c("panel","chr","start","end","base","gc","color")
abnormal <- rbind(abnormal_data[,c(1,2,5)],standard[,c(1,6,7)])
abnormal <- abnormal[order(abnormal[,1]),]
no_no <- ceiling(max(abnormal$panel)/200)
no_abnormal <- rep(c(1:200),no_no)[1:max(abnormal$panel)]
no_abnormal_panel <- table(abnormal$panel)
abnormal$no <- rep(no_abnormal,no_abnormal_panel)                   
  
g_abnormal <- floor((rep(rep(c(1:max(abnormal$panel))),no_abnormal_panel)-1)/200)
abnormal$group <-  paste0((g_abnormal+1)*200-199," ~ ",(g_abnormal+1)*200)
abnormal$group <- ordered(abnormal$group,levels=c("1 ~ 200","201 ~ 400","401 ~ 600","601 ~ 800","801 ~ 1000","1001 ~ 1200"))
  #threshhold_min <- min(threshhold_chr[-which(is.na(threshhold_chr))])
  #threshhold_chr[which(is.na(threshhold_chr))] <- threshhold_min
  
  #abnormal_out <- paste0("/lustre/project/og04/wangxian/pipeline_script/GC/panel_output/CHR/abnormal_chr",i,".txt")
  #write.table(abnormal_data,abnormal_out,col.names = FALSE, row.names = FALSE,quote=F,sep="\t")


#++++++
library("ggplot2")

png("/lustre/project/og04/wangxian/pipeline_script/GC/abnormal_gc_percent.png",width=2000,height=2000,units="px")
p <- ggplot(abnormal,aes(x=as.factor(abnormal$no),y=abnormal$gc)) + geom_boxplot() + geom_jitter(color=abnormal$color) + facet_grid(abnormal$group~.) + ylab("GC_percent(%)") + xlab("PANEL") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
print (p)
dev.off()

  
  
#abnormal <- read.table("/lustre/project/og04/wangxian/pipeline_script/GC/panel_output/CHR/abnormal.txt")

#panel=read.table("/lustre/project/og04/wangxian/pipeline_script/GC/panel_designed/panel12_gc_percent_sort.bed")
#colnames(panel)=c("chr","start","end","color")
#panel$no=c(1:nrow(panel))





