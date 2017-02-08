#!/nfs/pipe/Re/Software/bin/Rscript --vanilla
##!/nfs2/pipe/Re/Software/miniconda/bin/Rscript --vanilla 
# Inferring Somatic Signatures from Single Nucleotide Variant Calls
# @wxian20160826

.libPaths("/lustre/project/og04/pub/biosoft/R_Packages")
options(bitmapType='cairo')

argv <- commandArgs(TRUE)
if (length(argv) < 1) {
  cat ("Usage: Rscript $0 <in_data> <out_dir> <signature>\n")
  cat ("\n")
  cat ("Cancer_Type:Cancer_Name\n")
  cat ("gbm: Glioblastoma multiforme\n")
  cat ("hnsc: Head and Neck squamous cell carcinoma\n")
  cat ("kirc: Kidney Chromophobe\n")
  cat ("luad: Lung adenocarcinoma\n")
  cat ("lusc: Lung squamous cell carcinoma\n")
  cat ("ov: Ovarian serous cystadenocarcinoma\n")
  cat ("skcm: Skin Cutaneous Melanoma\n")
  cat ("thca: Thyroid carcinoma\n")
  q()
}

file_add <- as.character(argv[1])
out_dir <- as.character(argv[2])
n_sigs <- as.numeric(argv[3])
if (!file.exists(out_dir) ) {
  stop("! no such dir: ", out_dir)
}

library("ggplot2")
library("SomaticSignatures")
library("SomaticCancerAlterations")
library("BSgenome.Hsapiens.1000genomes.hs37d5")

#sca_metadata <- scaMetadata()

#file_add<-"/lustre/project/og04/wangxian/snake_test/mutation_signature.txt"
data<-read.table(file_add,header=T)

#sca_data <- unlist(scaLoadDatasets())
sca_data <- GRanges(Rle(data[["seqnames"]]),IRanges(start=data[["start"]],end=data[["end"]],names=data[["disease"]]),Hugo_Symbol=data[["Hugo_Symbol"]],Entrez_Gene_Id=data[["Entrez_Gene_Id"]],Variant_Classification=data[["Variant_Classification"]],Variant_Type=data[["Variant_Type"]],Reference_Allele=data[["Reference_Allele"]],Tumor_Seq_Allele1=data[["Tumor_Seq_Allele1"]],Tumor_Seq_Allele2=data[["Tumor_Seq_Allele2"]],Verification_Status=as.factor(data[["Verification_Status"]]),Validation_Status=data[["Validation_Status"]],Mutation_Status=data[["Mutation_Status"]],Patient_ID=data[["Patient_ID"]],Sample_ID=data[["Sample_ID"]],index=data[["index"]])


sca_data$study <- factor(gsub("(.*)_(.*)", "\\1", toupper(names(sca_data))))
sca_data <- unname(subset(sca_data, Variant_Type %in% "SNP"))
sca_data <- keepSeqlevels(sca_data, hsAutosomes())

sca_vr = VRanges(
  seqnames = seqnames(sca_data),
  ranges = ranges(sca_data),
  ref = sca_data$Reference_Allele,
  alt = sca_data$Tumor_Seq_Allele2,
  sampleNames = sca_data$Patient_ID,
  seqinfo = seqinfo(sca_data),
  study = sca_data$study)

#sca_vr

sort(table(sca_vr$study), decreasing = TRUE)
sca_motifs <- mutationContext(sca_vr, BSgenome.Hsapiens.1000genomes.hs37d5)
head(sca_motifs)

sca_mm <- motifMatrix(sca_motifs, group = "study", normalize = TRUE)

head(round(sca_mm, 4))

png(paste0(out_dir,"/mutation_spectrum.png"))
plotMutationSpectrum(sca_motifs, "study")
dev.off()

#n_sigs <- 5

sigs_nmf <- identifySignatures(sca_mm, n_sigs, nmfDecomposition)

#sigs_pca <- identifySignatures(sca_mm, n_sigs, pcaDecomposition)
#sigs_nmf
#sigs_pca

n_sigs <- 2:8

gof_nmf <- assessNumberSignatures(sca_mm, n_sigs, nReplicates = 5)

#gof_pca <- assessNumberSignatures(sca_mm, n_sigs, pcaDecomposition)

png(paste0(out_dir,"/number_signatures.png"))
plotNumberSignatures(gof_nmf)
dev.off()

png(paste0(out_dir,"/somatic_signatures_heatmap_NMF.png"))
plotSignatureMap(sigs_nmf) + ggtitle("Somatic Signatures: NMF - Heatmap")
dev.off()

png(paste0(out_dir,"/somatic_signatures_barchart_NMF.png"))
plotSignatures(sigs_nmf) + ggtitle("Somatic Signatures: NMF - Barchart")
dev.off()

png(paste0(out_dir,"/signatures.png"))
plotSignatures(sigs_nmf)
dev.off()

png(paste0(out_dir,"/fitted_spectrum.png"))
plotFittedSpectrum(sigs_nmf)
dev.off()

png(paste0(out_dir,"/sample_map.png"))
plotSampleMap(sigs_nmf)
dev.off()

png(paste0(out_dir,"/samples.png"))
plotSamples(sigs_nmf)
dev.off()

