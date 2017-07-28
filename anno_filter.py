#!/lustre/project/og04/wangxian/anaconda3/bin/python

# @wxian2017June02

# filter the anno_process(.var.join.tsv) output with the following conditions:
### impact_severity = HIGH
### clinvar_sig = pathogenic
### rs_ids != .
### AF >0.3

import sys, os, re
import pandas as pd
import fire
#subprocess.run(['mkdir', 'test'])

# === parse arg

#if len(sys.argv) == 1 or sys.argv[1] == '-h':
#    print ("Usage: {} <in_vcf> <in_anno> <out_file>".format(sys.argv[0]))
#    print('')
#    exit(1)

#VCF = sys.argv[1]
#ANNO = sys.argv[2]
#OUT_file = sys.argv[3]


def info_select(row):
    return float(re.findall(r"AF=(.*?);", row)[0])


#def CompareVar:
def compare_var(VCF, ANNO, OUT_FILE):
    """import file
    """
    vcf  = pd.read_csv(VCF, sep = '\t', skiprows = 2)
    info = vcf.INFO
    AF = info.apply(info_select,1)
    anno = (pd.read_csv(ANNO, sep = '\t')
    .join([AF])
    .rename(columns = {'INFO':'AF'})
    .query('impact_severity == "HIGH" & clinvar_sig == "pathogenic" & rs_ids != "." & AF > 0.3')
    .to_csv(OUT_FILE, sep='\t', index = False))
#def join(self, OUT_file):
    #a = pd.ncat([self.vcf, self.anno], axis = 0)
  #  a = anno.join([AF])
  #  a_f = a.query('impact_severity == "HIGH" & clinvar_sig == "pathogenic" & rs_ids != "." & INFO > 0.3 ')
  #  a_f.to_csv(OUT_FILE, sep='\t')
  #  a_f.to_csv(OUT_FILE, sep='\t', index = False)
   

    #del a_f['']


        


if __name__ == '__main__':
    fire.Fire(compare_var)
    
 









