data_path="/p299/user/og04/wangxian/CA-PM/depth_plot/all.abnormal_bedtools.bed"
data=read.table(data_path,sep="\t")
colnames(data) <- c("project","project_id","sample","sample_id","chr","start","end")
data$chr=ordered(data$chr,levels=c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"))

plot_abnormal <- function (input_data,C) {
  input_data$length <- input_data$end-input_data$start+1
  PO_n=rep(NULL,sum(input_data$length))
  p <- 0
  for (i in 1:nrow(input_data)) {
    left <- p+1
    p <- p+input_data[i,8]
    PO_n[left:p] <- c(input_data[i,6]:input_data[i,7])
  }
  PROJECT <- rep(as.character(input_data$project),input_data$length)
  SAMPLE_ID <- rep(input_data$sample_id,input_data$length)
  CHR <- rep(input_data$chr,input_data$length)
  PO <- as.factor(PO_n)
  data_plot <- data.frame(PROJECT,SAMPLE_ID,CHR,PO)
  color_lib=rainbow(max(SAMPLE_ID))
  po_x <- sort(unique(PO_n))
  n <- floor(length(po_x)/120)
  po_x_length <- floor(length(po_x)/n)
  po_x_cent <- rep(NA,po_x_length)
  for (j in (1:po_x_length)) {
    po_x_cent[j] <-po_x[(j*n)]
  }
  po_x_cent_name <- as.factor(po_x_cent)
  ggplot(data_plot,aes(PO,SAMPLE_ID)) + geom_point(colour = color_lib[data_plot$SAMPLE_ID], size=0.5) + ylab("") + xlab("")   + theme(axis.title.y=element_text(family="myFont2",face="bold",size=15),title=element_text(family="myFont2",face="bold",size=20)) + facet_grid(data_plot$PROJECT~.) + scale_x_discrete(breaks = po_x_cent_name) + theme(axis.text.x=element_text(family="myFont2",face="bold",size=10,angle=90,color="blue")) + ggtitle(paste0("CA-PM(chr",C,")"))
}



chr_name <- c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y")
for (i in chr_name) {
  eval (parse(text=paste0("data","_",i,"<-", "subset(data, data$chr == i)"))) 
  eval (parse(text=paste0("p = plot_abnormal(","data","_",i,",","i",")")))
  png(paste0("/p299/user/og04/wangxian/CA-PM/depth_plot/plot/plot_chr", i, ".png"),width=2000,height=2000,units="px")
  print (p)
  dev.off()
  #svg(paste0("/p299/user/og04/wangxian/CA-PM/depth_plot/plot/plot_chr", i, ".svg"))
  #print (p)
  #dev.off()
}
