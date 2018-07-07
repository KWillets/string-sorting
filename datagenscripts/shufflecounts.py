#!/usr/bin/env python
import random
import sys

N = 1000000

if(len(sys.argv)>1):
  k = int(sys.argv[1])
else: 
  k = 1

assert k > 0

array = ['{0:07}'.format(x).replace('','*'*(k-1)).strip() for x in range(N)]
random.shuffle(array)
for s in array: 
  print(s)
