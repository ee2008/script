#!/bin/bash

# call SV from bam via breakdancer (and/or) cnv (and/or) pindel (and/or) delly (and/or) lumpy
# @wxian^2016Feb15

# === env
BREAKDANCER_sh="$(dirname $0)/breakdancer.sh"
CNV_sh="$(dirname $0)/cnv.sh"
PINDEL_sh="$(dirname $0)/pindel.sh"
DELLY_sh="$(dirname $0)/delly.sh"
LUMPY_sh="$(dirname $0)/lumpy.sh"
DELLY_LENGTH_SV="$(dirname $0)/delly.length.sv.pl"
CNV_CHR="$(dirname $0)/cnv.chr.pl"
INTANSV="$(dirname $0)/intansv.R"
export LD_LIBRARY_PATH="/nfs2/pipe/Re/Software/miniconda/lib:"$LD_LIBRARY_PATH

# === parameter
chr="-chr 0"
delly_type="-type DEL DUP INV TRA INS"

# === argv
[[ $# -lt 2 ]] && echo "Usage: sh $0 <bam> <fasta> [-gff3 <gff3_file>|human.v19.gff3] [-out <out_dir>|bam_dir] [breakdancer] [cnv] [pindel] [delly] [lumpy]" && exit

# call SV from bam via breakdancer (and/or) cnv (and/or) pindel (and/or) delly (and/or) lumpy

bam="$1"
fasta="$2"
prefix=$(basename $bam .bam)

# == gff3 file
if [[ "$3" == '-gff3' ]]; then
	if [[ -z "$4" ]]; then
		echo "no file after -gff3" && exit 1
	fi
	gff3="$4"
	shift 2
else
	gff3="/lustre/project/og04/pub/database/human_genome_hg19/gencode.v19.annotation_nochr.gff3"
fi

# == output
if [[ "$3" == '-out' ]]; then
	if [[ -z "$4" ]]; then
		echo "no output directory after -out" && exit 1
	fi
	output_dir="$4"
	shift 2
else
	output_dir=$(dirname $bam)
fi
output_file=${output_dir}/${prefix}.input_intansv

[[ ! -d $output_file ]] && mkdir $output_file
echo ">> output_dir:$output_file"

[[ $# -eq 2 ]] && echo "! no specific software to call sv" && exit 1
while [[ $# -gt 2 ]]; do
	key="$3"
	case $key in 
		breakdancer) echo ">> call SV via breakdancer"
					 out_breakdancer=${output_file}/breakdancer
					 mkdir $out_breakdancer
					 echo ">> outcome of breakdancer:$out_breakdancer"
					 ;;
		cnv) echo ">> call SV via cnv"
		     out_cnv=${output_file}/cnv 
			 mkdir $out_cnv
			 echo ">> outcome of cnv:$out_cnv"
			 ;;
	    pindel) echo ">> call SV via pindel"
				out_pindel=${output_file}/pindel
				mkdir $out_pindel
				out_prefix="-outpre $prefix"
				echo ">> outcome of pindel:$out_pindel"
				;;
		delly) echo ">> call SV via delly"
			   out_delly_old=${output_file}/delly_old
			   out_delly=${output_file}/delly
			   mkdir $out_delly_old
			   mkdir $out_delly
			   echo ">> outcome of delly:$out_delly"
			   ;;
		lumpy) echo ">> call SV via lumpy"
			   out_lumpy=${output_file}/lumpy
			   mkdir $out_lumpy
			   echo ">> outcome of lumpy:$out_lumpy"
			   ;;
	esac
	shift
done

if [[ -d $out_breakdancer ]]; then
	sh $BREAKDANCER_sh $bam $out_breakdancer&
fi

if [[ -d $out_cnv ]]; then
	sh $CNV_sh $bam $(dirname $fasta) $chr $out_cnv&
fi

if [[ -d $out_pindel ]]; then
	sh $PINDEL_sh $bam $fasta $chr $out_prefix $out_pindel&
fi

if [[ -d $out_delly_old ]]; then
	sh $DELLY_sh $bam $fasta $out_delly_old $delly_type&
fi

if [[ -d $out_lumpy ]]; then
	sh $LUMPY_sh $bam $out_lumpy&
fi
wait

if [[ -d $out_cnv ]]; then
	cnv_log=${out_cnv}/${prefix}.cnvnator.log
	cnv_old=${out_cnv}/${prefix}.cnv.old
	cnv=${out_cnv}/${prefix}.cnv
	mv $cnv $cnv_old
	perl $CNV_CHR $cnv_old $cnv
	rm $cnv_old
	root=${out_cnv}/${prefix}.root
	mv $cnv_log $output_file
	mv $root $output_file
fi

if [[ -d $out_delly_old ]]; then
	perl $DELLY_LENGTH_SV $out_delly_old $out_delly
	delly_ins=${out_delly}/${prefix}.INS.vcf
	delly_tra=${out_delly}/${prefix}.TRA.vcf
	[[ -f $delly_ins ]] && mv $delly_ins $output_file
	[[ -f $delly_tra ]] && mv $delly_tra $output_file
	rm -r $out_delly_old
fi

if [[ -d $out_lumpy ]]; then
	HISTO=${out_lumpy}/${prefix}.lib.histo
	mv $HISTO $output_file
fi
 
# annotation via R package-- intansv
echo ">> START $INTANSV for annotation"`date`
$INTANSV $output_file $prefix $gff3



echo "> DONE $0"`date`  
