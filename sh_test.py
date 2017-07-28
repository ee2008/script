import sh
#print(sh.wc(sh.ls('-1'), '-lhat'))
print(sh.ls('-a', '-l'))
#for line in sh.tr(sh.tail('-f', 'sh_test2.log', _piped =True),  "[:upper:]", "[:lower:]", _iter = True):
 #   print(line)
