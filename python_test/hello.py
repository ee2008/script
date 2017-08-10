# encoding='utf8'

import codecs

print "hello world!"

def read_csv(fname):
	my_dict = dict()
	f = open(fname)
	# lines = f.readlines()
	for line in f:
		line = line.strip('\n')
		attrs = line.split('\t')
		print attrs[1]
		my_dict[attrs[0]] = attrs[1]
	print my_dict.values()




# iterate list
for value in my_dict.values():
print value


if __name__ == '__main__':
	read_csv('./hello.csv')



