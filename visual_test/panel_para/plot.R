#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# @wxian2017AUG07

argv <- commandArgs(TRUE)
if (length(argv) == 0) {
  cat ("Usage: /PATH/plot.R <para_value.txt> <out_dir>\n")
  q()
}
.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')

input <- as.character(argv[1])
#input <- "/lustre/project/og04/wangxian/1705wxVisual/panel_para/data_example.txt"
out_dir <- as.character(argv[2])
if (!file.exists(out_dir) ) {
  dir.create(out_dir)
}


ddd <- read.csv(input,sep="\t",header=F)
colnames(ddd) <- c("para","val")

#a <- c("coverage","mapping","specificity","uniformity")
#b <- c(99.9,99.8,68,99.1)
#dd <- data.frame(a,b)

f<-function(info,percent){  
  r=20
  plot(0,0,xlab="",ylab="",axes=FALSE,xlim=c(-r,r),ylim=c(-r,r),col=0)  
  k = (1:(360*percent/100)*10)/10  
  #print(r)  
  x = r*sin(k/180*pi)  
  y = r*cos(k/180*pi)  
  text(-5,0,info, pos=3,cex=1.5)  
  text(6,0,paste(percent,"%"),pos=3, cex=1.5)  
  k_s = c(1:360)
  x_s = r*sin(k_s/180*pi)
  y_s = r*cos(k_s/180*pi)
  lines(x_s,y_s,col=rgb(155, 0, 0, 60, maxColorValue=255), lwd=30) +
  lines(x,y,col=rgb(255, 0, 0, 80, maxColorValue=255), lwd=30)  
}  

for(i in 1:nrow(ddd)){
  name <- ddd$para[i]
  value <- ddd$val[i]
  png(paste0(out_dir, "/",name,"_panel_para_circle.png"),width=512,height=512,units="px")
  f(name,value)  
  dev.off()
}
