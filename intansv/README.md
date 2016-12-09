# 结构变异的检测、注释和可视化
                                           王娴 2016年3月25日
										   负责人：沈仲佶

## 结构变异检测软件

### BreakDancer

####软件简介

[BreakDancer](http://breakdancer.sourceforge.net)（version 1.4.5）是一个提供结构变异的全基因组检测的Cpp软件包，它包含BreakDancerMax 和 BreakDancerMini 这两个相辅相成的程序。BreakDancerMax从新一代短末端配对序列片段中预测五种类型的结构变异（insertions, deletions, inversions, inter- and intra-chromosomal translocations）；BreakDancerMini则侧重于检测小片段缺失（通常在10bp-100bp）。

####软件路径与重要参数

软件路径: `/lustre/project/og04/pub/biosoft/bin/breakdancer-max`
​    
```
Usage: breakdancer-max <analysis.config>

Options:
       -o STRING       operate on a single chromosome [all chromosome]
       -s INT          minimum length of a region [7]
       -c INT          cutoff in unit of standard deviation [3]
       -m INT          maximum SV size [1000000000]
       -q INT          minimum alternative mapping quality [35]
       -r INT          minimum number of read pairs required to establish a connection [2]
       -x INT          maximum threshold of haploid sequence coverage for regions to be ignored [1000]
       -b INT          buffer size for building connection [100]
       -t              only detect transchromosomal rearrangement, by default off
       -d STRING       prefix of fastq files that SV supporting reads will be saved by library
       -g STRING       dump SVs and supporting reads in BED format for GBrowse
       -l              analyze Illumina long insert (mate-pair) library
       -a              print out copy number and support reads per library rather than per bam, by default off
       -h              print out Allele Frequency column, by default off
       -y INT          output score filter [30]
       
```

#### 封装脚本

脚本路径: `/lustre/project/og04/pub/pipeline/intansv/breakdancer.sh`

##### 使用方法

```
Usage: sh $0 <bam> [out_dir|bam_dir] [out_sv|bam_prefix]
```

##### 命令解析

1. $0：封装的脚本路径
2. \<bam\>：输入bam格式的文件，在封装脚本内通过bam2cfg.pl脚本转化为configuration file
3. [out_dir|bam_dir]：输出结果的文件夹（默认输出到bam文件所在的文件夹下）
4. [out_sv|bam_prefix]：输出结果文件的前缀名（默认以bam文件的前缀作为结果文件的前缀名）

封装的脚本未设定BreakDancer的任何参数，均使用的默认值。

#### 输出结果示例

```
#Chr1   Pos1    Orientation1    Chr2    Pos2    Orientation2    Type    Size    Score   num_Reads       num_Reads_lib   mut8.bam
1       721359  4+2-    1       721424  4+2-    ITX     -101    49      2       /lustre/project/og04/wangxian/intansv/sh_scr/mut8.bam|2 NA
1       726930  2+2-    1       726968  2+2-    ITX     -116    56      2       /lustre/project/og04/wangxian/intansv/sh_scr/mut8.bam|2 NA
1       762075  4+2-    1       762089  4+2-    ITX     -92     68      2       /lustre/project/og04/wangxian/intansv/sh_scr/mut8.bam|2 NA
1       783025  4+3-    1       783091  4+3-    ITX     -90     49      2       /lustre/project/og04/wangxian/intansv/sh_scr/mut8.bam|2 NA
1       871033  7+4-    1       871133  7+4-    ITX     -94     80      4       /lustre/project/og04/wangxian/intansv/sh_scr/mut8.bam|4 NA
1       879196  4+2-    1       879245  4+2-    ITX     -88     53      2       /lustre/project/og04/wangxian/intansv/sh_scr/mut8.bam|2 NA
```


###CNVnator

#### 软件简介

基因组的拷贝数变异（Cope number variation, CNV）是一个复杂的过程，[CNVnator](https://github.com/abyzovlab/CNVnator/releases)（version0.3）通过分析片段深度来检测CNV以及进行基因分型。

#### 软件路径与重要参数

软件路径: `/nfs2/pipe/Cancer/Software/CNVnator/CNVnator_v0.3/src/cnvnator`
​    
```
Usage: ./cnvnator [-genome name] -root out.root [-chrom name1 ...] -tree [file1.bam ...]

    out.root  -- output ROOT file. 
    chr_name1 -- chromosome name.
    file.bam  -- bam files.
```

#### 封装脚本

脚本路径: `/lustre/project/og04/pub/pipeline/intansv/cnv.sh`
​    
##### 使用方法

```
Usage: sh ./cnv.sh <bam> <fa_dir> [-chr <chr_name>] [out_dir|bam_dir]
```

##### 命令解析

1. $0：封装的脚本路径
2. \<bam\>：输入bam格式的文件
3. \<fa_dir\>：输入fasta格式文件所在的文件夹
4. [-chr <chr_name>]：检测特点染色体的CNV（默认检测所有染色体的CNV）
5. [out\_dir|bam\_dir]：输出结果的文件夹（默认输出到bam文件所在的文件夹下）

   ​        
#### 输出结果示例

```
duplication     chr1:1-249251000        2.49251e+08     1.58198e+13     0       0       0       0       1
duplication     chr2:1-243200000        2.432e+08       1.28344e+13     0       0       0       0       1
duplication     chr3:1-197963000        1.97963e+08     1.22335e+13     0       0       0       0       1
deletion        chr3:197963001-198023000        60000   0       23925   2.4902e-09      24750   9.96078e-09     1
duplication     chr4:1-191155000        1.91155e+08     9.19832e+12     0       0       0       0       1
duplication     chr5:1-180916000        1.80916e+08     1.06678e+13     0       0       0       0       1
```

###Pindel

#### 软件简介

[Pindel](http://gmt.genome.wustl.edu/packages/pindel/) (version 0.2.5)可以从新一代序列数据检测出大段缺失、中等长度的插入、倒转、串联重复序列等结构变异的断点。

#### 软件路径与重要参数

软件路径: `/lustre/project/og04/pub/biosoft/pindel/pindel`
​    
```
Usage:     pindel -f <reference.fa> -p <pindel_input> [and/or -i bam_configuration_file]
           -c <chromosome_name> -o <prefix_for_output_file>
           
    -f/--fasta               the reference genome sequences in fasta format
    -p/--pindel-file         the Pindel input file; (either this or a bam configuration file is required).
    -i/--config-file         the bam config file; either this or a pindel input file is required. Per line: path and file name of bam, insert size and sample tag. For example: /data/tumour.bam 400  tumour
    -o/--output-prefix       Output prefix
    -c/--chromosome          Which chr/fragment. Pindel will process reads for one chromosome each time. ChrName must be the same as in reference sequence and in read file. '-c ALL' will make Pindel loop over all chromosomes. The search for indels and SVs can also be limited to a specific region; -c 20:10,000,000 will only look for indels and SVs after position 10,000,000 == [10M, end], -c 20:5,000,000-15,000,000 will report indels in the range between and including the bases at position 5,000,000 and 15,000,000 = [5M, 15M]	
```


#### 封装脚本

脚本路径: `/lustre/project/og04/pub/pipeline/intansv/pindel.sh`
​    
##### 使用方法
```
usage: sh pindel.sh <bam> <fasta> [-chr <chromosome>] [-outpro <output_prefix>|output] [out_dir|bam_dir]
```

##### 命令解析

1. $0：封装的脚本路径
2. \<bam\>：输入bam格式的文件，在封装脚本中生成config_file文件
3. \<fasta\>：输入fasta格式的文件
4. [-chr <chromosome>]：检测特点染色体的结构变异（默认检测所有染色体的结构变异）
5. [-out <output_prefix>]：输出结果文件的前缀名（默认以”output”为输出结果文件前缀名）
6. [out_dir|bam_dir]：输出结果的文件夹（默认输出到bam文件所在的文件夹下）。

#### 输出结果示例

```
1 ####################################################################################################
2 0   D 2 NT 0 "" ChrID 1 BP 13656    13659   BP_range 13656  13659   Supports 13 13  + 13    13  - 0 0   S1 14   SUM_MS 190  1   NumSupSamples 1 1   mut8 2        7 27 13 13 0 0
3 GTCTGCAGGGATCCTGCTACAAAGGTGAAACCCAGGAGAGTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAACagGGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGTGAGATCTTCCCAGGG        CAGCTCCCCTCTGTGGAATCCAATCTGTCTTCCATCCTGCGTGGCC
4                                                                                    TGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGTGAGATCTTCCCAGGG        CAGCTCCCCTCTGTGGAATCCAATCTGTCTT                   +   13446   22  mut8    @HISEQ02:122:HGYLWADXX:1:2108:5636:49585/1
5                                                                              CATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGTGAGATCTTCCCAGGG        CAGCTCCCCTCTGTGGAATCCAATC                         +   13485   6   mut8    @HISEQ01:448:HVFGFADXX:1:1206:15384:50917/2
6                                                     AGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGTGAGATCTTCCCAGGG                                                          +   13470   2   mut8    @HISEQ02:121:HGYFFADXX:2:2214:18116:25842/1
7                                             GAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGTGAGATCT                                                                  +   13414   22  mut8    @HISEQ02:122:HGYLWADXX:2:1212:6538:41043/1
8                                          GTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGTGAGA                                                                     +   13417   22  mut8    @HISEQ01:446:HGVMJADXX:1:1106:17434:68375/1
9                                        GTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGTGA                                                                       +   13447   22  mut8    @HISEQ02:123:HVFM2ADXX:1:1115:3807:72326/1
10                                       GTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGTGA                                                                       +   13447   22  mut8    @HISEQ01:448:HVFGFADXX:1:1103:11122:30848/1
11                                     GAGTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGCCATCCGT                                                                         +   13465   7   mut8    @HISEQ02:121:HGYFFADXX:1:2116:13179:46751/1
12                              CCCAGGAGAGTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGGC                                                                                +   13461   7   mut8    @HISEQ02:122:HGYLWADXX:2:1201:15790:30262/1
13                             ACCCAGGAGAGTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCTGG                                                                                 +   13458   12  mut8    @HISEQ02:122:HGYLWADXX:1:2215:7094:12657/2
14                           AAACCCAGGAGAGTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAGAAATGGTGGGTCCT                                                                                   +   13461   7   mut8    @HISEQ02:121:HGYFFADXX:1:1203:11136:83288/2
15             CTGCTACAAAGGTGAAACCCAGGAGAGTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGAAG                                                                                                 +   13446   23  mut8    @HISEQ01:445:HHFK2ADXX:2:1106:11752:69115/2
16           TCCTGCTACAAAGGTGAAACCCAGGAGAGTGTGGAGTCCAGAGTGTTGCCAGGACCCAGGCACAGGCATTAGTGCCCGTTGGAGAAAAC  GGGAATCCCGA                                                                                                   +   13395   16  mut8    @HISEQ01:445:HHFK2ADXX:2:2108:8856:14006/2
```

###DELLY

####软件简介

[DELLY](https://github.com/tobiasrausch/delly)（version4.1)是一个综合的结构变异检测软件。它可以从短读大规模并行的测序数据中的单核苷酸解析度来检测基因的缺失、重复串联、倒置、易位。使用配对末端和分段读取的方法更灵敏更准确地描绘整个基因组中的基因重排。

#### 软件路径和重要参数

软件路径: `/nfs2/pipe/Re/Software/miniconda/bin/delly`
​       
```
Usage: ./delly [OPTIONS] -g <ref.fa> <sample1.sort.bam> <sample2.sort.bam> ...

Options:
       -t [ --type ] arg (=DEL)            SV type (DEL, DUP, INV, TRA, INS)
       -o [ --outfile ] arg (="sv.vcf")    SV output file
       -x [ --exclude ] arg (="")          file with chr to exclude
       -g [ --genome ] arg                 genome fasta file
       -v [ --vcfgeno ] arg (="site.vcf")  input vcf file for genotyping only
```

#### 封装脚本

脚本路径: `/lustre/project/og04/pub/pipeline/intansv/delly.sh`

##### 使用方法

```
usage: sh $0 <bam> <fasta> [out_dir|bam_dir] [-type <DEL DUP INV TRA INS>]
```

##### 命令解析

1. $0：封装的脚本路径
2. \<bam\>：输入bam格式的文件
3. \<fasta\>：输入fasta格式的文件
4. [out_dir|bam_dir]：输出结果的文件夹（默认输出到bam文件所在的文件夹下）
5. [-type \<DEL DUP INV TRA INS\>]：选择检测的结构变异类型[DEL:deletions; DUP:duplications; INV:inversions; TRA:translocation; INS:insertion]（默认检测缺失变异）

#### 输出结果示例

```
#CHROM  POS ID  REF ALT QUAL    FILTER  INFO    FORMAT  mut8
1   1647967     INV00000001 N   <INV>   .   LowQual IMPRECISE;CIEND=-95,95;CIPOS=-95,95;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=228422169;CT=3to3;INSLEN=0;PE=6;MAPQ=9  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/1:-1.4897,0,-33.2515:15:PASS:0:21846189:0:-1:6:4:0:0
1   16862421    INV00000002 N   <INV>   .   LowQual IMPRECISE;CIEND=-198,198;CIPOS=-198,198;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17198218;CT=3to3;INSLEN=0;PE=2;MAPQ=6  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/0:0,-14.7505,-242.024:148:PASS:29714:122318:48357:3:50:1:0:0
1   16862480    INV00000003 N   <INV>   .   LowQual IMPRECISE;CIEND=-107,107;CIPOS=-107,107;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17198691;CT=5to5;INSLEN=0;PE=4;MAPQ=9  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/0:0,-3.18778,-62.1107:32:PASS:31765:121561:47068:3:16:3:0:0
1   16955081    INV00000004 N   <INV>   .   LowQual IMPRECISE;CIEND=-235,235;CIPOS=-235,235;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17270946;CT=5to5;INSLEN=0;PE=2;MAPQ=37 GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/1:-2.09285,0,-23.058:21:PASS:43009:93740:53240:2:5:2:0:0
1   16973504    INV00000005 N   <INV>   .   LowQual IMPRECISE;CIEND=-153,153;CIPOS=-153,153;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17087199;CT=5to5;INSLEN=0;PE=3;MAPQ=9  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/0:0,-148.277,-1000:10000:PASS:21382:62920:6731:4:504:3:0:0
1   16974668    INV00000006 N   <INV>   .   LowQual IMPRECISE;CIEND=-231,231;CIPOS=-231,231;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17085504;CT=3to3;INSLEN=0;PE=2;MAPQ=7  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/0:0,-122.185,-1000:10000:PASS:26889:50808:6704:3:409:2:0:0
```

#### 备注

我们使用DELLY4.1版本计算的结果中没有包含sv长度，而在intansv包读数据时需要用到该信息，所以通过一个perl脚本更新DELLY的检测结果。

脚本路径: `/lustre/project/og04/wangxian/intansv/delly.length.sv.pl`

使用方法：

```
Usage: perl ./delly.length.sv.pl [delly_in_dir] [delly_out_dir]
```

输入原来DELLY运行结果所在的文件夹和更新后结果存放的文件夹即可得到可被intansv包读入的文件，在FILTER列中增加了SVLEN的数据。

输出结果示例

```
#CHROM  POS ID  REF ALT QUAL    FILTER  INFO    FORMAT  mut8
1   1647967     INV00000001 N   <INV>   .   LowQual IMPRECISE;CIEND=-95,95;CIPOS=-95,95;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=228422169;SVLEN=226774202;CT=3to3;INSLEN=0;PE=6;MAPQ=9  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/1:-1.4897,0,-33.2515:15:PASS:0:21846189:0:-1:6:4:0:0
1   16862421    INV00000002 N   <INV>   .   LowQual IMPRECISE;CIEND=-198,198;CIPOS=-198,198;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17198218;SVLEN=335797;CT=3to3;INSLEN=0;PE=2;MAPQ=6  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/0:0,-14.7505,-242.024:148:PASS:29714:122318:48357:3:50:1:0:0
1   16862480    INV00000003 N   <INV>   .   LowQual IMPRECISE;CIEND=-107,107;CIPOS=-107,107;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17198691;SVLEN=336211;CT=5to5;INSLEN=0;PE=4;MAPQ=9  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/0:0,-3.18778,-62.1107:32:PASS:31765:121561:47068:3:16:3:0:0
1   16955081    INV00000004 N   <INV>   .   LowQual IMPRECISE;CIEND=-235,235;CIPOS=-235,235;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17270946;SVLEN=315865;CT=5to5;INSLEN=0;PE=2;MAPQ=37 GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/1:-2.09285,0,-23.058:21:PASS:43009:93740:53240:2:5:2:0:0
1   16973504    INV00000005 N   <INV>   .   LowQual IMPRECISE;CIEND=-153,153;CIPOS=-153,153;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17087199;SVLEN=113695;CT=5to5;INSLEN=0;PE=3;MAPQ=9  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/0:0,-148.277,-1000:10000:PASS:21382:62920:6731:4:504:3:0:0
1   16974668    INV00000006 N   <INV>   .   LowQual IMPRECISE;CIEND=-231,231;CIPOS=-231,231;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.2;CHR2=1;END=17085504;SVLEN=110836;CT=3to3;INSLEN=0;PE=2;MAPQ=7  GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV   0/0:0,-122.185,-1000:10000:PASS:26889:50808:6704:3:409:2:0:0
```

###Lumpy

####软件介绍

[Lumpy](https://github.com/arq5x/lumpy-sv)（version 0.2.11）是一个检测结构变异的概率框架。

#### 软件路径与重要参数

软件路径: `/lustre/project/og04/pub/biosoft/speedseq/bin/lumpy`
​    
```
usage:    lumpy [options]
    
Options:
	-g	Genome file (defines chromosome order)
	-e	Show evidence for each call
	-w	File read windows size (default 1000000)
	-mw	minimum weight for a call
	-msw	minimum per-sample weight for a call
	-tt	trim threshold
	-x	exclude file bed file
	-t	temp file prefix, must be to a writeable directory
	-P	output probability curve for each variant
	-b	output BEDPE instead of VCF
	-sr	bam_file:<file name>,
		id:<sample name>,
		back_distance:<distance>,
		min_mapping_threshold:<mapping quality>,
		weight:<sample weight>,
		min_clip:<minimum clip length>,
		read_group:<string>

	-pe	bam_file:<file name>,
		id:<sample name>,
		histo_file:<file name>,
		mean:<value>,
		stdev:<value>,
		read_length:<length>,
		min_non_overlap:<length>,
		discordant_z:<z value>,
		back_distance:<distance>,
		min_mapping_threshold:<mapping quality>,
		weight:<sample weight>,
		read_group:<string>

	-bedpe	bedpe_file:<bedpe file>,
		id:<sample name>,
		weight:<sample weight>
```

#### 封装脚本

脚本路径: `/lustre/project/og04/pub/pipeline/intansv/lumpy.sh`
​    
##### 使用方法

```
usage: sh $0 <bam> [out_dir|bam_dir]
```

##### 命令解析

1. $0：封装的脚本路径
2. \<bam\>：输入bam格式的文件，在封装的脚本中经过samtools处理成discordants.bam和splitters.bam两种类型的bam文件以及histo_file
3. [out_dir|bam_dir]：输出结果的文件夹（默认输出到bam文件所在的文件夹下）

#### 输出结果示例

```
1   899531  899613  1   899542  899641  1   0.010101    +   -   TYPE:DELETION   IDS:mut8_PE,4   STRANDS:+-,4    MAX:1:899542;1:899631   95:1:899539-899577;1:899591-899634
1   957714  957803  1   957745  957814  2   1.8382e-12  +   -   TYPE:DELETION   IDS:mut8_PE,4   STRANDS:+-,4    MAX:1:957722;1:957804   95:1:957720-957766;1:957772-957807
1   977022  977041  1   977039  977067  3   1.41934e-20 +   -   TYPE:DELETION   IDS:mut8_PE,6   STRANDS:+-,6    MAX:1:977028;1:977057   95:1:977018-977036;1:977046-977060
1   978519  978689  1   978647  978929  4   0.00301211  +   -   TYPE:DELETION   IDS:mut8_PE,4   STRANDS:+-,4    MAX:1:978530;1:978919   95:1:978528-978614;1:978820-978921
1   987426  987767  1   987527  987784  5   8.00011e-07 +   -   TYPE:DELETION   IDS:mut8_PE,5   STRANDS:+-,5    MAX:1:987437;1:987774   95:1:987435-987538;1:987677-987775
1   1078046 1078317 1   1078191 1078384 6   0.00347222  +   -   TYPE:DELETION   IDS:mut8_PE,5   STRANDS:+-,5    MAX:1:1078057;1:1078374 95:1:1078055-1078126;1:1078310-1078377
```

##intansv

目前，根据新一代的测序数据已经开发出了几十种方案来检测结构变异，这些方案的结果不完全一致，
整合多种方案所得到的结果才更可信。我们使用五个常用的结构变异检测软件，并通过R语言下的intansv软件包整合不同的方法得到的结果，注释因为结构变异给基因及其要素带来的影响，同时描绘结构变异的基因组分布，以及可视化特定基因组区域下的结构变异。intansv软件包可以对deletions、duplications、inversions这三种类型的结构变异进行注释和可视化。

### Read in predictions of different programs

1） intansv包可以读入上述五个软件的预测结果，低品质的结构变异预测和重叠的部分将会被过滤掉。

```
library("intansv")
breakdancer <- readBreakDancer(file="", scoreCutoff=60, readsSupport=3,regSizeLowerCutoff=100,regSizeUpperCutoff=1000000,method="BreakDancer")
cnvnator <- readCnvnator(dataDir=".", regSizeLowerCutoff=100, regSizeUpperCutoff=1000000,method="CNVnator")
delly <- readDelly(dataDir=".", regSizeLowerCutoff=100, regSizeUpperCutoff=1000000,readsSupport=3,method="DELLY", pass=TRUE, minMappingQuality=30)
pindel <- readPindel(dataDir=".", regSizeLowerCutoff=100, regSizeUpperCutoff=1000000,readsSupport=3,method="Pindel")
lumpy <- readLumpy(file="", regSizeLowerCutoff=100, readsSupport=3, method="Lumpy",regSizeUpperCutoff=1000000, breakpointThres=200, scoreCut=0.1)
```

读入的文件格式为

```
$ del:'data.frame':	449 obs. of  4 variables:
  ..$ chromosome: chr [1:449] "1" "1" "1" "1" ...
  ..$ pos1      : num [1:449] 12907904 21786418 26489812 46207286 58743909 ...
  ..$ pos2      : num [1:449] 13183635 21786691 26490139 46207599 58744823 ...
  ..$ size      : num [1:449] 275730 272 326 312 913 ...
$ inv:'data.frame':	233 obs. of  4 variables:
  ..$ chromosome: chr [1:233] "1" "1" "1" "1" ...
  ..$ pos1      : num [1:233] 1248928 1581724 13052666 16415255 16862813 ...
  ..$ pos2      : num [1:233] 1249196 1644964 13216621 16416097 17198109 ...
  ..$ size      : num [1:233] 273 63257 163954 841 335295 ...
$ dup:'data.frame':	238 obs. of  4 variables:
  ..$ chromosome: chr [1:238] "1" "1" "1" "1" ...
  ..$ pos1      : num [1:238] 1606988 7924954 12907708 16890559 17060620 ...
  ..$ pos2      : num [1:238] 1669845 7925065 13183439 16893725 17195029 ...
  ..$ size      : num [1:238] 62856 110 275730 3165 134408 ...
```

2） 将5个软件预测的结果进行合并

```
sv_all_methods <- methodsMerge(breakdancer,cnvnator,pindel,lumpy,delly)
```

合并后的结果示例

```
 $ del:'data.frame':	143 obs. of  7 variables:
  ..$ chromosome : chr [1:143] "1" "1" "1" "1" ...
  ..$ pos1       : num [1:143] 2.18e+07 3.27e+07 7.94e+07 8.96e+07 1.51e+08 ...
  ..$ pos2       : num [1:143] 2.18e+07 3.27e+07 7.94e+07 8.97e+07 1.51e+08 ...
  ..$ BreakDancer: chr [1:143] "N" "Y" "N" "Y" ...
  ..$ CNVnator   : chr [1:143] "N" "N" "N" "N" ...
  ..$ Pindel     : chr [1:143] "Y" "N" "Y" "Y" ...
  ..$ Lumpy      : chr [1:143] "Y" "Y" "Y" "N" ...
 $ dup:'data.frame':	17 obs. of  7 variables:
  ..$ chromosome : chr [1:17] "1" "1" "1" "3" ...
  ..$ pos1       : num [1:17] 1.29e+07 8.96e+07 1.52e+08 1.95e+08 1.07e+07 ...
  ..$ pos2       : num [1:17] 1.32e+07 8.97e+07 1.52e+08 1.95e+08 1.07e+07 ...
  ..$ BreakDancer: chr [1:17] "N" "N" "N" "N" ...
  ..$ CNVnator   : chr [1:17] "N" "N" "N" "N" ...
  ..$ Pindel     : chr [1:17] "Y" "Y" "Y" "Y" ...
  ..$ Lumpy      : chr [1:17] "Y" "Y" "Y" "Y" ...
 $ inv:'data.frame':	20 obs. of  7 variables:
  ..$ chromosome : chr [1:20] "2" "2" "4" "5" ...
  ..$ pos1       : num [1:20] 8.55e+07 8.92e+07 7.02e+07 1.15e+08 1.48e+08 ...
  ..$ pos2       : num [1:20] 8.56e+07 8.92e+07 7.02e+07 1.15e+08 1.48e+08 ...
  ..$ BreakDancer: chr [1:20] "Y" "N" "Y" "Y" ...
  ..$ CNVnator   : chr [1:20] "N" "N" "N" "N" ...
  ..$ Pindel     : chr [1:20] "N" "Y" "N" "Y" ...
  ..$ Lumpy      : chr [1:20] "Y" "Y" "Y" "Y" ...
```


### Annotate the effects of SVs

1） 对结构变异进行注释，需要一个基因组注释文件，通常为gff3格式。该文件可以被R中的rtracklayer包读入并存储为一个基因组范围的文件。


人类的基因组注释文件路径：`/lustre/project/og04/pub/database/human_genome_hg19/gencode.v19.annotation_nochr.gff3`   
​    
```
library("rtracklayer")
msu_gff_v7 <- import.gff("/lustre/project/og04/pub/database/human_genome_hg19/gencode.v19.annotation_nochr.gff3")
```

经rtracklayer包读取后的文件格式为

```
seqnames         ranges strand |   source       type     score     phase
         <Rle>      <IRanges>  <Rle> | <factor>   <factor> <numeric> <integer>
  [1]        1 [11869, 14412]      + |   HAVANA       gene      <NA>      <NA>
  [2]        1 [11869, 14409]      + |   HAVANA transcript      <NA>      <NA>
  [3]        1 [11869, 12227]      + |   HAVANA       exon      <NA>      <NA>
  [4]        1 [12613, 12721]      + |   HAVANA       exon      <NA>      <NA>
  [5]        1 [13221, 14409]      + |   HAVANA       exon      <NA>      <NA>
  [6]        1 [11872, 14412]      + |  ENSEMBL transcript      <NA>      <NA>
                            ID           gene_id     transcript_id   gene_type gene_status
                   <character>       <character>       <character> <character> <character>
  [1]        ENSG00000223972.4 ENSG00000223972.4 ENSG00000223972.4  pseudogene       KNOWN
  [2]        ENST00000456328.2 ENSG00000223972.4 ENST00000456328.2  pseudogene       KNOWN
  [3] exon:ENST00000456328.2:1 ENSG00000223972.4 ENST00000456328.2  pseudogene       KNOWN
  [4] exon:ENST00000456328.2:2 ENSG00000223972.4 ENST00000456328.2  pseudogene       KNOWN
  [5] exon:ENST00000456328.2:3 ENSG00000223972.4 ENST00000456328.2  pseudogene       KNOWN
  [6]        ENST00000515242.2 ENSG00000223972.4 ENST00000515242.2  pseudogene       KNOWN
        gene_name                    transcript_type transcript_status transcript_name
      <character>                        <character>       <character>     <character>
  [1]     DDX11L1                         pseudogene             KNOWN         DDX11L1
  [2]     DDX11L1               processed_transcript             KNOWN     DDX11L1-002
  [3]     DDX11L1               processed_transcript             KNOWN     DDX11L1-002
  [4]     DDX11L1               processed_transcript             KNOWN     DDX11L1-002
  [5]     DDX11L1               processed_transcript             KNOWN     DDX11L1-002
  [6]     DDX11L1 transcribed_unprocessed_pseudogene             KNOWN     DDX11L1-201
            level          havana_gene            Parent    havana_transcript exon_number
      <character>          <character>   <CharacterList>          <character> <character>
  [1]           2 OTTHUMG00000000961.2                                   <NA>        <NA>
  [2]           2 OTTHUMG00000000961.2 ENSG00000223972.4 OTTHUMT00000362751.1        <NA>
  [3]           2 OTTHUMG00000000961.2 ENST00000456328.2 OTTHUMT00000362751.1           1
  [4]           2 OTTHUMG00000000961.2 ENST00000456328.2 OTTHUMT00000362751.1           2
  [5]           2 OTTHUMG00000000961.2 ENST00000456328.2 OTTHUMT00000362751.1           3
  [6]           3 OTTHUMG00000000961.2 ENSG00000223972.4                 <NA>        <NA>
                exon_id             ont             tag  protein_id      ccdsid
            <character> <CharacterList> <CharacterList> <character> <character>
  [1]              <NA>                                        <NA>        <NA>
  [2]              <NA>                                        <NA>        <NA>
  [3] ENSE00002234944.1                                        <NA>        <NA>
  [4] ENSE00003582793.1                                        <NA>        <NA>
  [5] ENSE00002312635.1                                        <NA>        <NA>
  [6]              <NA>                                        <NA>        <NA>
  
```

2） 对结构变异的预测结果进行注释

```
sv_all_methods.anno <- llply(sv_all_methods,SVAnnotation,genomeAnnotation=msu_gff_v7)
```

备注：如果需要对注释结果进行调整，可以通过修改SVAnnotation函数来完成。

注释后的结果示例

```
chromosome     pos1     pos2 overlap annotation                 id             parent
1          1 21786418 21786690   0.006       gene ENSG00000142794.14                  1
2          1 21786418 21786690   0.483       gene  ENSG00000176378.8                  1
3          1 21786418 21786690   0.006 transcript  ENST00000454000.2 ENSG00000142794.14
4          1 21786418 21786690   0.006 transcript  ENST00000318220.6 ENSG00000142794.14
5          1 21786418 21786690   0.006 transcript  ENST00000318249.5 ENSG00000142794.14
6          1 21786418 21786690   0.006 transcript  ENST00000342104.5 ENSG00000142794.14
```


### Display the genomic distribution of SVs

1） 首先需要准备一个记录了各条染色体长度的GRanges文件，以人类基因组为例：

```
gencode.v19 <- GRanges(Rle(c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15" ,"16", "17","18","19","20","21","22","X","Y","M")),IRanges(1,width=c(249250621,243199373,198022430,191154276,180915260,171115067,159138663,146364022,141213431,135534747,135006516,133851895,115169878,107349540,102531392,90354753,81195210,78077248,59128983,63025520,48129895,51304566,155270560,59373566,16569)))
```

GRanges文件格式为

```
GRanges object with 25 ranges and 0 metadata columns:
       seqnames         ranges strand
          <Rle>      <IRanges>  <Rle>
   [1]        1 [1, 249250621]      *
   [2]        2 [1, 243199373]      *
   [3]        3 [1, 198022430]      *
   [4]        4 [1, 191154276]      *
   [5]        5 [1, 180915260]      *
   ...      ...            ...    ...
  [21]       21 [1,  48129895]      *
  [22]       22 [1,  51304566]      *
  [23]        X [1, 155270560]      *
  [24]        Y [1,  59373566]      *
  [25]        M [1,     16569]      *
  -------
  seqinfo: 25 sequences from an unspecified genome; no seqlengths
```

2） 以环状图显示各染色体上的结构变异情况

```
plotChromosome(gencode.v19,sv_all_methods, 1000000)
```

![](http://192.168.1.224:4321/lustre/project/og04/wangxian/intansv/mut2.input_intansv/anno/mut2.jpeg)



### Visualize SVs in specific genomic region

```
plotRegion(sv_all_methods,msu_gff_v7,"5",1,200000)
```


## 检测、注释和可视化的流程

我们将从检测结构变异，到注释变异结果以及可视化变异情况的整个过程整合为一个完整的流程。

脚本路径：`/lustre/project/og04/pub/pipeline/intansv/call_sv_and_annotation.sh`

```
Usage: sh $0 <bam> <fasta> [-gff3 <gff3_file>|human.v19.gff3] [-out <out_dir>|in_dir] [breakdancer] [cnv] [pindel] [delly] [lumpy]
```

命令解析

1. $0：脚本路径
2. \<bam\>：输入bam格式的文件
3. \<fasta\>：输入fasta格式的文件
4. [-gff3 \<gff3_file\>|human.v19.gff3]：输入gff3格式的文件（默认输入人类的gff3文件）
5. [-out \<out_dir\>|in_dir]：输出结果的文件夹（默认输出到bam文件所在的文件夹下）
6. [breakdancer] [cnv] [pindel] [delly] [lumpy]：选择其中的一种或多种方法进行结构变异的检测,并得到注释和可视化的结果

