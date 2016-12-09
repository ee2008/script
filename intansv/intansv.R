#!/nfs2/pipe/Re/Software/bin/Rscript --vanilla 
#--slave -e 'Cstack_info()["102400"]' 
# annotation via intansv
# @wxian2016Mar10

# == parameters
scoreCutoff0=60
readsSupport0=3
regSizeLowerCutoff0=100
regSizeUpperCutoff0=1000000
breakpointThres0 = 200
scoreCut0 = 0.1
pass0=TRUE
minMappingQuality0=30
soft=c()
.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")

argv <- commandArgs(TRUE)
if (length(argv) <2) {
	cat ("Usage: $0 <input_dir> <bam_prefix> <gff3_file>\n")
	cat ("input_directory example:\n")
	cat ("├── breakdancer\n  └── mut8.sv\n")
	cat ("├── cnv\n  └── mut8.cnv\n")
	cat ("├── delly\n  ├── mut8.DEL.vcf\n  ├── mut8.DUP.vcf\n  └── mut8.INV.vcf\n")
	cat ("├── lumpy\n  └── mut8.bedpe\n")
	cat ("└── pindel\n  ├── output_D\n  ├── output_INV\n  └── output_TD\n")
	q() 
}

input_dir=as.character(argv[1])
bam_prefix=as.character(argv[2])
gff3=as.character(argv[3])

#input_dir="/lustre/project/og04/wangxian/intansv/mut5.input_intansv"
#bam_prefix="mut5"

out_anno=paste0(input_dir,"/","anno")
dir.create(out_anno)
cat ("annotation out_dir: anno\n")
out_del=paste0(out_anno,"/",bam_prefix,".del.csv")
out_dup=paste0(out_anno,"/",bam_prefix,".dup.csv")
out_inv=paste0(out_anno,"/",bam_prefix,".inv.csv")

library("ggplot2")
library("intansv")

# == breakdancer
breakdancer_file=paste0(input_dir,"/breakdancer/")
if (file.exists(breakdancer_file) == 1) {
  breakdancer <- readBreakDancer(file = paste0(breakdancer_file,bam_prefix,".sv"),scoreCutoff=scoreCutoff0,
                                 readsSupport=readsSupport0,regSizeLowerCutoff=regSizeLowerCutoff0,
                                 regSizeUpperCutoff=regSizeUpperCutoff0,method="BreakDancer")
  #str(breakdancer)
  soft=c(soft,"breakdancer")
}

# == cnvnator
cnv_file=paste0(input_dir,"/cnv/")
if (file.exists(cnv_file) == 1) {
  cnvnator <- readCnvnator(dataDir = cnv_file, regSizeLowerCutoff=regSizeLowerCutoff0,
                           regSizeUpperCutoff=regSizeUpperCutoff0, method="CNVnator")
  #str(cnvnator)  
  soft=c(soft,"cnvnator")
}

# == delly
delly_file=paste0(input_dir,"/delly/")
if (file.exists(delly_file) == 1) {
  delly <- readDelly(dataDir = delly_file, regSizeLowerCutoff=regSizeLowerCutoff0,
                     regSizeUpperCutoff=regSizeUpperCutoff0, readsSupport=readsSupport0, 
                     pass=pass0, minMappingQuality=minMappingQuality0, method="DELLY")
  #str(delly)  
  soft=c(soft,"delly")
}
 
# == pindel
pindel_file=paste0(input_dir,"/pindel/")
if (file.exists(pindel_file) == 1) {
  pindel <- readPindel(dataDir = pindel_file, regSizeLowerCutoff=regSizeLowerCutoff0,
                       regSizeUpperCutoff=regSizeUpperCutoff0, readsSupport=readsSupport0, method="Pindel")
  #str(pindel)
  soft=c(soft,"pindel")
}

# == lumpy
lumpy_file=paste0(input_dir,"/lumpy/")
if (file.exists(lumpy_file) == 1) {
  lumpy <- readLumpy(file=paste0(lumpy_file,bam_prefix,".bedpe"), regSizeLowerCutoff=regSizeLowerCutoff0,
                     regSizeUpperCutoff=regSizeUpperCutoff0, readsSupport=readsSupport0, breakpointThres=breakpointThres0,
                     scoreCut=scoreCut0, method="Lumpy")
  #str(lumpy)
  soft=c(soft,"lumpy")
}

if (length(soft)==1) {
	sv_all_methods <- eval(parse(text = soft))
} else {
  softs=paste(soft,collapse=",")
  mixmethod=paste0("methodsMerge(",softs,")")
  sv_all_methods <- eval(parse(text = mixmethod))
}

