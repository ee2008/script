#!/bin/bash

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 <input_vcf.annovar.hg19_multianno.txt> <output> [-s] [-g] [-db] [-cg] [-esp] [-c] [-e]

options:
	-s filter SIFT,Polyphen,MutationTaster,CADD
	-g filter 1000G(including 1000G_ALL,1000G_AFR,1000G_AMR,1000G_EAS,1000G_EUR,1000G_SAS)
	-db filter dbsnp 
	-cg filter cg(including cg46 cg69)
	-esp filter ESP6500(including ESP6500siv2_ALL,ESP6500siv2_AA,ESP6500siv2_EA)
	-c filter clinvar_20150629 cosmic70
	-e filter feature type(intronic,intergenic,downstream,upstream) 


EOF
exit 0
fi

csvcut="/nfs2/pipe/Re_/Software/bin/csvcut"
csvformat="/nfs2/pipe/Re_/Software/bin/csvformat"
perl_scr="$(dirname $0)/filter_annovar.pl"
input="$1"
output="$2"
s=0
g=0
db=0
cg=0
esp=0
c=0
e=0

info="Chr,Start,End,Ref,Alt,Func.ensGene,Gene.ensGene,GeneDetail.ensGene,SIFT_score,SIFT_pred,Polyphen2_HDIV_score,Polyphen2_HDIV_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,MutationTaster_score,MutationTaster_pred,CADD_raw,CADD_phred,1000G_ALL,1000G_AFR,1000G_AMR,1000G_EAS,1000G_EUR,1000G_SAS,avsnp144,dbSNP_ID,cg46,cg69,esp6500siv2_aa,esp6500siv2_all,esp6500siv2_ea,clinvar_20150629,cosmic70"

while [[ $# -gt 2 ]]; do
	key="$3"
	case $key in
		-s) s=1
			;;
		-g) g=1
			;;
		-db) db=1
			;;
		-cg) cg=1
			;;
		-esp) esp=1
			;;
		-c) c=1
			;;
		-e) e=1
			;;
	esac
	shift
done

out_path=$(dirname $output)
out_tem=$(basename $input)
$csvcut -t -c $info $input | $csvformat -T >> $out_path/tem.${out_tem}
perl_scr_generate=$out_path/generate.filter.pl

if [ $s == 1 ]; then
	cond="(\$line[8] ne \".\" ) && (\$line[10] ne \".\" ) && (\$line[12] ne \".\") && (\$line[14] ne \".\") && (\$line[16] ne \".\")"
	out_col="\$line[0],\$line[1],\$line[2],\$line[3],\$line[4],\$line[5],\$line[6],\$line[7],\$line[8],\$line[9],\$line[10],\$line[11],\$line[12],\$line[13],\$line[14],\$line[15],\$line[16],\$line[17]"
else
	cond="(\$line[0] ne \".\" )"
	out_col="\$line[0],\$line[1],\$line[2],\$line[3],\$line[4],\$line[5],\$line[6],\$line[7]"
fi

if [ $g == 1 ]; then
	cond=$cond" && (\$line[18] eq \".\" ) && (\$line[19] eq \".\" ) && (\$line[20] eq \".\" ) && (\$line[21] eq \".\" ) && (\$line[22] eq \".\" ) && (\$line[23] eq \".\" )"
fi

if [ $db == 1 ]; then
	cond=$cond" && (\$line[24] eq \".\" ) && (\$line[25] eq \".\" )"
fi

if [ $cg == 1 ]; then
	cond=$cond" && (\$line[26] eq \".\" ) && (\$line[27] eq \".\" )"
fi

if [ $esp == 1 ]; then
	cond=$cond" && (\$line[28] eq \".\" ) && (\$line[29] eq \".\" ) && (\$line[30] eq \".\" )"
fi

if [ $c == 1 ]; then
	cond=$cond" && (\$line[31] eq \".\" ) && (\$line[32] eq \".\" )"
fi

if [ $e == 1 ]; then
	cond=$cond" && (\$line[5] ne \"intronic\") && (\$line[5] ne \"intergenic\") && (\$line[5] ne \"downstream\") && (\$line[5] ne \"upstream\")"
fi

change_out="my \$out=join(\"\\t\",$out_col);"
change_cond="} elsif($cond) {"
cp $perl_scr $perl_scr_generate
echo "		$change_out">> $perl_scr_generate
echo "		print OUT \"\$out\\n\";" >> $perl_scr_generate
echo "	$change_cond" >> $perl_scr_generate
echo "		$change_out">> $perl_scr_generate
echo "		print OUT \"\$out\\n\";" >> $perl_scr_generate
echo "	}" >> $perl_scr_generate
echo "}"  >> $perl_scr_generate
echo "close IN;" >> $perl_scr_generate

/nfs2/pipe/Re/Software/miniconda/bin/perl $perl_scr_generate $out_path/tem.${out_tem} $output

rm $perl_scr_generate $out_path/tem.${out_tem}
