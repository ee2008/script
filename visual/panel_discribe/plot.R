#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# plot gene in panel
# @wxian2017JUN28
argv <- commandArgs(TRUE)

if (length(argv) == 0) {
  cat ("Usage: $0 <gene_name> <out_dir>\n")
  q()
}

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
library("ggplot2")  
options(bitmapType='cairo')

# ref file
GFF3 <- "/lustre/project/og04/wangxian/visual_test/panel_discribe/gff3_final.tsv"
PANEL_BED <- "/lustre/project/og04/wangxian/visual_test/panel_discribe/panel_bed_final.tsv"
PANEL_INFO <- "/lustre/project/og04/wangxian/visual_test/panel_discribe/panel_info_final.tsv"


# parameter
gene_i <- as.character(argv[1])
out_dir <- as.character(argv[2])
if (!file.exists(out_dir) ) {
	dir.create(out_dir)
}

gff <- read.table(GFF3,sep="\t",header = T)
#colnames(gff) <- c("chr","source","record","start","end","other1","other2","other3","info")
#gff1=gff[3:10,]
#gff2=gff[5:7,]
panel_bed <- read.table(PANEL_BED,sep="\t",header = T)
panel_info <- read.table(PANEL_INFO,sep="\t",header = T)


gff1 <- subset(gff,GENE==gene_i)
panel_bed1 <- subset(panel_bed,GENE==gene_i)
panel_info1 <- subset(panel_info,gene==gene_i)
exon_factor_gff <- unique(as.character(gff1$EXON))
exon_factor_panel_bed <- unique(as.character(panel_bed1$EXON))
panel_bed1$EXON <- ordered(panel_bed1$EXON,levels=exon_factor_panel_bed)
panel_info1$EXON <- ordered(panel_info1$EXON,levels=exon_factor_gff)
gff1$EXON <- ordered(gff1$EXON,levels=exon_factor_gff)

out_path <- paste0(out_dir, "/", gene_i,".png")
png(out_path,width=3000,height=1000,units="px")
#out_path <- paste0(out_dir, "/", gene_i,".svg")
#svg(out_path)
p <- ggplot() + geom_segment(data=gff1, aes(x=gff1$START, xend=gff1$END, y=1, yend=1), color="blue", alpha = 0.2, size=2)  + 
  scale_y_continuous(limits=c(1,1.02)) + 
  theme(legend.position="none", panel.grid =element_blank(), axis.text.x=element_text(face="bold",size=8,angle=90,color="black"), axis.text.y = element_blank(), axis.ticks.y = element_blank(), axis.title.y = element_blank(), panel.background = element_blank()) + xlab("Position") + labs(title=gene_i) + 
  geom_segment(data=panel_bed1, aes(x=panel_bed1$start, xend=panel_bed1$end, y=1, yend=1), color="red", alpha = 0.3, size=2) + 
  geom_segment(data=panel_info1, aes(x=panel_info1$start, xend=panel_info1$end, y=1, yend=1), color="black", alpha = 1, size=2) + geom_text(data=panel_info1,aes(x=panel_info1$start,y=1.01,label=p_anno),size=4,angle = 90) +
  facet_wrap(~EXON, scales = c('free'),ncol=3) 
print (p)  
dev.off()
#ggplot() + geom_segment(aes(x=gff1$start, xend=gff1$end, y=1, yend=1), color="red", alpha = 0.3, size=2) + geom_text(data=gff1,aes(x=start,y=1.1,label=record),angle = 45) + scale_y_continuous(limits=c(1,1.1)) + theme(legend.position="none", panel.grid =element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank(), axis.title.y = element_blank(), panel.background = element_blank()) + labs(title="EGFR") + geom_segment(aes(x=gff2$start, xend=gff2$end, y=1.02, yend=1.02), color="grey20", alpha = 0.2, size=2)



