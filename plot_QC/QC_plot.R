#!/nfs2/pipe/Re/Software/miniconda/bin/Rscript --vanilla
# plot base content and Q30 along reads
# @wxian2016Aug10

# fix X11
options(bitmapType='cairo') 

argv <- commandArgs(TRUE)
if (length(argv) < 6) {
  cat (
    "Usage: Rscript $0 <sample_filterstat.txt> <sample_fqstat.txt> <sample_fq.txt> <sample_depth.txt> <sample_chr.txt> <sample_name> <out_dir>\n")
  q()
}

raw_data <- as.character(argv[1])
base_data <- as.character(argv[2])
q_data <- as.character(argv[3])
d_data <- as.character(argv[4])
c_data <- as.character(argv[5])
sample_name <- as.character(argv[6])
out_dir <- as.character(argv[7])
library("ggplot2")
library("reshape2")
library("grid")
library("gtable")


# plot raw data content
raw_reads <- read.table(raw_data, sep = "\t", stringsAsFactors =T)
data <- c(raw_reads[1,9]/raw_reads[1,2] * 100, raw_reads[1,6], raw_reads[1,8], raw_reads[1,5])
data_percentage <- round(data, 2)
df = data.frame(percentage = data_percentage, type = c('Clean Reads', 'Adapter Filter', 'Duplicated Filter', 'Low Quality Filter'))
myLabel <- as.vector(df$type)
myLabel <- paste(myLabel, '(', df$percentage,'%)', sep = "")
png(paste0(out_dir, '/', sample_name, ".raw_reads_composition.png"))
pie <- ggplot(df, aes(x = '', y = percentage, fill = type)) + geom_bar(stat = 'identity', width = 1) + coord_polar('y') + theme_bw() + labs(x = "", y = "", title = paste0("Classification of Raw Reads(", sample_name, ")")) + theme(text = element_text(family = "Arial"), plot.title = element_text(size = 16, face = "bold"), axis.ticks = element_blank(), axis.text.x = element_blank(), legend.title = element_blank(), legend.key = element_rect(linetype = 0)) + scale_fill_discrete(breaks = df$type, labels = myLabel) + theme(panel.grid = element_blank()) + theme(panel.border = element_blank()) 
print (pie)
dev.off()


# plot base content
# base_data="/lustre/project/og04/wangxian/snake_test/LYT-2B_fqstat.txt"
data_base <- read.table(base_data, sep = "\t", header = T, stringsAsFactors = T)
data_base1 <- melt(data_base, id.vars = "Posi")
png(paste0(out_dir, "/", sample_name, ".base_content.png"))
p <- ggplot(data_base1, aes(Posi, value)) +
  geom_line(aes(colour = variable), size = 0.75) +
  scale_y_continuous(limits = c(0, 50)) + scale_x_continuous(limits = c(0, 300), breaks = c(0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300)) + 
  ylab("Percentage (%)") + xlab("Position along reads") + scale_colour_hue(name ="type") + 
  ggtitle(paste0("Base content along reads(", sample_name, ")")) +
  theme(text = element_text(family = "Arial"), plot.title = element_text(size = 16, face = "bold"), legend.background = element_rect(fill = NA, colour = "black"), panel.background = element_rect(fill="grey90",colour = "black"), legend.title.align = 1, legend.title = element_text(face = "plain", size = 12), legend.text = element_text(size = 11), axis.title = element_text(size = 14), legend.key.height = unit(0.6, 'cm'), legend.key = element_rect(fill = "grey90"), legend.key.width = unit(1.2, 'cm'), plot.margin = unit(c(1, 0, 1, 0), "cm"), axis.text = element_text(colour = "black", size = 12), strip.background = element_rect(fill = NA, colour = NA), axis.ticks.length = unit(0.2, "cm")) +
  geom_vline(xintercept = 150.5, linetype = 2, colour = "black", size = 0.7)
print (p)
dev.off()


