# @wxian

import pandas as pd
import numpy as np

import sys


panel_info_target = sys.argv[1]
output = sys.argv[2]

gff = pd.read_csv('/lustre/project/og04/pub/database/human_genome_hg19/gencode.v19.annotation.gff3',comment = '#',  sep = '\t', header = None) 
transcript_transvar = pd.read_csv(panel_info_target, comment = '#',  sep = '\t', header = None)
#transcript_transvar = pd.read_csv('/lustre/project/og04/wangxian/visual_test/panel_target.bed.transvr', comment = '#',  sep = '\t', header = None)
transcript_list = transcript_transvar[6].str.split(" ").str.get(0)
transcript_list = set(transcript_list).difference(set("."))

gff['gene'] = gff[8].str.extract('gene_name=(.*?);', expand = False)
gff.columns = ['chr_','source','type','start','end','other1','other2','other3','info','gene'] 

gff['transcript'] = gff['info'].str.extract('transcript_id=(.*?);', expand = False).str.split(".").str.get(0)

gff = gff.query('type!="gene"')
#gff = gff.query('other2!="-"')

gff = gff.query('transcript in @transcript_list')

gff = gff.query('type!="transcript" & type == "exon"')
gff['exon'] = gff['type'] + " " + gff['info'].str.extract('exon_number=(.*?);', expand = False)
gff['#chr'] = gff['chr_'].str.slice(3,)

out = gff.loc[:,['#chr','start','end','gene','transcript','exon']]

out.to_csv(output,sep="\t",index=False)









