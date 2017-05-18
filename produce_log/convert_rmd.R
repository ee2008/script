#!/usr/bin/env Rscript

# @szj^16Dec20

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')
#library(knitr)
#library(rticles)
#input_path="/lustre/project/og04/wangxian/all_qc_stats/all_qc_stats.tsv"


input_file <- commandArgs(T)[1]
output_file <- commandArgs(T)[2]
input_path <- commandArgs(T)[3]

if (! file.exists(input_file)) {
    message("! not valid input file: ", input_file)
    quit('no')

}
#knit2html(input_file,output=output_file)
rmarkdown::render(commandArgs(T)[1], output_format = "html_document", output_file = output_file)
