# Genome MuSiC



## Introduction

The decreasing cost of sequencing has moved the focus of cancer genomics beyond single genome studies to the analysis of tens or hundreds of patients diagnosed with similar cancers. Besides the routine discovery and validation of SNVs, indels, and SVs in individual genomes, it is now paramount to systematically analyze the function and recurrence of mutations across a cohort, and to describe how they interact with one other or associate to clinical data. To this end we have developed the Mutational Significance In Cancer (MuSiC) suite of tools. It consists of downstream analysis tools that can:

1.Apply statistical methods to identify significantly mutated genes

2.Highlight significantly altered pathways

3.Investigate the proximity of amino acid mutations in the same gene
4.Search for gene-based or site-based correlations to mutations and relationships between mutations themselves
5.Correlate mutations to clinical features, using typical correlation measures, and generalized linear models
6.Cross-reference findings with relevant databases such as Pfam, COSMIC, and OMIM
7.Generate typical visualizations like Kaplan-Meier survival estimates, and mutation status matrices



## Software Path & Sub commands

Path:	

​		Genome: `/nfs2/pipe/Re/Software/miniconda/bin/genome` 

 		MuSiC: `/lustre/project/og04/pub/biosoft/MuSiC`

Usage:

​		` genome music …`

Sub commons:

```
proximity		
		Perform a proximity analysis on a list of mutations.
cosmic-omim		
		Compare the amino acid changes of supplied mutations to COSMIC and OMIM 				databases.
play		
		Run the full suite of MuSiC tools sequentially.
clinical-correlation		
		Correlate phenotypic traits against mutated genes, or against individual variants
pfam					
		Add Pfam annotation to a MAF file
mutation-relation		 
		Identify relationships of mutation concurrency or mutual exclusivity in genes 			across cases.
smg						
		Identify significantly mutated genes.
plot					
		Generate relevant plots and visualizations for MuSiC.
survival				
		Create survival plots and P-values for clinical and mutational phenotypes.
path-scan				
		Find signifcantly mutated pathways in a cohort given a list of somatic mutations.
bmr	
		Calculate gene coverages and background mutation rates.
```



## Packaged Scripts

### 1.path-scan & plot

#### Script path: `/lustre/project/og04/pub/pipeline/music/music.sh`

```
Usage: sh ./music.sh <bam_dir> <maf_dir> [-p] [-o <out_dir>|maf_dir]

Options:
	-p plot
	-o out_dir, default: maf_dir

the output including:
	file: bam_list
	file: all_patients.maf
	dir:  gene_covgs
	dir:  roi_covgs
	file: total_covgs
	file: Pathway
	file: Pathway_detailed
[-p]  
	file: matrix
	file: mutation
	pdf:  plot.pdf
```

#### Requared inputs

bam_dir

​	A directory that contains bam files, the name of bam file must be [sample_name.bam].

maf_dir

​	A directory that contains maf files, the name of maf file must be [normal_bam-VS-tumor_bam.var.oncotator.maf].

#### Optional inputs

-p

​	Generate relevant plots and visualizations.

-o

​	An output directory.

#### Descriptiion

##### Required arguments in path-scan:

* gene-covg-dir Text

  ​	Directory containing per-gene coverage files (Created using music bmr calc-covg)

  ```
  #Gene   Length  Covered AT_covd CG_covd CpG_covd
  A1BG    1520    1520    526     778     216
  A1CF    3346    3195    1708    1377    110
  A2LD1   1772    669     198     329     142
  A2M     7495    6890    3487    3183    220
  ```




###### supplement:

genome music bmr calc-covg --gene-covg-dir=? --roi-file=? --reference-sequence=?--bam-list=? --output-dir=?

> roi-file: `/lustre/project/og04/pub/biosoft/MuSiC/testdata/roi_testdata_ensembl_67_cds_ncrna_and_splice_sites_hg19`
>
> reference-sequence:
>
> `/lustre/project/og04/pub/database/human_genome_hg19/reference/human_g1k_v37.fa`



