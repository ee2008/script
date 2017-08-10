

import pandas as pd
import numpy as np

gff = pd.read_csv('./gff3.txt', sep = '\t', header = None) 
gff['gene'] = gff[8].str.extract('gene_name=(.*?);', expand = False)
gff.columns = ['chr','source','type','start','end','other1','other2','other3','info','gene'] 
gff['length']=gff['end']-gff['start']

#gff['info'].str.extract('transcript_id=(.*?);', expand = False)

nrow = len(gff.index)
gff = gff.query('type!="gene"')

a = gff.query('type=="transcript"').index + 1
b = list(a - 2)
b = b[1::]
b.append(nrow - 1 )

gff_transcript = gff.query('type=="transcript"')
gff_transcript['a'] = list(a)
gff_transcript['b'] = b
gff_transcript_max = gff_transcript.groupby('gene').apply(lambda t: t[t.length == t.length.max()])

idx=[]
for i in list(range(0,len(gff_transcript_max.index))):
    idx_range = list(range(gff_transcript_max.iloc[i,11],gff_transcript_max.iloc[i,12]+1))
    idx.extend(idx_range)

output = gff.loc[idx] 
#print (output)
output.to_csv("./tt.txt",sep="\t",index=False)









