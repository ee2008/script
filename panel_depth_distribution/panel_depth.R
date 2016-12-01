#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# plot average depth in panel
# @wxian2016Nov29

argv <- commandArgs(TRUE)
if (length(argv) < 3) {
  cat (
    "Usage: Rscript $0 <sample_samtools_depth_bed.txt> <panel.bed> <out_dir>\n")
  q()
}

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')
library("ggplot2")
library("grid")
library("gtable")

in_data <- as.character(argv[1])
in_panel_data <- as.character(argv[2])
out_dir <- as.character(argv[3])
if (!file.exists(out_dir) ) {
  dir.create(out_dir)
}

path <- strsplit(in_data,'/')[[1]]
file_name <- strsplit(path[length(path)],"\\.")[[1]]
sample=file_name[1]

#in_data="/p299/user/og04/wangxian/CA-PM/CA-PM-20161108_v5/qc/panel/OG165740011T1LEUD.samtools_depth_bed.txt"
#in_panel_data="/lustre/project/og04/pub/database/panel_ca_pm/panel.bed"

data <- read.table(in_data,header=F)
colnames(data) <- c("chr","po","depth")
depth_chr <- tapply(data$depth,data$chr,sum)
no_chr <- table(data$chr)
mean_depth <- depth_chr/no_chr

panel_data <- read.table(in_panel_data,header=F)[,1:3]
colnames(panel_data) <- c("chr","start","end")
panel_data$count <- panel_data$end-panel_data$start+1
range_panel <- tapply(panel_data$count,panel_data$chr,sum)
cov_panel <- no_chr/range_panel*100

out_data <- data.frame(mean_depth,cov_panel)
data_p <- out_data[,-3]
colnames(data_p)=c("Chr","Depth","Cov")

grid.newpage()
#chr=data_p[,1]
#data_p$Chr <- ordered(data_p$Chr,chr)
#data_p[order(data_p$Chr),]
p1 <- ggplot(data_p,aes(Chr,weight=Depth))+geom_bar(position="identity",fill="red",width=0.6) + theme_bw() + ylab("Mean depth") + theme(panel.grid.major = element_line(colour = NA), panel.background = element_rect(fill = "grey90", colour = "black")) + ggtitle(paste0("Mean Depth(left) and Coverage(right) in panel (",sample,")")) 


p2 <- ggplot(data_p, aes(x = Chr, y = Cov, group = 1)) + geom_line(aes(y = Cov),colour="blue", size=0.5) + scale_y_continuous(limits = c(0, 100)) + theme_bw() %+replace% theme(panel.background = element_rect(fill = NA)) + ylab("Proportion of covered bases") + theme(panel.grid.minor = element_line(colour = NA))

# extract gtable
g1 <- ggplot_gtable(ggplot_build(p1))
g2 <- ggplot_gtable(ggplot_build(p2))

# overlap the panel of 2nd plot on that of 1st plot
pp <- c(subset(g1$layout, name == "panel", se = t:r))
g <- gtable_add_grob(g1, g2$grobs[[which(g2$layout$name == "panel")]], pp$t, pp$l, pp$b, pp$l)

# axis tweaks
ia <- which(g2$layout$name == "axis-l")
ga <- g2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(1, "npc") + unit(0.15, "cm")
g <- gtable_add_cols(g, g2$widths[g2$layout[ia,]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)
ia <- which(g2$layout$name == "ylab-r")
ga <- g2$grobs[[ia]]
ga$rot <- 270
g <- gtable_add_cols(g, g2$widths[g2$layout[ia,]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ga, pp$t, length(g$widths) - 1, pp$b)
# draw it

#pdf (paste0(out_dir, "/", sample, "_depth_coverage.pdf"))
#grid.draw(g)
#dev.off()