* bam-list Text

  ​	Tab delimited list of BAM files [sample_name, normal_bam, tumor_bam]

  ```
  LC0614T /lustre/project/og04/shenzhongji/PM-ZS-X-20160202-01_liver_cancer/align/LC0614B.bam     /lustre/project/og04/shenzhongji/PM-ZS-X-20160202-01_liver_cancer/align/LC0614T.bam
  LC1244T /lustre/project/og04/shenzhongji/PM-ZS-X-20160202-01_liver_cancer/align/LC1244B.bam     /lustre/project/og04/shenzhongji/PM-ZS-X-20160202-01_liver_cancer/align/LC1244T.bam
  ```





* maf-file Text

  ​	List of mutations using TCGA MAF specifications v2.3

  ```
  ## Oncotator v1.8.0.0 | Flat File Reference hg19 | GENCODE v19 CANONICAL |        UniProt_AAxform 2014_12 | 1000gp3 20130502 | COSMIC v62_291112 | ESP 6500SI       -V2 | dbNSFP v2.4 | ESP 6500SI-V2 | dbSNP build 142 | ClinVar 12.03.20 | Un       iProt_AA 2014_12 | ORegAnno UCSC Track | CCLE_By_GP 09292010 | Ensembl ICGC        MUCOPA | CCLE_By_Gene 09292010 | TCGAScape 110405 | UniProt 2014_12 | MutS       ig Published Results 20110905 | CGC full_2012-03-15 | HumanDNARepairGenes 2       0110905 | Familial_Cancer_Genes 20110905 | ACHILLES_Lineage_Results 110303        | gencode_xref_refseq metadata_v19 | COSMIC_Tissue 291112 | TUMORScape 2010       0104 | HGNC Sept172014 | COSMIC_FusionGenes v62_291112

  RP11-34P13.7    0   __UNKNOWN__ __UNKNOWN__ 1   89194   89194   __UNKNOWN__        RNA SNP G   G   T           LC0614T LC0614B __UNKNOWN__ __UNKNOWN__ __UNKN       OWN__ __UNKNOWN__ __UNKNOWN__ __UNKNOWN__ __UNKNOWN__ __UNKNOWN__ __UNKNOWN       __ __UNKNOWN__ __UNKNOWN__ __UNKNOWN__ __UNKNOWN__ __UNKNOWN__ __UNKNOWN__        __UNKNOWN__ LC0614B g.chr1:89194G>T ENST00000466430.1   -   0   5496                       RP11-34P13.8_ENST00000495576.1_lincRNA                                                                                                 GAAATAAGGAGAT       CATTTCCC   0.418                                                                                                                                                                 0.666667    3.73412     2   0                                                  0                               5.0 1.5 3.0103  3.73412                                                                                                                                                                       0.0,-0.       60206,-7.64479   0                                                                                                                          chr1.hg19:g.89194       G>T        1   1.0 45.0    45.0    1   2.19722     1.0 1.0 0.0 0.0 0.0 0.0        84  0   126 84  3   2   2.0 7.35324 9.52472 0.0 1   1   3.0103  1   1   3.7       3412 2   7.34376 snp     1   0.25    False   ENST00000466430.1   hg19               1X                                                                                                                                                                                                                                                                                                                                                                      5       RP11-34P13.7-001    KNOWN   not_b       est_in_genome_evidence|basic   lincRNA lincRNA 0/0 10.0088 OTTHUMT000000032       25.1        31.3022 2       2       4
  ```





* pathway-file Text

  ​	Tab-delimited file of pathway information. This is a tab-delimited file prepared from a pathway database (such as KEGG), with the columns: [path_id, path_name, class, gene_line, diseases, drugs, description] The latter three columns are optional (but are available on KEGG). The gene_line contains the "entrez_id:gene_name" of all genes involved in this pathway, each separated by a "|" symbol.

  ```
  ID  NAME    CLASS   GENES   DISEASES    DRUGS   DESCRIPTION
  hsa00592    alpha-Linolenic acid metabolism - Homo sapiens (human)  Metabolism    ; Lipid Metabolism    100137049:PLA2G4B|123745:PLA2G4E|26279:PLA2G2D|30814:PLA    2G2E|391013:PLA2G2C|50487:PLA2G3|5319:PLA2G1B|5320:PLA2G2A|5321:PLA2G4A|5322:P    LA2G5|64600:PLA2G2F|81579:PLA2G12A|8398:PLA2G6|8399:PLA2G10|84647:PLA2G12B|868    1:JMJD7-PLA2G4B|9415:FADS2|51:ACOX1|8310:ACOX3  Peroxisomal beta-oxidation enz    yme deficiency
  ```

  ​

  > KEGG(human): `/lustre/project/og04/pub/biosoft/MuSiC/testdata/inputs/kegg_db_120910`

  ​

