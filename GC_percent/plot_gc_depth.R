#!/nfs/pipe/Re/Software/bin/Rscript --vanilla

# plot gc content and depth & export abnormal results
# @wxian2017Feb17

argv <- commandArgs(TRUE)
if (length(argv) == 0) {
	cat ("Usage: /PATH/plot_gc_content.R <input_file> <out_dir> <pic_name> <image_type(boxplot/scatter/all)> <standard_panel_gc> <abnormal_status(1/2/3)> \n")
	q()
}

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
library("ggplot2")
options(bitmapType='cairo')
data_path <- as.character(argv[1])
#data_path="/lustre/project/og04/pub/pipeline/plot_gc_depth/CA-PM-201701_CFD/CA-PM.gc_depth_20170227_162520.txt"
out_dir <- as.character(argv[2])
name <- as.character(argv[3])
image <- as.character(argv[4])
standard_path <- as.character(argv[5])
AB <- as.numeric(argv[6])
#standard_path <- "/lustre/project/og04/pub/pipeline/plot_gc_depth/panel_design.txt"


if (!file.exists(out_dir) ) {
	dir.create(out_dir)
}

if (AB == 1 | AB == 3) {
  print (">> preparing data for plotting gc and depth")
  data_panel <- read.table(data_path)
  colnames(data_panel)=c("project","sample","chr","start","end","index","depth","gc")
  data_panel$gc_stand <- NA
  data_panel$length <- 0     
  data_panel$bed_deep <- NA
  if (!is.numeric(data_panel$gc)) {
    data_panel <- subset(data_panel,gc != "-")
    data_panel$gc <- as.numeric(levels(data_panel$gc)[data_panel$gc])
  }
  project_data_panel <- table(data_panel$project)
  length_project_data_panel <- length(project_data_panel)
 # if ( length_project_data_panel == 1) {
 #   sample_data_panel <- table(data_panel$sample)
 #   data_panel$color <- rep(c(1:length(sample_data_panel)),sample_data_panel)
 # } else {
 #   data_panel$color <- rep(c(1:length(project_data_panel)),project_data_panel)
 # }
  
  standard <- read.table(standard_path)
  standard$panel <- paste0(standard$V1,standard$V2,standard$V3)
  standard$depth <- NA
  standard$project="STANDARD"
  standard$sample="standard"
  standard$gc <- NA
  standard <- data.frame(standard$project,standard$sample,standard$V1,standard$V2,standard$V3,standard$panel,standard$depth,standard$gc,standard$V4)
  #standard$color <- NA
  colnames(standard) <- c("project","sample","chr","start","end","index","depth","gc","gc_stand")
  chr_name <- c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y")
  bed_length <- sapply (chr_name,function(x) {
    chr_standard <- subset(standard,chr==x)
    all_po <- c(chr_standard$start,chr_standard$end)
    rank_po <- order(all_po)-nrow(chr_standard)  
    rank_po <- data.frame(rank_po)
    po_end <- subset(rank_po,rank_po>0)
    rank_end <- as.numeric(row.names(po_end))-2*po_end
  })
  all_bed_length <- c()
  for (i  in 1:24) {
    all_bed_length <- c(all_bed_length,bed_length[[i]])
  }
  standard$length <- all_bed_length
  n=1
  bed_deep <- rep(NULL,length(all_bed_length))
  if (all_bed_length[1]==0){
    bed_deep[1] <- 0  
  } else {
    bed_deep[1] <- 1
  }
  
  for ( i in 2:length(all_bed_length)) {
    if (all_bed_length[i-1] == 0 ) {
      n <- 1
    } else {
      n <- n+1
    }
    if (all_bed_length[i] != 0) {
      bed_deep[i] <- n
    } else {
      bed_deep[i] <- 0
    }
  }
  standard$bed_deep <- bed_deep
  
  data_all <- rbind(data_panel,standard)
  data_all$chr <- ordered(data_all$chr,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))
  data_all <- data_all[order(data_all$chr,data_all$start),]
  #panel_bed_index <- unique(data_all[,2:4])
  #panel_bed_index$no <- c(1:nrow(panel_bed_index))
  #panel_bed_index <- panel_bed_index[,c(4,1,2,3)]
  #output_index <- paste0(out_dir, "/index_panel_design.bed")
  #write.table(panel_bed_index,output_index,row.names = F,quote=FALSE,sep="\t")
  
  index_uniq <- unique(data_all$index)
  data_all$index <-  ordered(data_all$index,levels=index_uniq)
  data_index <- table(data_all$index)
  nu_data_index <- length(data_index)
  data_all$panel <- rep(c(1:nu_data_index),data_index)
  
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
  data_all$no_end <- data_all$no+data_all$length
  rm(data_panel,standard)
  data_sample <- data_all[complete.cases(data_all$gc),]
  data_standard <- data_all[complete.cases(data_all$gc_stand),]
  if (length_project_data_panel == 1) {
    #    label_legend <- unique(data_all$sample)
    name_legend <- "Sample"
    data_sample$project <- data_sample$sample
  } else {
    #    label_legend <- unique(data_all$project) 
    name_legend <- "Project_ID"
  }
  
  print (paste0(">> plotting ",image, " : gc and depth"))
  output_gc <- paste0(out_dir, "/", name)
  png(output_gc,width=2000,height=4000,units="px")
  if (image == "boxplot") {
    p1 <- ggplot() + geom_boxplot(data=data_sample,aes(x=as.factor(no),y=gc)) + geom_boxplot(data=data_sample,aes(x=as.factor(no),y=-10*log10(depth))) + geom_point(data=data_standard, aes(x=no,y=gc_stand),color="red",size=3,pch=17) + geom_segment(data=data_standard, aes(x= no, xend=no_end, y=bed_deep, yend=bed_deep),color="blue",size=1) + facet_grid(group~., scales = c('free')) + ylab("Depth and GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10)) 
  } else if (image == "violin") {
    p1 <- ggplot() + geom_violin(data=data_sample,aes(x=as.factor(no),y=gc)) + geom_violin(data=data_sample,aes(x=as.factor(no),y=-10*log10(depth))) + geom_point(data=data_standard,aes(x=no,y=gc_stand),color="red",size=3,pch=17) + geom_segment(data=data_standard,aes(x= no, xend=no_end, y=bed_deep, yend=bed_deep),color="blue",size=1) + facet_grid(group~., scales = c('free')) + ylab("Depth and GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.title=element_text(face="bold",size=10))
  } else if (image == "scatter") {
    p1 <- ggplot() + geom_jitter(data=data_sample,aes(x=no,y=gc,color=as.factor(project)),alpha = 0.3,size=1.5) + geom_jitter(data=data_sample,aes(x=no,y=-10*log10(depth),color=as.factor(project),fill=as.factor(project)),alpha = 0.3,size=1.5,pch=23) + geom_point(data=data_standard,aes(x=no,y=gc_stand),color="red",size=3,pch=17) + geom_segment(data=data_standard, aes(x= no, xend=no_end, y=bed_deep, yend=bed_deep),color="blue",size=1) + facet_grid(group~., scales = c('free')) + ylab("Depth and GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.position="right",legend.direction="vertical",legend.title=element_text(face="bold",size=10)) + labs(fill=name_legend) + labs(color=name_legend)
  } else if (image == "all") {
    p1 <- ggplot() + geom_violin(data=data_sample,aes(x=as.factor(no),y=gc)) + geom_jitter(data=data_sample,aes(x=no,y=gc,color=as.factor(project)),alpha = 0.3,size=1.5)  + geom_violin(data=data_sample,aes(x=as.factor(no),y=-10*log10(depth))) + geom_jitter(data=data_sample,aes(x=no,y=-10*log10(depth),color=as.factor(project),fill=as.factor(project)),alpha = 0.3,size=1.5,pch=23) + geom_point(data=data_standard,aes(x=no,y=gc_stand),color="red",size=3,pch=17) + geom_segment(data=data_standard,aes(x= no, xend=no_end, y=bed_deep, yend=bed_deep),color="blue",size=1) + facet_grid(group~., scales = c('free')) + ylab("Depth and GC_percent(%)") + xlab("Designed_panel") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.position="right",legend.direction="vertical",legend.title=element_text(face="bold",size=10))  + labs(fill=name_legend) + labs(color=name_legend)
  }
  print (p1)
  dev.off()
}  



# === plot the relationshaip between change of GC_content and depth in panel and abnormal results
if (AB == 2 | AB == 3) {
  print (">> preparing data for abnormal results")
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
    chr_cfd_data <- chr_cfd[,c(3,4,5,1,2,9,7,8)]
    colnames(chr_cfd_data) <- c("chr","start","end","project","sample","index","depth","gc")
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
  
  # summary abnormal needle
  print (">> export abnormal results of each needle")
  mean_depth <- mean(gc_ch_all$depth)
  sd_depth <- var(gc_ch_all$depth)
  gc_ch_all$lower_depth <- mean_depth*0.8
  gc_ch_all$upper_depth <- mean_depth*3
  abnormal_data <- subset(gc_ch_all,depth < lower_depth | depth > upper_depth | gc_ch < -2 | gc_ch > 2)
  needle_name <- unique(abnormal_data$index)
  abnormal_report <- lapply(needle_name, function(x){
    needle_abnormal <- subset(abnormal_data,index == x)
    chr <- needle_abnormal$chr[1]
    start <- needle_abnormal$start[1]
    end <- needle_abnormal$end[1]
    sample_all <- nrow(needle_abnormal)
    gc_lower <- length(needle_abnormal$gc_ch[needle_abnormal$gc_ch < -2])
    gc_upper <- length(needle_abnormal$gc_ch[needle_abnormal$gc_ch > 2])
    depth_lower <- length(needle_abnormal$depth[needle_abnormal$depth < needle_abnormal$lower_depth])
    depth_upper <- length(needle_abnormal$depth[needle_abnormal$depth > needle_abnormal$upper_depth])
    output_report <- data.frame(x,chr,start,end,sample_all,gc_lower,gc_upper,depth_lower,depth_upper)
    return(output_report)
  })
  out_abnormal_report <- do.call(rbind,abnormal_report)
  colnames(out_abnormal_report) <- c("needle","chr","start","end","sample","gc_lower","gc_upper","depth_lower","depth_upper")
  output_report_path <- paste0(out_dir,"/abnormal_needle_summary.txt")
  write.table(out_abnormal_report,output_report_path,col.names = TRUE, row.names= FALSE,quote=F,sep="\t")
  
  print (">> plotting abnormal results after filtering")
  project_sample <- unique.array(gc_ch_all[,c(4,5)])
  sample_nu <- table(project_sample$project)
  #sample_nu <- ceiling(table(gc_ch_all$project)/length(unique(gc_ch_all$index)))
  abnormal_needle <- lapply(needle_name, function(x){
    needle_abnormal <- subset(abnormal_data,index == x)
    needle_project_abnormal <- table(needle_abnormal$project)
    needle <- rep(x,length(needle_project_abnormal))
    out_needle <- data.frame(needle,needle_project_abnormal,sample_nu)
    return(out_needle)
  })
  out_abnormal_needle <- do.call(rbind,abnormal_needle)
  colnames(out_abnormal_needle) <- c("needle","project_id","changed_sample","checked_project_id","all_sample")
  check_out_abnormal_needle <- subset(out_abnormal_needle,project_id == checked_project_id)
  
  if (nrow(out_abnormal_needle) != nrow(check_out_abnormal_needle)) {
    print ("!Error: confused project_id")
    q()
  }
  rm(check_out_abnormal_needle)
  project_nu_all <- length(unique(out_abnormal_needle$project_id))
  plot_abnormal_needle <- subset(out_abnormal_needle, changed_sample > all_sample/2)
  plot_abnormal_needle$change_project <- rep(table(plot_abnormal_needle$needle),table(plot_abnormal_needle$needle))
  plot_abnormal_needle <- subset(plot_abnormal_needle, change_project > project_nu_all*0.8)
  uniq_needle <- unique(plot_abnormal_needle$needle)
  out_needle <- subset(out_abnormal_report,out_abnormal_report$needle %in% uniq_needle)
  
  output_plot_path <- paste0(out_dir,"/abnormal_needle_output.txt")
  write.table(out_needle,output_plot_path,col.names = TRUE, row.names= FALSE,quote=F,sep="\t")
  
  output_needle <- paste0(out_dir,"/abnormal_needle.png")
  png(output_needle,width=2000,height=1200,units="px")
  p_n <- ggplot(plot_abnormal_needle) + geom_point(aes(x=needle,y=project_id,color=changed_sample))  + ggtitle("Abnormal_needles") + ylab("Project") + xlab("Needles") + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=10,color="black"),axis.text.x=element_text(face="bold",size=8,angle=90,color="black"),title=element_text(face="bold",size=20),legend.position="right",legend.direction="vertical",legend.title=element_text(face="bold",size=10))
  print (p_n)
  dev.off()
  
  # plotting
  
  print (">> ploting relationship between depth and GC_change")
  output_path1 <- paste0(out_dir,"/depth_gc-change.png")
  output_path2 <- paste0(out_dir,"/depth_gc.png")
  
  png(output_path1,width=2000,height=2500,units="px")
  #p1 <- ggplot(gc_ch_all) + geom_point(aes(x=gc_ch,y=depth,color=as.factor(project)),size=1,alpha=0.3) + facet_grid(chr~.) + ylab("Depth") + xlab("GC - GC_standard (%)")  + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=15,color="black"),axis.text.x=element_text(face="bold",size=15,color="black"),legend.position="right",legend.direction="vertical",legend.title=element_text(face="bold",size=10)) 
  p1 <- ggplot(gc_ch_all) + geom_point(aes(x=gc_ch,y=log(depth),color=as.factor(project)),size=1,alpha=0.3) + ylab("log ( Depth )") + xlab("GC - GC_standard (%)")  + theme(axis.title.x=element_text(face="bold",size=15),axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=15,color="black"),axis.text.x=element_text(face="bold",size=15,color="black"),legend.position="right",legend.direction="vertical",legend.title=element_text(face="bold",size=10)) + labs(title = 'log(Depth) ~ GC_change') + labs(colour = "Project_id")
  print (p1)
  dev.off()
  
  
  png(output_path2,width=2000,height=2500,units="px")
  #p2 <- ggplot(gc_ch_all) + geom_point(aes(x=gc,y=depth,color=as.factor(project)),size=1,alpha=0.3) + facet_grid(chr~.) + ylab("Depth") + xlab("GC_content (%)")  + theme(axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=15,color="black"),axis.text.x=element_text(face="bold",size=15,color="black"),legend.position="right",legend.direction="vertical",legend.title=element_text(face="bold",size=10)) 
  p2 <- ggplot(gc_ch_all) + geom_point(aes(x=gc,y=log(depth),color=as.factor(project))) + ylab("log ( Depth )") + xlab("GC (%)")  + theme(axis.title.x=element_text(face="bold",size=15),axis.title.y=element_text(face="bold",size=15),axis.text.y=element_text(face="bold",size=15,color="black"),axis.text.x=element_text(face="bold",size=15,color="black"),legend.position="right",legend.direction="vertical",legend.title=element_text(face="bold",size=10)) + labs(fill="Project_id") + labs(title = 'log(Depth) ~ GC') + labs(colour = "Project_id")
  print (p2)
  dev.off()
}




  
  