#str(sv_all_methods)
library("rtracklayer")
msu_gff_v7 <- import.gff(gff3)
#head(msu_gff_v7)

# modify the svAnnotation in llply(change"mRNA" to "transcript" at line172)
SVAnnotation=function (structuralVariation, genomeAnnotation) 
{
  if (is.null(structuralVariation)) {
    return(NULL)
  }
  else if (!is.data.frame(structuralVariation)) {
    stop("structuralVariation should be a data frame!\n")
  }
  else if (!identical(names(structuralVariation)[1:3], c("chromosome", 
                                                         "pos1", "pos2"))) {
    stop("structuralVariation should have appropriate names!\n")
  }
  else if (class(genomeAnnotation) != "GRanges") {
    stop("genomeAnnotation should be a Genomic Range\n")
  }
  else if (!(.hasSlot(genomeAnnotation, "elementMetadata") && 
             .hasSlot(genomeAnnotation@elementMetadata, "listData") && 
             any(names(genomeAnnotation@elementMetadata) == "type") && 
             any(names(genomeAnnotation@elementMetadata) == "Parent"))) {
    stop("The content of genomeAnnotation is not appropriate!\n")
  }
  if (is.null(structuralVariation) | nrow(structuralVariation) <= 
      0) {
    return(NULL)
  }
  else {
    structuralVariation <- structuralVariation[, 1:3]
    structuralVariation$start <- as.numeric(structuralVariation$pos1)
    structuralVariation$end <- as.numeric(structuralVariation$pos2)
    structuralVariationIrange <- GRanges(seqnames = structuralVariation$chromosome, 
                                         ranges = IRanges(start = structuralVariation$pos1, 
                                                          end = structuralVariation$pos2))
    geneAnnoRes <- findOverlaps(structuralVariationIrange, 
                                genomeAnnotation)
    structuralVariation$query <- 1:nrow(structuralVariation)
    geneAnnoResDf <- as.data.frame(cbind(queryHits(geneAnnoRes), 
                                         subjectHits(geneAnnoRes)))
    names(geneAnnoResDf) <- c("query", "subject")
    structuralVariationGeneAnno <- merge(structuralVariation, 
                                         geneAnnoResDf, by = "query", all = T)
    structuralVariationGeneAnnoNa <- structuralVariationGeneAnno[is.na(structuralVariationGeneAnno$query) | 
                                                                   is.na(structuralVariationGeneAnno$subject), ]
    structuralVariationGeneAnnoNna <- structuralVariationGeneAnno[!(is.na(structuralVariationGeneAnno$query)) & 
                                                                    !(is.na(structuralVariationGeneAnno$subject)), ]
    structuralVariationGeneAnnoNna$overlap <- sprintf("%.3f", 
                                                      width(pintersect(structuralVariationIrange[structuralVariationGeneAnnoNna$query], 
                                                                       genomeAnnotation[structuralVariationGeneAnnoNna$subject], 
                                                                       ignore.strand = T))/width(genomeAnnotation[structuralVariationGeneAnnoNna$subject]))
    structuralVariationGeneAnnoNna$annotation <- genomeAnnotation[as.numeric(structuralVariationGeneAnnoNna$subject)]$type
    structuralVariationGeneAnnoNna$id <- genomeAnnotation[as.numeric(structuralVariationGeneAnnoNna$subject)]$ID
    structuralVariationGeneAnnoNna$parent <- NA
    structuralVariationGeneAnnoNna[structuralVariationGeneAnnoNna$annotation == 
                                     "gene", ]$parent <- genomeAnnotation[as.numeric(structuralVariationGeneAnnoNna[structuralVariationGeneAnnoNna$annotation == 
                                                                                                                      "gene", ]$subject)]$Name
    structuralVariationGeneAnnoNna[structuralVariationGeneAnnoNna$annotation != 
                                     "gene", ]$parent <- (genomeAnnotation[as.numeric(structuralVariationGeneAnnoNna[structuralVariationGeneAnnoNna$annotation != 
                                                                                                                       "gene", ]$subject)]$Parent)@unlistData
    if (nrow(structuralVariationGeneAnnoNa) > 0) {
      structuralVariationGeneAnnoNa$parent <- NA
      structuralVariationGeneAnnoNa$id <- NA
      structuralVariationGeneAnnoNa$annotation <- "intergenic"
      structuralVariationGeneAnnoNa$overlap <- NA
    }
    genomeAnnotationExon <- genomeAnnotation[genomeAnnotation$type == 
                                               "exon"]
    genomeAnnotationGene <- genomeAnnotation[genomeAnnotation$type == 
                                               "mRNA"]
    if (length(genomeAnnotationGene) == 0) {
		genomeAnnotationGene <- genomeAnnotation[genomeAnnotation$type ==
												"transcript"
	}
	genomeAnnotationGeneDf <- NULL
    genomeAnnotationGeneDf$chr <- rep(as.character((seqnames(genomeAnnotationGene))@values), 
                                      (seqnames(genomeAnnotationGene))@lengths)
    genomeAnnotationGeneDf$start <- (ranges(genomeAnnotationGene))@start
    genomeAnnotationGeneDf$end <- (ranges(genomeAnnotationGene))@start + 
      (ranges(genomeAnnotationGene))@width - 1
    genomeAnnotationGeneDf$name <- as.character(genomeAnnotationGene$ID)
    genomeAnnotationGeneDf <- as.data.frame(genomeAnnotationGeneDf, 
                                            stringsAsFactors = FALSE)
    names(genomeAnnotationGeneDf)[2:3] <- c("gene.start", 
                                            "gene.end")
    genomeAnnotationExonDf <- NULL
    genomeAnnotationExonDf$chr <- rep(as.character((seqnames(genomeAnnotationExon))@values), 
                                      (seqnames(genomeAnnotationExon))@lengths)
    genomeAnnotationExonDf$start <- (ranges(genomeAnnotationExon))@start
    genomeAnnotationExonDf$end <- (ranges(genomeAnnotationExon))@start + 
      (ranges(genomeAnnotationExon))@width - 1
    genomeAnnotationExonDf$name <- (genomeAnnotationExon$Parent)@unlistData
    genomeAnnotationExonDf <- as.data.frame(genomeAnnotationExonDf, 
                                            stringAsfactor = F)
    names(genomeAnnotationExonDf)[2:3] <- c("exon.start", 
                                            "exon.end")
    genomeAnnotationExonIrange <- GRanges(seqnames = genomeAnnotationExonDf$name, 
                                          IRanges(genomeAnnotationExonDf$exon.start, genomeAnnotationExonDf$exon.end))
    genomeAnnotationGeneIrange <- GRanges(seqnames = genomeAnnotationGeneDf$name, 
                                          IRanges(genomeAnnotationGeneDf$gene.start, genomeAnnotationGeneDf$gene.end))
    genomeAnnotationIntronIrange <- setdiff(genomeAnnotationGeneIrange, 
                                            genomeAnnotationExonIrange)
    LocusChr <- as.character(genomeAnnotationGeneDf$chr)
    names(LocusChr) <- as.character(genomeAnnotationGeneDf$name)
    genomeAnnotationGeneDf$strand <- rep(as.character((strand(genomeAnnotationGene))@values), 
                                         (strand(genomeAnnotationGene))@lengths)
    LocusStrand <- as.character(genomeAnnotationGeneDf$strand)
    names(LocusStrand) <- as.character(genomeAnnotationGeneDf$name)
    genomeAnnotationExonDf$strand <- LocusStrand[genomeAnnotationExonDf$name]
    genomeAnnotationIntronDf <- NULL
    genomeAnnotationIntronDf$intron.start <- start(genomeAnnotationIntronIrange)
    genomeAnnotationIntronDf$intron.end <- end(genomeAnnotationIntronIrange)
    genomeAnnotationIntronDf$name <- rep(as.character((seqnames(genomeAnnotationIntronIrange))@values), 
                                         (seqnames(genomeAnnotationIntronIrange))@lengths)
    genomeAnnotationIntronDf <- as.data.frame(genomeAnnotationIntronDf, 
                                              stringAsfactor = F)
    genomeAnnotationIntronDf$strand <- LocusStrand[genomeAnnotationIntronDf$name]
    genomeAnnotationIntronDfPlus <- genomeAnnotationIntronDf[genomeAnnotationIntronDf$strand == 
                                                               "+", ]
    genomeAnnotationIntronDfMinus <- genomeAnnotationIntronDf[genomeAnnotationIntronDf$strand == 
                                                                "-", ]
    intronPlusNum <- (rle(as.character(genomeAnnotationIntronDfPlus$name)))$lengths
    intronMinusNum <- (rle(as.character(genomeAnnotationIntronDfMinus$name)))$lengths
    genomeAnnotationIntronDfPlus$id <- unlist(sapply(intronPlusNum, 
                                                     function(x) {
                                                       return(c(1:x))
                                                     }))
    genomeAnnotationIntronDfMinus$id <- unlist(sapply(intronMinusNum, 
                                                      function(x) {
                                                        return(rev(c(1:x)))
                                                      }))
    genomeAnnotationIntronDf <- rbind(genomeAnnotationIntronDfMinus, 
                                      genomeAnnotationIntronDfPlus)
    genomeAnnotationIntronDf$id <- paste("intron_", genomeAnnotationIntronDf$id, 
                                         sep = "")
    genomeAnnotationIntronDf$chr <- LocusChr[as.character(genomeAnnotationIntronDf$name)]
    genomeAnnotationIntron <- GRanges(seqnames = genomeAnnotationIntronDf$chr, 
                                      IRanges(start = genomeAnnotationIntronDf$intron.start, 
                                              end = genomeAnnotationIntronDf$intron.end), name = genomeAnnotationIntronDf$name, 
                                      id = genomeAnnotationIntronDf$id)
    intronAnnoRes <- findOverlaps(structuralVariationIrange, 
                                  genomeAnnotationIntron)
    intronAnnoResDf <- as.data.frame(cbind(queryHits(intronAnnoRes), 
                                           subjectHits(intronAnnoRes)))
    names(intronAnnoResDf) <- c("query", "subject")
    structuralVariationIntronAnno <- merge(structuralVariation, 
                                           intronAnnoResDf, by = "query", all = T)
    structuralVariationIntronAnnoNna <- structuralVariationIntronAnno[!(is.na(structuralVariationIntronAnno$query)) & 
                                                                        !(is.na(structuralVariationIntronAnno$subject)), 
                                                                      ]
    structuralVariationIntronAnnoNna$overlap <- sprintf("%.3f", 
                                                        width(pintersect(structuralVariationIrange[structuralVariationIntronAnnoNna$query], 
                                                                         genomeAnnotationIntron[structuralVariationIntronAnnoNna$subject]))/width(genomeAnnotationIntron[structuralVariationIntronAnnoNna$subject]))
    structuralVariationIntronAnnoNna$annotation <- "intron"
    structuralVariationIntronAnnoNna$id <- genomeAnnotationIntron[as.numeric(structuralVariationIntronAnnoNna$subject)]$id
    structuralVariationIntronAnnoNna$parent <- genomeAnnotationIntron[as.numeric(structuralVariationIntronAnnoNna$subject)]$name
    structuralVariationAnno <- rbind(structuralVariationGeneAnnoNna, 
                                     structuralVariationGeneAnnoNa, structuralVariationIntronAnnoNna)
    structuralVariationAnnoOrdered <- structuralVariationAnno[order(structuralVariationAnno$chr, 
                                                                    structuralVariationAnno$start, structuralVariationAnno$parent), 
                                                              ]
    rownames(structuralVariationAnnoOrdered) <- 1:nrow(structuralVariationAnnoOrdered)
    structuralVariationAnnoOrdered$query <- NULL
    structuralVariationAnnoOrdered$subject <- NULL
    structuralVariationAnnoOrdered$start <- NULL
    structuralVariationAnnoOrdered$end <- NULL
    return(structuralVariationAnnoOrdered)
  }
}

sv_all_methods.anno <- llply(sv_all_methods,SVAnnotation,genomeAnnotation=msu_gff_v7)
#names(sv_all_methods.anno)
#head(sv_all_methods.anno$del)
#head(sv_all_methods.anno$dup)
#head(sv_all_methods.anno$inv)
del=data.frame(sv_all_methods.anno$del)
dup=data.frame(sv_all_methods.anno$dup)
inv=data.frame(sv_all_methods.anno$inv)
write.csv(del,out_del)
write.csv(dup,out_dup)
write.csv(inv,out_inv)

# Display the genomic distribution of SVs


gencode.v19 <- GRanges(Rle(c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16",
                       "17","18","19","20","21","22","X","Y","M")),IRanges(1, width=c(249250621,243199373,
                        198022430,191154276,180915260,171115067,159138663,146364022,141213431,135534747,135006516,
                        133851895,115169878,107349540,102531392,90354753,81195210,78077248,59128983,63025520,
                        48129895,51304566,155270560,59373566,16569)))
#genome
pic_name=paste0(out_anno,"/",bam_prefix,".jpeg")
jpeg(file=pic_name)
plotChromosome(gencode.v19,sv_all_methods, 1000000)
dev.off()


# Visualize SVs in specific genomic region
#pic_name=paste0(out_anno,"/",bam_prefix,".region.jpeg")
#jpeg(file=pic_name)
#plotRegion(sv_all_methods,msu_gff_v7,"5",1,200000)
#dev.off()