* output-file Text

  ​	Output file that will list the significant pathways and their p-values

  ```
  Pathway Name    Class   Samples_Affected    Total_Variations    p-value FDR
  hsa05200    Pathways in cancer - Homo sapiens (human)   Human Diseases; Cancer    s 5   142 0.000000000000000000000000000000000000000000000000000000000000003688    6   3.2312136e-62
  hsa04010    MAPK signaling pathway - Homo sapiens (human)   Environmental Info    rmation Processing; Signal Transduction   5   118 0.00000000000000000000000000    000000000000000000000000000000053926    9.92419663865546e-58
  ```
  ​


##### Required arguments in plot: 

* input-matrix

  ​	A gene/sample matrix generated by the music mutation-relation tool

  ```
  Sample  A1BG    A2M     A2ML1   AADACL3 AADACL4 AAED1   AAK1    AARS  ...
  LC0614T 0       0       0       0       0       0       0       1 ...
  LC1244T 0       1       0       0       0       0       1       1 ...
  LC2195T 0       0       0       1       0       1       0       0 ...
  LC6947T 1       0       0       0       0       0       0       0 ...
  ```



###### supplement:

genome music mutation-relation --bam-list=? --maf-file=? --output-file=?



* output-pdf

​		An output pdf file to draw the plot to



### 2.smg

#### Step 1: generated a "gene-mr-file" using the tool "music bmr calc-bmr"

##### Script path: `/lustre/project/og04/pub/pipeline/music/calc_bmr.sh`

##### *Warning: this script must be ran in test node(Connected to the Internet)

```
Usage: sh ./calc_bmr.sh_step_1 <music_dir>

there will be 2 output files:
	gene_mrs
	overall_bmrs
```

##### Required input

music_dir

​	Use the same directory used with genome music  path-scan(contains bam_list、maf-file and gene_covgs、total_covgs created using music bmr calc-covg)

##### Output files

gene-mr-file

```
#Gene   Mutation_Class  Covered_Bases   Mutations       BMR
1/2-SBSRNA4     AT_Transitions  185     0       1.76960673137621e-05
A1BG    Overall 7588    1       5.23956995624978e-05
A1CF    AT_Transitions  8502    0       1.76960673137621e-05
```

bmr-out

```
#Mutation_Class Covered_Bases   Mutations       Overall_BMR
AT_Transitions  90472079        1601    1.76960673137621e-05
AT_Transversions        90472079        2655    2.9346070404771e-05
CG_Transitions  86709989        985     1.13597062040914e-05
```



#### Step 2: Identify significantly mutated genes using the tool "music smg"

##### Script path: `/lustre/project/og04/pub/pipeline/music/smg.sh`

```
Usage: sh smg.sh_step_2 <music_dir>

there will be 2 output files:
	smg
	smg_detailed
```

##### Required input

music_dir

​	A directory contains the gene-mr-file created by step 1

##### Output file

smg

​	Output file that will list significantly mutated genes and their p-values

```
#Gene   Indels  SNVs    Tot Muts    Covd Bps    Muts pMbp   P-value FCPT	P-value LRT P-value CT  FDR FCPT    FDR LRT FDR CT
FRG2B   1   17  18  4128    4360.47 0   0   0   0   0   0
KRT18   3   18  21  7105    2955.67 0   0   0   0   0   0
```

smg_detailed

​	Output file that will list all mutated genes and their p-values

```
#Gene   Indels  SNVs    Tot Muts    Covd Bps    Muts pMbp   P-value FCPT	P-value LRT P-value CT  FDR FCPT    FDR LRT FDR CT
CNIH3   18  0   18  4606    3907.95 0   0   0   0   0   0
FAM65A  0   39  39  54305   718.17  0   0   0   0   0   0
```