# plot the distribution of Quality
#q_data="/lustre/project/og04/wangxian/snake_test/LYT-2B_fastqc.txt"
data_q <- read.table(q_data, sep = "\t", header = T, stringsAsFactors = T)
png(paste0(out_dir, "/", sample_name, ".Quality_score.png"))
p <- ggplot(data_q, aes(Base, Quality)) +
  geom_line(colour = "blue", size = 1) + scale_y_continuous(limits =c(0, 50)) + 
  scale_x_continuous(limits = c(0, 300), breaks = c(0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300)) +
  ylab("Quality score") + xlab("Position along reads") +
  ggtitle(paste0("Quality score distribution along reads(", sample_name, ")")) +
  theme(text = element_text(family = "Arial"), plot.title = element_text(size = 16, face = "bold"), panel.background = element_rect(fill = "grey90",colour = "black"), plot.margin = unit(c(1, 0.8, 1, 0.8), "cm"), axis.text = element_text(colour = "black", size = 12), strip.background = element_rect(fill = "grey100", colour = NA), axis.ticks.length = unit(0.2, "cm")) +
  geom_vline(xintercept = 150.5, linetype = 2, colour = "black", size = 0.7)
print (p)
dev.off()


# plot the depth distribution
#d_data="/lustre/project/og04/wangxian/snake_test/LYT-2B_depth.txt"
data_d <- read.table(d_data, sep = "\t", header = T, stringsAsFactors = T)
max_y <- ceiling(max(data_d["Percent"]))
png(paste0(out_dir, "/", sample_name, ".Depth_distribution.png"))
p <- ggplot(data_d, aes(Depth, Percent)) +
  geom_point(colour = "blue", size = 1) + scale_y_continuous(limits = c(0, max_y)) + 
  ylab("Fraction of bases(%)") + xlab("sequence depth") +
  ggtitle(paste0("Distribution of sequence depth(", sample_name, ")")) +
  theme(text = element_text(family = "Arial"), plot.title = element_text(size = 16, face = "bold"), plot.margin = unit(c(1, 0.8, 1, 0.8), "cm"), axis.text = element_text(colour = "black", size = 12), panel.background = element_rect(fill = "grey90", colour = "black"), strip.background = element_rect(fill = "grey100", colour = NA), axis.ticks.length = unit(0.2, "cm"))
print (p)
dev.off()


## plot the cumulative depth distribution
png(paste0(out_dir, "/", sample_name, ".Cumulative_depth_distribution.png"))
p <- ggplot(data_d, aes(Depth, Accumulate_percent)) +
geom_line(colour = "blue", size = 1) + scale_y_continuous(limits = c(0, 100)) + 
  ylab("Fraction of bases(%)") + xlab("ccumulative sequence depth") +
  ggtitle(paste0("Distribution of cumulative sequence depth(", sample_name, ")")) +
  theme(text = element_text(family = "Arial"), plot.title = element_text(size = 16, face = "bold"), plot.margin = unit(c(1, 0.8, 1, 0.8), "cm"), axis.text = element_text(colour = "black", size = 12), panel.background = element_rect(fill = "grey90", colour = "black"), strip.background = element_rect(fill = "grey100", colour = NA), axis.ticks.length = unit(0.2, "cm"))
print (p)
dev.off()


grid.newpage()
#c_data="/lustre/project/og04/wangxian/snake_test/LYT-1T_chr.txt"
data_c= read.table(c_data, sep = "\t", header = T, stringsAsFactors = T)
chr=data_c[,1]
data_c$Chr <- ordered(data_c$Chr,chr)
#data_c[order(data_c$Chr),]
p1 <- ggplot(data_c) + geom_bar(aes(x = Chr, y = Depth),fill="red", stat = 'identity', colour = "red", width=0.5) + scale_y_continuous(limits = c(0, 100)) +  theme_bw() + ylab("Mean depth") + theme(panel.grid.major = element_line(colour = NA), panel.background = element_rect(fill = "grey90", colour = "black")) + ggtitle("每条染色体的平均覆盖深度柱状图（左）和覆盖率折线图（右）") 

p2 <- ggplot(data_c, aes(x = Chr, y = Cov, group = 1)) + geom_line(aes(y = Cov),colour="blue", size=1) + scale_y_continuous(limits = c(0, 100)) + theme_bw() %+replace% theme(panel.background = element_rect(fill = NA)) + ylab("Proportion of covered bases") + theme(panel.grid.minor = element_line(colour = NA))

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
ia <- which(g2$layout$name == "ylab")
ga <- g2$grobs[[ia]]
ga$rot <- 270
g <- gtable_add_cols(g, g2$widths[g2$layout[ia,]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ga, pp$t, length(g$widths) - 1, pp$b)
# draw it
png (paste0(out_dir, "/", sample_name, ".Coverage.png"))
grid.draw(g)
dev.off()
