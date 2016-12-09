#/bin/bash

#extract the alt frequency form varscan speedseq
# @wxian2016Sep28

## script
PANEL_s=$(dirname $(readlink -e $0))/panel_intersection.pl
FRE_sv_s=$(dirname $(readlink -e $0))/frequency_sv.pl
FRE_var_s=$(dirname $(readlink -e $0))/frequency_var.sh

if [[ $# -eq 0 ]]; then
	cat <<EOF
Usage: sh $0 <-i project_dir> <-s in_file> [-f|inactive] [-p|inactive] [-pi panel_info|latest_panel1_info] [-c <col_in_panel.info|none> <"keyword1 keyword2 ..."|none)>] [-r range|0] [-o out_dir|project_dir] [-pf <postfix>|panel_frequency.tsv]

options:
	-i	project_dir
	-s	input_file
	-f (default: inactive): extract the mutation frequency
	#-p (default: inactive): extract the intersection with panel_info
	#-pi	panel_info(default: latest_panel1_info): only use after -p
	#-c	col_in_panel(default:none)	"keyword1 keyword2 ..."(default:none): only use after -p
	#-r	range_of_po(default:0): only use after -p
	-o	out_dir(default:project_dir)
	-pf	output_postfix(default: panel_frequency.tsv (example: sample.var.panel_frequency.tsv))

EOF
exit 0
fi

panel="/lustre/project/og04/wangxian/panel_exon/database_uniq_sorted.format.txt_exon"
f=0
p=0
c=0
ran=0
postfix="panel_frequency.tsv"

while [[ $# -gt 0 ]];do
	key="$1"
	case $key in
		-i) in_dir=$(readlink -e $2)
			shift; ;;
		-s) IN=$(readlink -e $2)
			shift; ;;
		-f) f=1
			;;
		-p) p=1
			;;
		-pi) panel="$2"
			 shift; ;;
		-c) c=1
			col_index="$2"
			keyword="$3"
			shift 2; ;;
		-r) ran="$2"
			shift; ;;
		-o) out_dir="$2"
			shift; ;;
		-pf) postfix="$2"
			 shift; ;;
	esac
	shift
done

if [[ ! -e $IN ]]; then
	echo "!! error: no input named $IN"
	exit 1
fi
file_name=$(basename $IN)
sample=${file_name%%.*}

if [[ $sample == *-VS-* ]]; then
	t="somatic"
else
	t="germline"
fi

m_type=$(echo $file_name | cut -d "." -f 2)
if [[ $m_type != "var" ]] && [[ $m_type != "sv" ]]; then
	echo "!! error: unrecognized  mutation type(sv or var)"
	exit 1
fi
postfix_p=$postfix
postfix=$m_type.$postfix

if [[ $p -eq $f ]] && [[ $p -eq 0 ]]; then
	echo "!! error: use -p or -f at least"
	exit 1
fi

if [[ -z $out_dir ]]; then
	out_dir=$in_dir
else
	[[ ! -d $out_dir ]] && mkdir -pv $out_dir
fi
out_file=$out_dir/$sample.$m_type.$postfix


if [[ $p -eq $f ]] && [[ $p -eq 1 ]]; then
	chr=$(head -n 1 $panel | awk '{print NF}')
else
	chr=0
fi

if [[ $c -eq 1 ]]; then
	for i in ${keyword[@]}
	do
		keyword_array="$keyword_array -k ${i}"
	done
	col_argv="-c $col_index $keyword_array"
else
	col_argv=""
fi

if [[ $p -eq 1 ]]; then
	if [[ $f -eq 0 ]]; then
		eval /nfs2/pipe/Re/Software/miniconda/bin/perl $PANEL_s -i $IN -p $panel $col_argv -o $out_dir -pf $postfix_p -r $ran
#		echo "/nfs2/pipe/Re/Software/miniconda/bin/perl $PANEL_s -i $IN -p $panel $col_argv -o $out_dir -pf $postfix_p -r $ran"
	else
		eval /nfs2/pipe/Re/Software/miniconda/bin/perl $PANEL_s -i $IN -p $panel $col_argv -o $out_dir -pf panel_intersection.tsv -r $ran
#		echo "/nfs2/pipe/Re/Software/miniconda/bin/perl $PANEL_s -i $IN -p $panel $col_argv -o $out_dir -pf panel_intersection.tsv -r $ran"
	fi
	IN_f=$out_dir/${sample}.${m_type}.panel_intersection.tsv
else
	IN_f=$IN
fi

if [[ $f -eq 1 ]]; then
	if [ $m_type == "var" ]; then
#		echo "sh $FRE_var_s $in_dir $IN_f $t $chr $out_dir $postfix"
		sh $FRE_var_s $in_dir $IN_f $t $chr $out_dir $postfix
else
#		echo "/nfs2/pipe/Re/Software/miniconda/bin/perl $FRE_sv_s $in_dir $IN_f $t $chr $out_dir $postfix"
		/nfs2/pipe/Re/Software/miniconda/bin/perl $FRE_sv_s $in_dir $IN_f $t $chr $out_dir $postfix
	fi
fi
		
if [[ $p -eq 1 ]] && [[ $f -eq 1 ]]; then
	rm $IN_f
fi

