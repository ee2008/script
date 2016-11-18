#!/bin/bash
# only use at local

if [[ $# -eq 0 ]]; then
	cat << EOF
Usage: sh $0 <R1.fastq.gz> [-l <region_len>] [-d] [-o <out_dir>] [-min <min_depth>] [-max <max_depth>] [-i <interval>] [-z] [-r]

Options:
	-l region_len
	-d only echo the depth of fastq(just need: <R1.fastq.gz> -l <region_len> -d)
	-o out_dir
	-min min_depth
	-max max_depth
	-i interval of depth
	-r split data at random
	-z unzip to folder(just need:<R1.fastq.gz> -l <region_len> -z) 
EOF
exit 0
fi

R1="$1"
d=0
z=0
r=0
while [[ $# -gt 1 ]];do
	key="$2"
	case $key in
		-l) LEN="$3"
			shift; ;;
		-d) d=1
			;;
		-z) z=1
			;;
		-r) r=1
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

[[ ! -d $OUT ]] && mkdir -pv $OUT

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
	echo "gunzip -c $R1 > $R1g" > $OUT/tem_R1.sh
	echo "echo \"DONE\" > $OUT/tem_R1.done" >> $OUT/tem_R1.sh
	echo "gunzip -c $R2 > $R2g" > $OUT/tem_R2.sh
	echo "echo \"DONE\" > $OUT/tem_R2.done" >> $OUT/tem_R2.sh
	eval "qsub -cwd -S /bin/bash -m abes -l vf=500M,p=1 -q dna.q,rna.q $OUT/tem_R1.sh"
	eval "qsub -cwd -S /bin/bash -m abes -l vf=500M,p=1 -q dna.q,rna.q $OUT/tem_R2.sh"
	for ((t=1;t<=30;t++)) 
	do
		if [[ -e $OUT/tem_R1.done ]] && [[ -e $OUT/tem_R2.done ]]; then
			echo "finshed unzip fastq.gz to $OUT"
			break
		else
			sleep 60s
		fi
	done
rm $OUT/tem_R1.sh $OUT/tem_R2.sh
rm $OUT/tem_R1.done $OUT/tem_R2.done
fi

i=$MIN
while [ $i -le $MAX ]
do
	line=$[(${LEN}*${i}/150)/2]
	#size=$[$line*150/(10**9)]
	line=$[${line}*4]
	echo "head -n $line $R1g | gzip > $OUT/${prefix_R1}${i}_R1.fastq.gz" >> $OUT/tem_${i}.sh
	echo "head -n $line $R2g | gzip > $OUT/${prefix_R1}${i}_R2.fastq.gz" >> $OUT/tem_${i}.sh
	echo "a=\$(gunzip -dc $OUT/${prefix_R1}${i}_R1.fastq.gz | wc -l) " >> $OUT/tem_${i}.sh
	echo "b=\$(gunzip -dc $OUT/${prefix_R1}${i}_R2.fastq.gz | wc -l) " >> $OUT/tem_${i}.sh
	echo "if [[ \$a != $line ]] || [[ \$b != $line ]]; then" >> $OUT/tem_${i}.sh
	echo "	echo \"ERROR: ${prefix_R1}${i}.fastq.gz\" > ${OUT}/error.${prefix_R1}${i}" >> $OUT/tem_${i}.sh
	echo "else" >> $OUT/tem_${i}.sh
	echo "	echo \"DONE\"" >> $OUT/tem_${i}.sh
	echo "fi" >> $OUT/tem_${i}.sh
	eval "qsub -cwd -S /bin/bash -m abes -l vf=500M,p=1 -q dna.q,rna.q $OUT/tem_${i}.sh"
	rm $OUT/tem_${i}.sh
	i=$[$i + $INT]
done



