#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# plot panel depth distribution
# @wxian2016Dec05

argv <- commandArgs(TRUE)
if (length(argv) < 2) {
  cat (
    "Usage: /PATH/panel_depth_distribution.R <sample.samtools_depth_bed.txt/sample.bedtools_intersect.txt> [panel.bed | if input samtools] <out_dir/output> [png/svg/pdf/... | png]\n")
  q()
}

#Sys.setenv("LD_LIBRARY_PATH"="/nfs2/pipe/Re/Software/miniconda/lib")
.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')
library("ggplot2")

in_data <- as.character(argv[1])
#in_data <- "/p299/user/og04/wangxian/CA-PM/CA-PM-20161108_v5/qc/panel/OG165740011T1LEUD.samtools_depth_bed.txt"
#in_data <- "/lustre/project/og04/pub/test/sm_demo/qc/panel/LEU02.bedtools_intersect.txt"
path <- strsplit(in_data,'/')[[1]]
file_name <- strsplit(path[length(path)],"\\.")[[1]]
sample <- file_name[1]
software <- file_name[2] 
tools <- substr(software,1,8)

if (tools == "bedtools") {
  out <- as.character(argv[2])
} else {
  in_panel <- as.character(argv[2])
  #in_panel <- "/lustre/project/og04/pub/database/panel_ca_pm/panel.bed"
  out <- as.character(argv[3])
  #out <- "/p299/user/og04/wangxian/plot_example/"
}

out_t <- substr(out,nchar(out),nchar(out))
if (out_t == "/") {
	out_dir <- out
	output_name <- paste0(sample,".",tools,"_panel_depth_boxplot") 
} else {
	out_dirs <- strsplit(out,'/')[[1]]	
	out_dir <- substr(out,1,nchar(out)-nchar(out_dirs[length(out_dirs)]))
	output_name <- out_dirs[length(out_dirs)]
}
if (!file.exists(out_dir) ) {
  dir.create(out_dir)
}

if ((tools == "bedtools") & (length(argv) == 3))  {
  type_plot <- as.character(argv[4])
} else if ((tools == "samtools") & (length(argv) == 4))  {
  type_plot <- as.character(argv[4])
} else {
  type_plot <- "png"
}
  
## start time
t <- Sys.time()
print (paste0(">> START ",t))
print (paste0(">  INPUT: ",in_data))

if (tools == "bedtools") {
	print (">  DATA from bedtools")
	data_bedtools <- read.table(in_data)
	data_bedtools[,1]=ordered(data_bedtools[,1],levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
	data_bedtools[,5]=ordered(data_bedtools[,1],levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
	bedtools_ncol <- ncol(data_bedtools)	
	data_origin=data_bedtools[c(1,2,3,bedtools_ncol-4,bedtools_ncol-3,bedtools_ncol-2,bedtools_ncol-1,bedtools_ncol)]
	#key <- paste0(data_origin[,1],data_origin[,2])
	#no_key <- table(key)
	#data_origin$no <- rep(1:length(no_key),no_key)
	#data_origin$group <-
	data_origin$length <- data_origin[,3]-data_origin[,2]
	n <- 0
	chr <- 0
	po <- 0
	data_origin_nrow <- nrow(data_origin)
	no <- rep(NULL,data_origin_nrow)
	group <- rep(NULL,data_origin_nrow)
	for (i in (1:data_origin_nrow)) {
	  if ((data_origin[i,1] == chr) & (data_origin[i,2] == po)) {
	    no[i] <- n%%100
	  } else {
	    n=n+1
	    no[i] <- n%%100
	  }
	  if (no[i]==0) {
	    no[i] <- 100
	  }
	  chr <- data_origin[i,1]
	  po <- data_origin[i,2]
	  g <- floor((n-1)/100)
	  group[i] <- paste0((g+1)*100-99," ~ ",(g+1)*100)
	}
	data_origin <- cbind(data_origin,no,group)
	data_origin <- data_origin[,c(-1,-2,-3,-5,-6)]
	colnames(data_origin)=c("chr","depth","len","length","no","group")
	rm (data_bedtools)
	group_factor=c()
	for (i in (1:(g+1))) {
	  group_n <- paste0((i-1)*100+1," ~ ",i*100)
	  group_factor <- c(group_factor,group_n)
	}
	data_origin$GROUP=ordered(data_origin$group,levels=group_factor)
	CHR <- rep(data_origin[,1],data_origin[,3])
	DEPTH <- rep(data_origin[,2],data_origin[,3])
	LENGTH <- rep(data_origin[,4],data_origin[,3])
	NO <- rep(data_origin[,5],data_origin[,3])
	GROUP <- rep(data_origin[,6],data_origin[,3])
	data <- data.frame(CHR,DEPTH,NO,GROUP,LENGTH)
	rm(data_origin)
} else {
    print (paste0(">  PANEL: ",in_panel))
	print (">  DATA from samtools")
	data=read.table(in_data)
	colnames(data)=c("CHR","PO","DEPTH")
	data$CHR=ordered(data$CHR,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
	panel=read.table(in_panel)[,1:3]
	colnames(panel) = c("chr","start","end")
	panel$chr=ordered(panel$chr,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
	panel_nrow <- nrow(panel)
	data_nrow <- nrow(data)
	int_n <- ceiling(panel_nrow/100)
	panel_no <- rep(1:100,int_n)
	panel$no <- panel_no[1:panel_nrow]
	panel$length=panel$end-panel$start+1
	p <- 1
	g <- 100
	NO <- rep(NULL,data_nrow)
	GROUP <- rep(NULL,data_nrow)
	LENGTH <- rep(NULL,data_nrow)
	for (i in (1:data_nrow)) {
	  chr <- as.character(data[i,1])
	  po <- data[i,2]
	  while ((chr != panel[p,1]) || (po > panel[p,3])) {
	    p <- p+1
	  }
	  NO[i] <- panel[p,4]
	  LENGTH[i] <- panel[p,5]
	  if (g < p) {
	    g <- g+100
	  }
	  GROUP[i] <- paste0(g-99," ~ ",g)
	}
	group <- rep(NULL,int_n)
	for (i in (1:int_n)) {
	  group_n <- paste0((i-1)*100+1," ~ ",i*100)
	  group <- c(group,group_n)
	}
	data <- cbind(data,NO,GROUP,LENGTH)
	data$GROUP=ordered(data$GROUP,levels=group)
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
print (paste0(">  OUTPUT: ",out_dir,"/",output_name,".",type_plot))


if (type_plot == "png") {
	png(paste0(out_dir, "/", output_name, ".png"),width=1000,height=1000,units="px")
} else {
	output_path <- paste0(type_plot,"(\"",out_dir,"/",output_name,".",type_plot,"\")")
	eval(parse(text = output_path))
}
p <- ggplot(data, aes(x=factor(NO), y=DEPTH)) + geom_boxplot(aes(fill=LENGTH)) + ylab("Depth") + xlab("") + ggtitle(paste0("Panel_Depth_Boxplot_",tools," (", sample, ")")) + scale_fill_continuous(low = "darkgreen", high = "red", space = "rgb") + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),axis.text.y=element_text(family="myFont2",face="bold",size=10,color="blue"),axis.text.x=element_text(family="myFont2",face="bold",size=8,angle=90,color="blue"),title=element_text(family="myFont2",face="bold",size=20),legend.title=element_text(family="myFont2",face="bold",size=10)) + facet_grid(data$GROUP~.)
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
