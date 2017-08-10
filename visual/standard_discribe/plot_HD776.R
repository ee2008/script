#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
# discribe the PPV NPV of standard

# @wxian2017JUN30

out_dir="/lustre/project/og04/wangxian/visual_test/standard_discribe"
.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')
library(ggplot2)

# HD778
library("grid")
library("gtable")
grid.newpage()
path_data <- "/lustre/project/og04/wangxian/visual_test/standard_discribe/HD776.txt"
dd_raw <- read.table(path_data, sep = "\t", header = T, stringsAsFactors = T)
dd <- stack(dd_raw)
colnames(dd) <- c("fre","gene")
dd_raw_nrow <- nrow(dd_raw)
dd$standard <- rep(c(0,0,0,0,0,0,0,0),rep(dd_raw_nrow,ncol(dd_raw)-1))

NPV_fre <- rep(100,ncol(dd_raw)-1)
NPV_name <- colnames(dd_raw)[-1]
NPV <- data.frame(NPV_name,NPV_fre)


p1 <- ggplot(dd) + geom_point(aes(x = gene, y = fre), colour = "black", size = 2)  + theme_bw() + ylab("Alt_Fre") + theme(panel.grid.major = element_line(colour = NA), panel.background = element_rect(fill = "grey90", colour = "black")) + ggtitle("HD776") + geom_point(aes(x = gene, y = standard), colour = "red", size = 3, pch = 17) + theme(axis.text.x=element_text(size=10,angle=90,color="black"))

p2 <- ggplot(NPV, aes(x = NPV_name, y = NPV_fre, group = 1)) + geom_bar(aes(x = NPV_name, y = NPV_fre),fill="blue", stat = 'identity',  width=0.2, alpha = 0.2) + scale_y_continuous(limits = c(0, 100)) + theme_bw() %+replace% theme(panel.background = element_rect(fill = NA),panel.grid.major = element_blank()) + ylab("Frequency") + theme(panel.grid.minor = element_line(colour = NA)) + geom_text(aes(label = paste0(NPV_fre,"%")))


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
ia <- which(g2$layout$name == "ylab-l")
ga <- g2$grobs[[ia]]
ga$rot <- 270
g <- gtable_add_cols(g, g2$widths[g2$layout[ia,]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ga, pp$t, length(g$widths) - 1, pp$b)
# draw it
png (paste0(out_dir, "/", "HD776.png"))
grid.draw(g)
dev.off()






