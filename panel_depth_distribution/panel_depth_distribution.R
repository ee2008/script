#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# plot panel depth distribution
# @wxian2016Dec05

argv <- commandArgs(TRUE)
if (length(argv) < 2) {
  cat (
    "Usage: /PATH/panel_depth_distribution.R <sample_samtools_depth_bed.txt> <panel.bed> <out_dir>\n")
  q()
}

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')
library("ggplot2")

in_data <- as.character(argv[1])
#in_data <- "/p299/user/og04/wangxian/CA-PM/CA-PM-20161108_v5/qc/panel/OG165740011T1LEUD.samtools_depth_bed.txt"
in_panel <- as.character(argv[2])
#in_panel <- "/lustre/project/og04/pub/database/panel_ca_pm/panel.bed"
out_dir <- as.character(argv[3])
#out_dir <- "/p299/user/og04/wangxian/plot_example"
if (!file.exists(out_dir) ) {
	dir.create(out_dir)
}

path <- strsplit(in_data,'/')[[1]]
file_name <- strsplit(path[length(path)],"\\.")[[1]]
sample=file_name[1]

## start time
t <- Sys.time()
print (paste0(">> START ",t))

data=read.table(in_data)
colnames(data)=c("CHR","PO","DEPTH")
data$CHR=ordered(data$CHR,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
nu_chr <- table(data$CHR)

panel=read.table(in_panel)[,1:3]
colnames(panel) = c("chr","start","end")
panel_nrow <- nrow(panel)
data_nrow <- nrow(data)
int_n <- ceiling(panel_nrow/100)
panel_no <- rep(1:100,int_n)
panel$no <- panel_no[1:panel_nrow]
panel$length=panel$end-panel$start+1

# data_t <- readLines(in_data)
# group <- sapply(data_t, function(x) {
#   line <- strsplit(x, ',')[[1]]
#   chr <- as.character(line[1])
  #po <- as.character(x[2])
  # for (i in 1:nrow(panel)) {
  #   if ((chr == panel[i,1]) & (po >= panel[i,2]) & (po <= panel[i,3])) {
  #     NO <- panel[[i,4]]
  #     break
  #   }
  # }
#}, simplify="array")

p <- 1
g <- 100
NO <- rep(NULL,data_nrow)
GROUP <- rep(NULL,data_nrow)
LENGTH <- rep(NULL,data_nrow)
for (i in (1:data_nrow)) {
  chr <- as.character(data[i,1])
  po <- data[i,2]
  if ((chr == panel[p,1]) & (po >= panel[p,2]) & (po <= panel[p,3])) {
    NO[i] <- panel[p,4]
    LENGTH[i] <- panel[p,5]
  } else {
    p <- p+1
    if ((chr == panel[p,1]) & (po >= panel[p,2]) & (po <= panel[p,3])) {
      NO[i] <- panel[p,4]
      LENGTH[i] <- panel[p,5]
    }
  }
  if (g < p) {
    g <- g+100
  }
  GROUP[i] <- paste0(g-99," ~ ",g)

}
data <- cbind(data,NO,GROUP,LENGTH)
group <- rep(NULL,int_n)
for (i in (1:int_n)) {
  group_n <- paste0((i-1)*100+1," ~ ",i*100)
  group <- c(group,group_n)
}
data$GROUP=ordered(data$GROUP,levels=group)
#out_file <- paste0(out_dir, "/", sample,"_panel_depth_distribution.txt")
#write.table(data,out_file)

## plot time
t <- Sys.time()
print (paste0(">> PLOTTING ",t))

png(paste0(out_dir, "/", sample,"_panel_depth_boxplot.png"),width=1000,height=1000,units="px")
p <- ggplot(data, aes(x=factor(NO), y=DEPTH)) + geom_boxplot(aes(fill=LENGTH)) + ylab("Depth") + xlab("") + ggtitle(paste0("Panel_Depth_Boxplot (", sample, ")")) + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),axis.text.y=element_text(family="myFont2",face="bold",size=10,color="blue"),axis.text.x=element_text(family="myFont2",face="bold",size=6,angle=60,color="blue"),title=element_text(family="myFont2",face="bold",size=20),legend.title=element_text(family="myFont2",face="bold",size=10)) + facet_grid(data$GROUP~.)
print (p)
dev.off()

## end time
t= Sys.time()
print (paste0(">> DONE ",t))


## plot 1
# data$NO=c(1:nrow(data))
# n=1
# col=c()
# color=rainbow(length(nu_chr))
# for (i in nu_chr[1:length(nu_chr)]) {
#    col_chr=rep(as.character(color[n]),times=i)
#    col=c(col,col_chr)
#    n=n+1
# }
# data=cbind(data,col)
#  
# #p=ggplot(data, aes(NO, DEPTH),fill=col) + geom_line(aes(color = col), size = 0.5) + ylab("Depth") + xlab("") + scale_colour_hue(name ="chr") + theme(text = element_text(family = "Arial"), plot.title = element_text(size = 16, face = "bold"), legend.background = element_rect(fill = NA, colour = "black"),  legend.title.align = 1, legend.title = element_text(face = "plain", size = 12), legend.text = element_text(size = 11), axis.title = element_text(size = 14), legend.key.height = unit(0.6, 'cm'), legend.key = element_rect(fill = "grey90"), legend.key.width = unit(1.2, 'cm'), plot.margin = unit(c(1, 0, 1, 0), "cm"), axis.text = element_text(colour = "black", size = 12), strip.background = element_rect(fill = NA, colour = NA), axis.ticks.length = unit(0.2, "cm")) p + scale_fill_discrete(labels=c("1","10","11","12","13","14","15","16","17","18","19","2","3","4","5","6","7","8","9","X"))
#  
# png(paste0(out_dir, "/", sample,"_panel_depth_distribution_colorful.png"),width=1000,height=1000,units="px")   
# p=ggplot(data, aes(NO, DEPTH),fill=col) + geom_line(color = col, size = 0.5) + ylab("Depth") + xlab("") + ggtitle(paste0("Panel_Depth_Distribution (", sample, ")"))
# print(p)
# dev.off()
# 
# 
# 
# 
# 
# NO_2=c()
# for (i in nu_chr[1:length(nu_chr)]) {
#   if (i!=0) {
#     NO_chr=c(1:i)
#     NO_2=c(NO_2,NO_chr) 
#   }
# }
# data=cbind(data,NO_2)
# png(paste0(out_dir, "/", sample,"_panel_depth_distribution_chr_po.png"),width=1000,height=1000,units="px")    
# p=ggplot(data, aes(PO, DEPTH)) + geom_point(color="red",size = 0.5) + ylab("Depth") + xlab("") + facet_grid(data$CHR~.) + ggtitle(paste0("Panel_Depth_Distribution (", sample, ")"))
# print(p)
# dev.off()
# png(paste0(out_dir, "/", sample,"_panel_depth_distribution_chr.png"),width=1000,height=1000,units="px") 
# p=ggplot(data, aes(NO_2, DEPTH)) + geom_line(color="red",size = 0.5) + ylab("Depth") + xlab("") + facet_grid(data$CHR~.) + ggtitle(paste0("Panel_Depth_Distribution (", sample, ")"))
# print(p)
# dev.off()
