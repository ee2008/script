# merge gene data
# @wxian 2016Feb22

# == path
GENE="/lustre/project/og04/pub/database/onco_panel/gene"
ANNO="/lustre/project/og04/shenzhongji/human_tumor/QuanlityAssessment/anno/"
OUTPUT="/lustre/project/og04/wangxian/"

# == file_prefix
FILE_1="ck."
FILE_2="ck-VS-mut1."
FILE_3="ck-VS-mut2."
FILE_4="ck-VS-mut3."
FILE_5="ck-VS-mut4."
FILE_6="ck-VS-mut5."
FILE_7="ck-VS-mut6."
FILE_8="ck-VS-mut7."
FILE_9="ck-VS-mut8."
FILE_10="germ1."
FILE_11="germ2."
FILE_12="mut1."
FILE_13="mut2."
FILE_14="mut3."
FILE_15="mut4."
FILE_16="mut5."
FILE_17="mut6."
FILE_18="mut7."
FILE_19="mut8."
FILE=c(FILE_1,FILE_2,FILE_3,FILE_4,FILE_5,FILE_6,FILE_7,FILE_8,FILE_9,FILE_10,FILE_11,FILE_12,FILE_13,FILE_14,FILE_15,FILE_16,FILE_17,FILE_18,FILE_19)
#FILE=c("mut8.")

# == file_format
SV_SNPEFF="sv.snpeff.vcf"
INDEL_ANNODB="var.annodb.indel.exome_summary.csv"
SNP_ANNODB="var.annodb.snp.exome_summary.csv"
CLINVAR_ANNOVAR="var.annovar.hg19_clinvar_20150629_dropped"
COSMIC70_ANNOVAR="var.annovar.hg19_cosmic70_dropped"
VAR_ONCOTATOR="var.oncotator.vcf"
VAR_SNPEFF="var.snpeff.vcf"

gene=data.frame(read.table(GENE))
num.gene=as.numeric(nrow(gene))

