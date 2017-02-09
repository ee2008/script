#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# plot panel depth distribution
# @wxian2016Dec05

argv <- commandArgs(TRUE)
if (length(argv) < 2) {
  cat (
    "Usage: /PATH/panel_depth_distribution.R <sample.samtools_depth_bed.txt/sample.bedtools_intersect.txt> <tools> <out_file> <pic_type> <pic_chr> <panel.bed>\n")
  q()
}

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')
library("ggplot2")

in_data <- as.character(argv[1])
#in_data <- "/lustre/project/og04/wangxian/pipeline_script/panel_depth_distribution/test2/OG165711119T1CFD.chr3.txt"
tools <- as.character(argv[2])
output <- as.character(argv[3])
type_plot <- as.character(argv[4])
pic_chr <- as.character(argv[5])
in_panel <- as.character(argv[6])
#in_panel <- "/lustre/project/og04/wangxian/pipeline_script/panel_depth_distribution/test2/panel.chr3.bed"

path <- strsplit(in_data,'/')[[1]]
file_name <- strsplit(path[length(path)],"\\.")[[1]]
sample <- file_name[1]

  
## start time
t <- Sys.time()
print (paste0(">> START ",t))
print (paste0(">  INPUT: ",in_data))

if (tools == "bedtools") {
	print (">  DATA from bedtools")
	data_origin <- read.table(in_data,sep="\t")
	#bedtools_ncol <- ncol(data_bedtools)	
	data_origin[,1]=ordered(data_origin[,1],levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
	#data_bedtools[,bedtools_ncol-4]=ordered(data_bedtools[,1],levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
	#data_origin=data_bedtools[c(1,2,3,bedtools_ncol-1,bedtools_ncol)]
	data_origin$length <- data_origin[,3]-data_origin[,2]
	panel=read.table(in_panel,sep=" ")
	row_panel <- nrow(panel)
	max_n <- ceiling(row_panel/100)
	panel$no <- rep(1:100,max_n)[1:row_panel]
	panel$g <- rep(c(1:max_n),rep(100,max_n))[1:row_panel]
	panel$group <-  paste0((panel$g)*100-99," ~ ",(panel$g)*100)
	data_origin$no <- rep(panel$no,panel$V1)
	data_origin$group <- rep(panel$group,panel$V1)
	data_origin <- data_origin[,c(-2,-3)]
	colnames(data_origin)=c("chr","depth","len","length","no","group")
	group_factor=c()
	for (i in (1:max_n)) {
	  group_n <- paste0((i-1)*100+1," ~ ",i*100)
	  group_factor <- c(group_factor,group_n)
	}
	CHR <- rep(data_origin$chr,data_origin$len)
	DEPTH <- rep(data_origin$depth,data_origin$len)
	LENGTH <- rep(data_origin$length,data_origin$len)
	NO <- rep(data_origin$no,data_origin$len)
	GROUP <- rep(data_origin$group,data_origin$len)
	data <- data.frame(CHR,DEPTH,NO,GROUP,LENGTH)
	data$GROUP=ordered(data$GROUP,levels=group_factor)
	rm(data_origin)
} else {
  print (paste0(">  PANEL: ",in_panel))
	print (">  DATA from samtools")
	data=read.table(in_data,sep="\t")
	colnames(data)=c("CHR","PO","DEPTH")
	data$CHR=ordered(data$CHR,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
	panel=read.table(in_panel,sep="\t")[,1:3]
	colnames(panel) = c("chr","start","end")
	panel$chr=ordered(panel$chr,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
	if (pic_chr == "all") {
	  chr_name <- c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y")
	  no_chr <- sapply (chr_name, function(x) {
	    panel_chr <- subset(panel,chr==x)
	    range <- c(panel_chr$start,panel_chr$end)[order(c(panel_chr$start,panel_chr$end))]
	    data_chr <- subset(data,CHR==x)
	    chr_no <- as.vector(table(cut (data_chr$PO,range)))
	  })
	  nu_no_all <- c()
	  for (i in 1:24) {
	    if (length(no_chr[[i]])==1 & no_chr[[i]]==0) {
	      next 
	    } else {
	      nu_no_all <- c(nu_no_all, no_chr[[i]],0) 
	    }
	  }
	 # nu_no_all2 <- c(no_chr[[1]],0,no_chr[[2]],0,no_chr[[3]],0,no_chr[[4]],0,no_chr[[5]],0,no_chr[[6]],0,no_chr[[7]],0,no_chr[[8]],0,no_chr[[9]],0,no_chr[[10]],0,no_chr[[11]],0,no_chr[[12]],0,no_chr[[13]],0,no_chr[[14]],0,no_chr[[15]],0,no_chr[[16]],0,no_chr[[17]],0,no_chr[[18]],0,no_chr[[19]],0,no_chr[[20]],0,no_chr[[21]],0,no_chr[[22]],0,no_chr[[23]],0,no_chr[[24]],0)
	} else {
	  range <- c(panel$start,panel$end)[order(c(panel$start,panel$end))]
	  no_chr <- as.vector(table(cut (data$PO,range)))
	  nu_no_all <- c(no_chr,0)
	}
	nu_no <- nu_no_all[seq(1,length(nu_no_all),2)]
	#if (length(nu_no) != nrow(panel)) {
	 #print ("! Error: no data in panel_bed")
	 #q()
	#}
	if (sum(nu_no) != nrow(data)) {
	 print ("! Error: data from samtools are not in panel")
	 q()
	}
	row_panel <- nrow(panel)
	max_n <- ceiling(row_panel/100)
	panel$no <- rep(1:100,max_n)[1:row_panel]
	panel$no <- rep(1:100,max_n)[1:row_panel]
	data$NO <- rep(panel$no,nu_no)
	panel$g <- rep(c(1:max_n),rep(100,max_n))[1:row_panel]
	panel$group <-  paste0((panel$g)*100-99," ~ ",(panel$g)*100)
	data$GROUP <- rep(panel$group,nu_no)
	group_factor=c()
	for (i in (1:max_n)) {
	 group_n <- paste0((i-1)*100+1," ~ ",i*100)
	 group_factor <- c(group_factor,group_n)
	}
	data$GROUP=ordered(data$GROUP,levels=group_factor)
	data$LENGTH <- rep(nu_no,nu_no)
	rm (panel)
}

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


#out_file <- paste0(out_dir, "/", sample,"_panel_depth_distribution.txt")
#write.table(data,out_file)

## plot time
t <- Sys.time()
print (paste0(">> PLOTTING ",t))
print (paste0(">  OUTPUT: ",output))


if (type_plot == "png") {
	png(output,width=1000,height=1000,units="px")
} else {
	output_path <- paste0(type_plot,"(\"",output,"\",width=20,height=20)")
	eval(parse(text = output_path))
}

if (pic_chr == "all") {
	plot_title <- paste0("Panel_Depth_Boxplot_",tools," (", sample, ")")
} else {
	plot_title <- paste0("Panel_Depth_Boxplot_",tools," (", sample,": chr",pic_chr, ")")
}

p <- ggplot(data, aes(x=factor(NO), y=DEPTH)) + geom_boxplot(aes(fill=LENGTH)) + ylab("Depth") + xlab("") + ggtitle(plot_title) + scale_fill_continuous(low = "darkgreen", high = "red", space = "rgb") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="blue"),axis.text.x=element_text(face="bold",size=8,angle=90,color="blue"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10)) + facet_grid(data$GROUP~.)
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
