#!/bin/bash
# vf=20G,p=2

#extract the alt frequency form varscan speedseq
# @wxian2016Sep28


[[ $# -eq 0 ]] && echo "Usage: sh $0 <project_dir> <in_file> <somatic/germline> <col_chr(from 0,1..)> <out_dir> <postfix>" && exit 0

PROJECT="$1"
IN="$2"
TYPE="$3"
CHR="$4"
OUT_dir="$5"
POSTFIX="$6"

[[ ! -d $OUT_dir ]] && mkdir  -pv $OUT_dir
PREFIX=$(basename $IN)
PREFIX=${PREFIX%%.*}
out_tem=$OUT_dir/${PREFIX}.${POSTFIX}_tem
out=$OUT_dir/${PREFIX}.${POSTFIX}
if [[ -e $out ]]; then
	rm $out
fi
if [[ -e $out_tem ]]; then
	rm $out_tem
fi

MUTECT=$PROJECT/var_mutect/$PREFIX.snv.mutect_all.vcf
SPEEDSEQ=$PROJECT/var/$PREFIX.var.vcf
if [ $TYPE == "germline" ]; then
	VARSCAN=$PROJECT/var_varscan/$PREFIX.snp.txt
else
	VARSCAN=$PROJECT/var_varscan/$PREFIX.snv.txt
fi


## function: extract the frequency

function frequency_g() {
	shift $CHR
	chr=$1
	po=$2
	ref=$4
	alt=$5
	if [[ $alt == "-" ]]; then
		po_fix=$[$po-1]
		speedseq_line=$(grep ^$chr$'\t'$po_fix$'\t' $SPEEDSEQ)
	elif [[ $ref == "-" ]]; then
		speedseq_line=$(awk -v k1=$chr -v k2=$po -v k4=$alt '{if ($1==k1 && $2==k2 && $5==k4) print}' $SPEEDSEQ)
		#speedseq_line=$(grep ^$chr$'\t'$po$'\t' $SPEEDSEQ | grep $alt$'\t')
	else 
		#speedseq_line=$(grep ^$chr$'\t'$po$'\t' $SPEEDSEQ | grep $ref$'\t'$alt$'\t')
		speedseq_line=$(awk -v k1=$chr -v k2=$po -v k3=$ref -v k4=$alt '{if ($1==k1 && $2==k2 && $4==k3 && $5==k4) print}' $SPEEDSEQ)
	fi
	if [[ -z $speedseq_line ]]; then
		speedseq_fre=".	.	."
	else
		speedseq_fre_all=$(echo $speedseq_line | cut -d " " -f 10)
		speedseq_fre=$(echo $speedseq_fre_all | awk -F ":" '{print $3"\t"$5"\t"$5/($3+$5)}')
	fi
	varscan_line=$(awk -v k1=$chr -v k2=$po -v k4=$alt '{if ($1==k1 && $2==k2 && $NF==k4) print}' $VARSCAN)
	if [[ -z $varscan_line ]]; then
		varscan_fre=".	.	."
	else
		varscan_fre=$(echo $varscan_line | awk -F " " '{print $5"\t"$6"\t"$6/($5+$6)}')	
	fi
	echo -e "$speedseq_fre\t$varscan_fre"
}

#somatic
function frequency_s() {
	shift $CHR
	chr=$1
	po=$2
	ref=$4
	alt=$5
	mutect_line=$(awk -v k1=$chr -v k2=$po -v k3=$ref -v k4=$alt '{if ($1==k1 && $2==k2 && $4==k3 && $5==k4) print}' $MUTECT)
#	mutect_line=$(grep  ^$chr$'\t'$po$'\t' $MUTECT | grep  $ref$'\t'$alt$'\t')	
	if [[ -z $mutect_line ]]; then
		mutect_out=".	.	.	.	.	."
	else
		mutect_N=$(echo $mutect_line | cut -d " " -f 10 | awk -F ":" '{print $2}')
		mutect_N_ref=$(echo $mutect_N | cut -d "," -f 1)
		mutect_N_alt=$(echo $mutect_N | cut -d "," -f 2)
		mutect_N_fre=$(echo $mutect_line | cut -d " " -f 10 | awk -F ":" '{print $5}')
		mutect_T=$(echo $mutect_line | cut -d " " -f 11 | awk -F ":" '{print $2}')
		mutect_T_ref=$(echo $mutect_T | cut -d "," -f 1)
		mutect_T_alt=$(echo $mutect_T | cut -d "," -f 2)
		mutect_T_fre=$(echo $mutect_line | cut -d " " -f 11 | awk -F ":" '{print $5}')
		mutect_out=$(echo -e "$mutect_N_ref\t$mutect_N_alt\t$mutect_N_fre\t$mutect_T_ref\t$mutect_T_alt\t$mutect_T_fre")
	fi
	if [[ $alt == "-" ]]; then
		po_fix=$[$po-1]
		speedseq_line=$(grep ^$chr$'\t'$po_fix$'\t' $SPEEDSEQ)
	elif [[ $ref == "-" ]]; then
		speedseq_line=$(awk -v k1=$chr -v k2=$po -v k4=$alt '{if ($1==k1 && $2==k2 && $5==k4) print}' $SPEEDSEQ)
		#speedseq_line=$(grep ^$chr$'\t'$po$'\t' $SPEEDSEQ | grep $alt$'\t')
	else 
		speedseq_line=$(awk -v k1=$chr -v k2=$po -v k3=$ref -v k4=$alt '{if ($1==k1 && $2==k2 && $4==k3 && $5==k4) print}' $SPEEDSEQ)
		#speedseq_line=$(grep ^$chr$'\t'$po$'\t' $SPEEDSEQ | grep $ref$'\t'$alt$'\t')
	fi
	if [[ -z $speedseq_line ]]; then
		speedseq_out=".	.	.	.	.	."
	else
		speedseq_N_all=$(echo $speedseq_line | cut -d " " -f 10)
		speedseq_N_depth=$(echo $speedseq_N_all | awk -F ":" '{print $4+$6}')
		if [[ $speedseq_N_depth -eq 0 ]]; then
			speedseq_N_fre=$(echo -e "0\t0\t0")
		else
			speedseq_N_fre=$(echo $speedseq_N_all | awk -F ":" '{print $4"\t"$6"\t"$6/($4+$6)}')
		fi
		speedseq_T_all=$(echo $speedseq_line | cut -d " " -f 11)
		speedseq_T_depth=$(echo $speedseq_T_all | awk -F ":" '{print $4+$6}')
		if [[ $speedseq_T_depth -eq 0 ]]; then
			speedseq_T_fre=$(echo -e "0\t0\t0")
		else
			speedseq_T_fre=$(echo $speedseq_T_all | awk -F ":" '{print $4"\t"$6"\t"$6/($4+$6)}')
		fi
		speedseq_out=$(echo -e "$speedseq_N_fre\t$speedseq_T_fre")
	fi
	#varscan_line=$(awk -v k1=$chr -v k2=$po -v k3=$po -v k4=$alt '{if ($1==k1 && $2==k2 && $3==k3 && $4==k4) print}' $VARSCAN)
	varscan_line=$(grep ^$chr$'\t'$po$'\t' $VARSCAN)		
	if [[ -z $varscan_line ]]; then
		varscan_out=".	.	.	.	.	."
	else
		varscan_N_depth=$(echo $varscan_line | awk -F " " '{print $5+$6}')
		if [[ $varscan_N_depth -eq 0 ]]; then
			varscan_out=$(echo $varscan_line | awk -F " " '{print $5"\t"$6"\t"0"\t"$9"\t"$10"\t"$10/($9+$10)}')
		else
			varscan_out=$(echo $varscan_line | awk -F " " '{print $5"\t"$6"\t"$6/($5+$6)"\t"$9"\t"$10"\t"$10/($9+$10)}')
		fi
	fi
	echo -e "$mutect_out\t$speedseq_out\t$varscan_out"
}	

echo "> START $0 @$(date)"
i=0
if [ $TYPE == "germline" ]; then
	while read line
	do
		if [[ $line == \#* ]] || [[ $line == \Chr* ]]; then
			head="$line\tspeedseq_ref\tspeedseq_alt\tspeedseq_fre\tvarscan_ref\tvarscan_alt\tvarscan_fre"
			continue
		fi
		i=$[i+1]
		argv=$(echo $line | cut -d " " -f 1-$[$CHR+5])
		if [ $i -le 8 ]; then
			echo -e "$line\t`frequency_g $argv`" > $out_tem.tem${i}&
		else
			echo -e "$line\t`frequency_g $argv`" > $out_tem.tem${i}&
			wait
			cat $out_tem.tem* >> $out_tem
			rm $out_tem.tem*
			i=0
		fi
	done < $IN
	wait
	cat $out_tem.tem* >> $out_tem
	rm $out_tem.tem*
else
	while read line
	do
		if [[ $line == \#* ]] || [[ $line == \Chr* ]]; then
			head="$line\tmutect_N_ref\tmutect_N_alt\tmutect_N_fre\tmutect_T_ref\tmutect_T_alt\tmutect_T_fre\tspeedseq_N_ref\tspeedseq_N_alt\tspeedseq_N_fre\tspeedseq_T_ref\tspeedseq_T_alt\tspeedseq_T_fre\tvarscan_N_ref\tvarscan_N_alt\tvarscan_N_altfre\tvarscan_T_ref\tvarscan_T_alt\tvarscan_T_fre" 
			continue
		fi
		i=$[i+1]
		argv=$(echo $line | cut -d " " -f 1-$[$CHR+5])
		if [ $i -le 8 ]; then
			echo -e "$line\t`frequency_s $argv`" > $out_tem.tem${i}&
		else
			echo -e "$line\t`frequency_s $argv`" > $out_tem.tem${i}&
			wait
			cat $out_tem.tem* >> $out_tem
			rm $out_tem.tem*
			i=0
		fi
	done < $IN
	wait
	cat $out_tem.tem* >> $out_tem
	rm $out_tem.tem*
fi

echo -e "$head" > $out
sort -k $[$CHR+1] -k $[$CHR+2]n $out_tem >> $out
rm $out_tem

echo "> DONE $0 @$(date)"