for (i in FILE) {
  ## == find gene in var.snpeff.vcf
  file.var.snpeff <- paste0(ANNO,i,VAR_SNPEFF)
  output.name=paste0(OUTPUT,i,VAR_SNPEFF,".gene.csv")
  output=data.frame()
  con <- file(file.var.snpeff,"r")
  line.var.snpeff <- readLines(con,n = 1)
  while( length(line.var.snpeff) != 0 ) {
    if (substr(as.character(line.var.snpeff),1,1) != "#") {
      row.var.snpeff <- strsplit(as.character(line.var.snpeff),"\t")[[1]]
      info.var.snpeff <- strsplit(row.var.snpeff[8],";")[[1]]
      ANN.var.snpeff <- strsplit(info.var.snpeff[length(info.var.snpeff)],",")[[1]]
      for (j in 1:length(ANN.var.snpeff)) {
        gene.var.snpeff <- strsplit(ANN.var.snpeff[j],"\\|")[[1]][4]
        for (k in 1:num.gene) {
          gene.ob=as.character(gene[k,1])
          if (gene.var.snpeff == gene.ob) {
            row=data.frame(line.var.snpeff)
            output=rbind(output,row)
            break
          }
        }
        if (gene.var.snpeff == gene.ob) 
          break 
      }
    }
    line.var.snpeff <- readLines(con, n = 1)
  }
  close(con)
  write.table(output,output.name,row.names=FALSE,col.name=FALSE)
  result=data.frame()
  con1 <- file(output.name,"r")
  line.var.snpeff <- readLines(con1,n = 1)
  while (length(line.var.snpeff) != 0) {
    row.var.snpeff  <- strsplit(as.character(line.var.snpeff ),"\t")[[1]]
    po.ref <- strsplit(row.var.snpeff[2],";")[[1]]
    po.output=data.frame(line.var.snpeff)
    
    # == find position in var.annodb.indel.exome_summary.csv
    file.var.indel.annodb <- paste0(ANNO,i,INDEL_ANNODB)
    con2 <- file(file.var.indel.annodb,"r")
    line.var.indel.annodb <- readLines(con2,n = 1)
    while( length(line.var.indel.annodb) != 0 ) {
      if (substr(as.character(line.var.indel.annodb),1,4) != "Func") {
        row.var.indel.annodb <- strsplit(as.character(line.var.indel.annodb),",")[[1]]
        rank.po=as.numeric(grep("chr1",row.var.indel.annodb)[1])+1
        po.var.indel.annodb <- row.var.indel.annodb[rank.po]
        if (po.var.indel.annodb == po.ref) {
          var.indel.annodb=data.frame(line.var.indel.annodb)
          break
        } else {
          var.indel.annodb=data.frame("line.var.indel.annodb"=c("."))
        }
      }
      line.var.indel.annodb <- readLines(con2, n = 1)
    } 
    po.output=cbind(po.output,var.indel.annodb)
    close(con2)
    
    # == find position in var.annodb.snp.exome_summary.csv
    file.var.snp.annodb <- paste0(ANNO,i,SNP_ANNODB)
    con3 <- file(file.var.snp.annodb,"r")
    line.var.snp.annodb <- readLines(con3,n = 1)
    while( length(line.var.snp.annodb) != 0 ) {
      if (substr(as.character(line.var.snp.annodb),1,4) != "Func") {
        row.var.snp.annodb <- strsplit(as.character(line.var.snp.annodb),",")[[1]]
        rank.po=as.numeric(grep("chr1",row.var.snp.annodb)[1])+1
        po.var.snp.annodb <- row.var.snp.annodb[rank.po]
        if (po.var.snp.annodb == po.ref) {
          var.snp.annodb=data.frame(line.var.snp.annodb)
          break
        } else {
          var.snp.annodb=data.frame("line.var.snp.annodb"=c("."))
        }
      }
      line.var.snp.annodb <- readLines(con3, n = 1)
    }
    po.output=cbind(po.output,var.snp.annodb)
    close(con3)
    
    # == find position in var.annovar.hg19_clinvar_20150629_dropped
    file.var.clinvar.annovar <- paste0(ANNO,i,CLINVAR_ANNOVAR)
    con4 <- file(file.var.clinvar.annovar,"r")
    line.var.clinvar.annovar <- readLines(con4,n = 1)
    while( length(line.var.clinvar.annovar) != 0 ) {
      row.var.clinvar.annovar <- strsplit(as.character(line.var.clinvar.annovar),"\t")[[1]]
      po.var.clinvar.annovar <- row.var.clinvar.annovar[12]
      if (po.var.clinvar.annovar == po.ref) {
        var.clinvar.annovar=data.frame(line.var.clinvar.annovar)
        break
      } else {
        var.clinvar.annovar=data.frame("line.var.clinvar.annovar"=c("."))
      }
      line.var.clinvar.annovar <- readLines(con4, n = 1)
    }
    po.output=cbind(po.output,var.clinvar.annovar)
    close(con4)
    
    # == find position in var.annovar.hg19_cosmic70_dropped
    file.var.cosmic70.annovar <- paste0(ANNO,i,COSMIC70_ANNOVAR)
    con5 <- file(file.var.cosmic70.annovar,"r")
    line.var.cosmic70.annovar <- readLines(con5,n = 1)
    while( length(line.var.cosmic70.annovar) != 0 ) {
      row.var.cosmic70.annovar <- strsplit(as.character(line.var.cosmic70.annovar),"\t")[[1]]
      po.var.cosmic70.annovar <- row.var.cosmic70.annovar[12]
      if (po.var.cosmic70.annovar == po.ref) {
        var.cosmic70.annovar=data.frame(line.var.cosmic70.annovar)
        break
      } else {
        var.cosmic70.annovar=data.frame("line.var.cosmic70.annovar"=c("."))
      }
      line.var.cosmic70.annovar <- readLines(con5, n = 1)
    }
    po.output=cbind(po.output,var.cosmic70.annovar)
    close(con5)
    
    # == find position in var.oncotator.vcf
    file.var.oncotator.vcf <- paste0(ANNO,i,VAR_ONCOTATOR)
    con6 <- file(file.var.oncotator.vcf,"r")
    line.var.oncotator.vcf <- readLines(con6,n = 1)
    while( length(line.var.oncotator.vcf) != 0 ) {
      if (substr(as.character(line.var.oncotator.vcf),1,1) != "#") {
        row.var.oncotator.vcf <- strsplit(as.character(line.var.oncotator.vcf),"\t")[[1]]
        po.var.oncotator.vcf <- row.var.oncotator.vcf[2]
        if (po.var.oncotator.vcf == po.ref) {
          var.oncotator.vcf=data.frame(line.var.oncotator.vcf)
          break
        } else {
          var.oncotator.vcf=data.frame("line.var.oncotator.vcf"=c("."))
        } 
      }
      line.var.oncotator.vcf <- readLines(con6, n = 1)
    }
    po.output=cbind(po.output,var.oncotator.vcf)
    close(con6)  
    result=rbind(result,po.output)
    line.var.snpeff <- readLines(con1,n = 1)
  }
  close(con1)
}
result.name=paste0(OUTPUT,i,"merge.csv")
write.csv(result,result.name,row.names=FALSE)