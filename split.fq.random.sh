#!/bin/bash

if [[ $# -eq 0 ]]; then
	cat << EOF
Usage: sh $0 <R1.fastq.gz> [-l <region_len>] [-d] [-o <out_dir>] [-min <min_depth>] [-max <max_depth>] [-i <interval>] [-z]

Options:
	-l region_len
	-d only echo the depth of fastq(just need: <R1.fastq.gz> -l <region_len> -d)
	-o out_dir
	-min min_depth
	-max max_depth
	-i interval of depth
	-z only unzip to folder(just need:<R1.fastq.gz> -l <region_len> -z) 
EOF
exit 0
fi

R1="$1"
d=0
z=0
while [[ $# -gt 1 ]];do
	key="$2"
	case $key in
		-l) LEN="$3"
			shift; ;;
		-d) d=1
			;;
		-z) z=1
			;;
		-o) OUT="$3"
			shift; ;;
		-min)	MIN="$3"
			  	shift; ;;
		-max)	MAX="$3"
			  	shift; ;;
		-i)	INT="$3"
			shift; ;;
	esac
	shift
done

if [[ $d == 1 ]]; then
	row_n=$(gzip -dc $R1 | wc -l)
	max_x=$[${row_n}/4*150/${LEN}*2]
	echo "the depth is $max_x"
	exit 0
fi

prefix_R1=$(basename $R1 R1.fastq.gz)
R2=$(dirname $R1)/${prefix_R1}R2.fastq.gz

R1g="$OUT/$(basename $R1 .gz)"
R2g="$OUT/$(basename $R2 .gz)"
if [[ $z == 1 ]]; then
	gunzip -c $R1 > $R1g
	gunzip -c $R2 > $R2g
	exit 0
fi

i=$MIN
while [ $i -le $MAX ]
do
	line=$[(${LEN}*${i}/150)/2]
	#size=$[$line*150/(10**9)]
	echo "row_n=\$(gzip -dc $R1 | wc -l)" >> $OUT/tem_${i}.sh
	echo "base_n=\$[\$row_n/4]" >> $OUT/tem_${i}.sh
	echo "Rscript /lustre/project/og04/wangxian/depth/generate.random.data.R \$base_n $line $OUT/tem_${i}.random.txt" >> $OUT/tem_${i}.sh
	echo "paste $OUT/tem_${i}.random.txt $R1g > $OUT/tem_${i}_R1.fastq" >> $OUT/tem_${i}.sh
	echo "paste $OUT/tem_${i}.random.txt $R2g > $OUT/tem_${i}_R2.fastq" >> $OUT/tem_${i}.sh
	echo "line=\$(cat $OUT/tem_${i}.random.txt | grep \"1\" | wc -l)" >> $OUT/tem_${i}.sh 
	echo "cat $OUT/tem_${i}_R1.fastq | grep \"^1\" | awk -F \"\t\" '{print \$2}' | gzip > $OUT/${prefix_R1}${i}_R1.fastq.gz" >> $OUT/tem_${i}.sh
	echo "cat $OUT/tem_${i}_R2.fastq | grep \"^1\" | awk -F \"\t\" '{print \$2}'| gzip > $OUT/${prefix_R1}${i}_R2.fastq.gz" >> $OUT/tem_${i}.sh
	echo "rm $OUT/tem_${i}.random.txt" >> $OUT/tem_${i}.sh
	echo "rm $OUT/tem_${i}_R1.fastq" >> $OUT/tem_${i}.sh
	echo "rm $OUT/tem_${i}_R2.fastq" >> $OUT/tem_${i}.sh
	echo "a=\$(gunzip -dc $OUT/${prefix_R1}${i}_R1.fastq.gz | wc -l) " >> $OUT/tem_${i}.sh
	echo "b=\$(gunzip -dc $OUT/${prefix_R1}${i}_R2.fastq.gz | wc -l) " >> $OUT/tem_${i}.sh
	echo "if [[ \$a != \$line ]] || [[ \$b != \$line ]]; then" >> $OUT/tem_${i}.sh
	echo "	echo \"ERROR: ${prefix_R1}${i}.fastq.gz\" > ${OUT}/error.${prefix_R1}${i}" >> $OUT/tem_${i}.sh
	echo "else" >> $OUT/tem_${i}.sh
	echo "	echo \"DONE\"" >> $OUT/tem_${i}.sh
	echo "fi" >> $OUT/tem_${i}.sh
	eval "qsub -cwd -S /bin/bash -m abes -l vf=500M,p=1 -q dna.q,rna.q $OUT/tem_${i}.sh"
	#rm $OUT/tem_${i}.sh
	i=$[$i + $INT]
done



