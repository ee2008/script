#-*-coding:utf-8-*-
#!/usr/bin/env python

# @wxian2017Feb28
# auto report 

from __future__ import print_function
from docx import Document
from docx.shared import Length, Pt
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
import xlrd, os, commands, argparse, zipfile, re
import pandas as pd
import numpy as np

import sys,getopt
opts, args = getopt.getopt(sys.argv[1:], "hp:o:")
project_dir = ""
output_dir = "./"

model_file = ""




for op, value in opts:
	if op == "-p":
		project_dir = value
	elif op == "-o":
		output_dir = value
		if os.path.exists(output_dir) != True:
			print ("mkdir output_dir:",output_dir)
			os.mkdir(output_dir)
	elif op == "-h":
		print ("Usage: python",sys.argv[0],"-p <project_dir> -o <output_dir | ./>")
		sys.exit()


## set the cover









#if __name__ == '__main__':
	


















