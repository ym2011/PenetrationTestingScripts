#!/usr/bin/python
#-*- coding:utf-8 -*-
########################################################################################################
#ipreverse.py - v0.0.1 20160402
########################################################################################################
#this is a simply methods to produce ip list with python 
#maybe I would add more functions into in it 
########################################################################################################
### 
########################################################################################################
#python ipreverse.py >> ips2.txt 
print """
this script wouldn products a series of ip depending on your choices 
press ' Ctrl + C ' to stop the process
如果想把 结果输出到文件中，可以使用如下命令：
python ipreverse.py >> ips.txt 
"""
#############################################################################
import sys
#origin = sys.stdout
#ips = open('ips.txt','w+')
#sys.stdout = ips


for a in range (0,255):
     for b in range (0,255):
		for c in range (0,255):
			for d in range (0,255):
				print str(a) +"." + str(b) + "." + str(c) + "." + str(d)

#sys.stdout = origin
#ips.close()



if __name__ == "__main__":
    main()
