#!/nfs/pipe/Re/Software/bin/Rscript --vanilla

argv <- commandArgs(TRUE)

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')
library("ggplot2")

in_data <- as.character(argv[1])
out_dir <- as.character(argv[2])

path <- strsplit(in_data,'/')[[1]]
file_name <- strsplit(path[length(path)],"\\.")[[1]]
sample <- file_name[1]

dd=read.table(in_data)
colnames(dd) <- c("insert_size", "pairs_total", "inward_oriented_pairs", "outward_oriented_pairs", "other_pairs")

sum_insert <- sum(dd$pairs_total)
dd100 <- subset(dd,dd$insert_size <= 100)
dd100_cent <- round(sum(dd100$pairs_total)/sum_insert*100,2)

dd200 <- subset(dd,(dd$insert_size > 100 & dd$insert_size <= 200))
dd200_cent <- round(sum(dd200$pairs_total)/sum_insert*100,2)

dd300 <- subset(dd,dd$insert_size > 200 & dd$insert_size <= 300)
dd300_cent <- round(sum(dd300$pairs_total)/sum_insert*100,2)

dd400 <- subset(dd,dd$insert_size > 300 & dd$insert_size <= 400)
dd400_cent <- round(sum(dd400$pairs_total)/sum_insert*100,2)

dd500 <- subset(dd, dd$insert_size > 400 & dd$insert_size <= 1000)
dd500_cent <- round(sum(dd500$pairs_total)/sum_insert*100,2)

dd1000 <- subset(dd, dd$insert_size > 1000)
dd1000_cent <- round(sum(dd1000$pairs_total)/sum_insert*100,2)

insert_size_cent <- c(sample,dd100_cent,dd200_cent,dd300_cent,dd400_cent,dd500_cent,dd1000_cent)
output <- data.frame(insert_size_cent)
output_cent_path <- paste0(out_dir,"/",sample,".cent.tsv")
write.table(output,output_cent_path,row.names = F,quote=FALSE,sep="\t")

dd_1000 <- dd[1:1000,]

out_path <- paste0(out_dir,"/",sample,".png")
png(out_path,width=1000,height=1000,units="px")
p <- ggplot(dd_1000) + geom_line(aes(x = insert_size, y = pairs_total)) + ggtitle(paste0(sample,"( <100:",dd100_cent,"%; 100~200: ",dd200_cent,"%; 200~300: ",dd300_cent,"%; 300~400: ",dd400_cent,"%; 400~1000: ",dd500_cent,"%; >1000: ",dd1000_cent,"%)"))
print (p)
dev.off()
