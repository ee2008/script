#!/bin/bash

csvcut="/nfs2/pipe/Re_/Software/bin/csvcut"
csvformat="/nfs2/pipe/Re_/Software/bin/csvformat"

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 <input_vcf.annovar.hg19_multianno.txt> <output> [-s] [-g] [-db] [-cg] [-esp] [-c] [-e]

options:
	-s extract SIFT,Polyphen,MutationTaster,CADD
	-g extract 1000G(including 1000G_ALL,1000G_AFR,1000G_AMR,1000G_EAS,1000G_EUR,1000G_SAS)
	-db extract dbsnp 
	-cg extract cg(including cg46 cg69)
	-esp extract ESP6500(including ESP6500siv2_ALL,ESP6500siv2_AA,ESP6500siv2_EA)
	-c extract clinvar_20150629 cosmic70


EOF
exit 0
fi

input="$1"
output="$2"

info="Chr,Start,End,Ref,Alt,Func.ensGene,Gene.ensGene,GeneDetail.ensGene"

while [[ $# -gt 2 ]]; do
	key="$3"
	case $key in
		-s) info=${info},SIFT_score,SIFT_pred,Polyphen2_HDIV_score,Polyphen2_HDIV_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,MutationTaster_score,MutationTaster_pred,CADD_raw,CADD_phred
			;;
		-g) info=${info},1000G_ALL,1000G_AFR,1000G_AMR,1000G_EAS,1000G_EUR,1000G_SAS
			;;
		-db) info=${info},avsnp144,dbSNP_ID
			;;
		-cg) info=${info},cg46,cg69
			;;
		-esp) info=${info},esp6500siv2_aa,esp6500siv2_all,esp6500siv2_ea
			;;
		-c) info=${info},clinvar_20150629,cosmic70
			;;
	esac
	shift
done

$csvcut -t -c $info $input | $csvformat -T > $output

echo $info
