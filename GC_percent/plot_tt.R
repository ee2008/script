#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# useless -- alread add into plot_gc_depth.R

# plot the depth and changes in gc_content
# @wxian2017Mar14

#options(scipen = 200) 

#data_path="/lustre/project/og04/pub/pipeline/plot_gc_depth/CFD/CA-PM.gc_depth_20170227_162706.txt"
#standard_path <- "/lustre/project/og04/pub/pipeline/plot_gc_depth/panel_design.txt"

argv <- commandArgs(TRUE)
if (length(argv) == 0) {
  cat ("Usage: /PATH/script.R <input_file> <standard_panel_gc> <out_dir>\n")
  q()
}
  
data_path <- as.character(argv[1])
standard_path <- as.character(argv[2])
out_dir <- as.character(argv[3])

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
library("ggplot2")
options(bitmapType='cairo')

panel <- read.table(standard_path)
cfd <- read.table(data_path)
panel$index <- paste0(panel$V1,panel$V2,panel$V3)
chr_name <- c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y")

gc_change <- lapply (chr_name,function(x) {
  chr_panel <- subset(panel,V1 == x)
  chr_panel <- chr_panel[order(chr_panel$index),]
  chr_panel_data <- chr_panel[,c(5,4)]
  colnames(chr_panel_data) <- c("index","gc")
  
  
  chr_cfd <- subset(cfd,V3 == x)
  chr_cfd$index <- paste0(chr_cfd$V3,chr_cfd$V4,chr_cfd$V5)
  
  chr_cfd_data <- chr_cfd[,c(3,9,7,8)]
  colnames(chr_cfd_data) <- c("chr","index","depth","gc")
  chr_cfd_data <- chr_cfd_data[order(chr_cfd_data$index),]
  
  nu_index <- table(chr_cfd_data$index)
  chr_cfd_data$standard <- rep(chr_panel_data$gc,nu_index)
  chr_cfd_data <- subset(chr_cfd_data,gc != "-")
  chr_cfd_data$gc <- as.numeric(as.character(chr_cfd_data$gc))
  chr_cfd_data$gc_ch <- chr_cfd_data$gc - chr_cfd_data$standard
  return(chr_cfd_data)
})

gc_ch_all <- do.call(rbind,gc_change)
gc_ch_all$chr <- ordered(gc_ch_all$chr,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))

plot_data1 <- subset(gc_ch_all,nchar(as.character(gc_ch_all$chr)) == 1)
plot_data2 <- subset(gc_ch_all,nchar(as.character(gc_ch_all$chr)) == 2)


# plotting
 # split all chr into 2 part (1~9,X,Y and 10~22)
output_path1 <- paste0(out_dir,"/depth_gc-change_1.png")
output_path2 <- paste0(out_dir,"/depth_gc-change_2.png")

png(output_path1,width=2000,height=1500,units="px")
p1 <- ggplot(plot_data1) + geom_point(aes(x=gc_ch,y=depth),size=1,alpha=0.3) + facet_grid(chr~.) + ylab("Depth") + xlab("GC - GC_standard (%)")  + theme(axis.title.y=element_text(face="bold",size=20),axis.title.x=element_text(face="bold",size=20),axis.text.y=element_text(face="bold",size=20,color="black"),axis.text.x=element_text(face="bold",size=20,color="black")) 
print (p1)
dev.off()

png(output_path2,width=2000,height=1500,units="px")
p2 <- ggplot(plot_data2) + geom_point(aes(x=gc_ch,y=depth),size=1,alpha=0.3) + facet_grid(chr~.) + ylab("Depth") + xlab("GC - GC_standard (%)")  + theme(axis.title.y=element_text(face="bold",size=20),axis.title.x=element_text(face="bold",size=20),axis.text.y=element_text(face="bold",size=20,color="black"),axis.text.x=element_text(face="bold",size=20,color="black")) 
print (p2)
dev.off()




