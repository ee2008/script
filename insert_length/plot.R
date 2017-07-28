#!/nfs2/pipe/Re/Software/miniconda/bin/Rscript --vanilla

library("ggplot2")
options(bitmapType='cairo')
argv <- commandArgs(TRUE)


if (length(argv) < 2) {
  cat (
    "Usage: Rscript $0 <*.insert_size.txt> <out_dir>\n")
  q()
}

input <- as.character(argv[1])
#input="/lustre/project/og04/wangxian/pipeline_script/insert_length/1715Y1kx11b_tem.txt"
out_dir <- as.character(argv[2])

path <- strsplit(input,'/')[[1]]
file_name <- strsplit(path[length(path)],"\\.")[[1]]
sample=file_name[1]

in_data <- read.table(input,sep="\t")
colnames(in_data) <- c("insert_size","count")
insert_sum <- sum(in_data$count)
dd_100 <- subset(in_data,insert_size <= 100)
insert_100 <- round(sum(dd_100$count)/insert_sum*100,2)

dd_100_200 <- subset(in_data,insert_size > 100 & insert_size <= 200 )
insert_100_200 <- round(sum(dd_100_200$count)/insert_sum*100,2)

dd_200_300 <- subset(in_data,insert_size > 200 & insert_size <= 300 )
insert_200_300 <- round(sum(dd_200_300$count)/insert_sum*100,2)

dd_300_1000 <- subset(in_data,insert_size > 300 & insert_size <= 1000 )
insert_300_1000 <- round(sum(dd_300_1000$count)/insert_sum*100,2)

dd_1000 <- subset(in_data,insert_size > 1000)
insert_1000 <- round(sum(dd_1000$count)/insert_sum*100,2)

title <- paste0(out_dir, '/', sample, " (<100: ",insert_100,"%; 100~200: ", insert_100_200, "%; 200~300: ", insert_200_300, "%; 300~1000: ", insert_300_1000, "%; >1000: ", insert_1000, ")")

dd_plot <- subset(in_data,insert_size <= 1000)
png(paste0(out_dir, '/', sample, "insert_size.png"))  
p <- ggplot(dd_plot) + geom_line(aes(x=insert_size,y=count)) + ggtitle(paste0(sample, " (<100: ",insert_100,"%; 100~200: ", insert_100_200, "%; 200~300: ", insert_200_300, "%; 300~1000: ", insert_300_1000, "%; >1000: ", insert_1000, ")"))
print (p)
dev.off()
