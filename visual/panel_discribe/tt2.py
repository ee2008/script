

import pandas as pd
import numpy as np

gff = pd.read_csv('/lustre/project/og04/pub/database/human_genome_hg19/gencode.v19.annotation.gff3',comment = '#',  sep = '\t', header = None) 
gff['gene'] = gff[8].str.extract('gene_name=(.*?);', expand = False)
gff.columns = ['chr_','source','type','start','end','other1','other2','other3','info','gene'] 
gff['length']=gff['end']-gff['start']

gff['transcript'] = gff['info'].str.extract('transcript_id=(.*?);', expand = False)

gff = gff.query('type!="gene"')
#gff = gff.query('other2!="-"')
gff = gff.groupby('gene').apply(lambda x:x[x['transcript']==x.loc[x['length'].idxmax()]['transcript']])

gff = gff.query('type!="transcript"')
gff = gff.query('type == "exon"')
gff['exon'] = gff['type'] + " " + gff['info'].str.extract('exon_number=(.*?);', expand = False)
gff['chr'] = gff['chr_'].str.slice(3,)

out = gff.loc[:,['chr','start','end','gene','transcript','exon']]

out.to_csv("./gff2_test.txt",sep="\t",index=False)









