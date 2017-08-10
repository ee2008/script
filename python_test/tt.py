#!/nfs/pipe/Re/Software/bin/python2.7 

import sys

people=['adam', 'LISA', 'barT']

def name(x):
	if not x[0].isupper():
		head=x[0].upper()
	else:
		head=x[0]
	s=x[1:len(x)]
	if s.isupper():
		tail=s.lower()
	else:
		tail=s
	print head+tail

map(name,people)




#def fib(max):
#	n, a, b = 0, 0, 1
#	while n < max:
#		print n
#		yield b
#		a, b = b, a + b
#		n = n + 1
#
#for i in fib(6):
#	print "hao"
#	print i

#d=dict()
#d['Adam'] = 67
#d['bacr'] = 63
#d['cdam'] = 60

#if 'bacr' not in d:
#	print d.values()
#	print d.keys()
#else:
#	print "hao"

#name = sys.argv[1]
#cost = sys.argv[2]
#out = 'hi, %s, you have $%s.' %(name,cost)
#print out

#name = raw_input('please enter your name: ')
#print 'hello,', name

#if 5 > 3 and 5 > 4:
#	print "hao"
#else:
#	print "no"




