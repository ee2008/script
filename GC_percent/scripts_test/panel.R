#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# plot G+C
# @wxian2016Dec30

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')

argv <- commandArgs(TRUE)
if (length(argv) == 0) {
	cat ("Usage: /PATH/panel.R <input> <out_dir>\n")
  q()
}

data_path <- as.character(argv[1])

#panel1 <- read.table("/lustre/project/og04/pub/dev/panel_design_tumor_drug/result_r9/threshold20/NGS_Design_panel1/designed.bed")
#colnames(panel1) <- c("chr","start","end")
#panel1$chr <- ordered(panel1$chr,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
#panel1$length <- panel1$end-panel1$start+1

#panel2 <- read.table("/p299/user/og04/wangxian/CA-PM/GC/panel.designed.bed")
#colnames(panel2) <- c("chr","start","end")
#panel2$chr <- ordered(panel2$chr,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
#panel2$length <- panel2$end-panel2$start+1

t <- Sys.time()
print (paste0(">> START ",t))


library("ggplot2")
data_sample <- read.table(data_path)
data_sample$color <- "blue"
data_sample <- data_sample[,-3]
colnames(data_sample) <- c("chr","po","percent","depth","color")
panel_color <- read.table("/p299/user/og04/wangxian/CA-PM/GC/panel_designed/panel12_gc_percent_sort.bed")
colnames(panel_color) <- c("chr","po","percent","color")
data <- rbind(data_sample,panel_color)
data$chr=ordered(data$chr,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
data_new <- data[order(data$chr,data$po),]
#write.table(data_new,"/p299/user/og04/wangxian/CA-PM/GC/tt.txt",row.names = F,sep="\t")


#chr<- subset(data_new,data_new$chr=="1")
#ggplot(chr,aes(as.factor(po),percent)) + geom_point(colour = chr$color, size=0.3) + ylab("") + xlab("") 



png(paste0("/p299/user/og04/wangxian/CA-PM/GC/bb/OG165740011T1LEUD.gc_content", ".png"),width=2000,height=2000,units="px")
ggplot(data_new,aes(as.factor(po),percent)) + geom_point(colour = data_new$color, size=0.3) + ylab("") + xlab("") + facet_grid(~data_new$chr) 
dev.off()

t <- Sys.time()
print (paste0(">> DONE ",t))


#theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),title=element_text(family="myFont2",face="bold",size=20)) + scale_x_discrete(breaks = po_x_cent_name) + theme(axis.text.x=element_text(family="myFont2",face="bold",size=10,angle=90,color="blue")) + ggtitle(paste0("CA-PM(chr",C,")"))
