#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Usage: remove_concepts_from_human_annotation.py all.txt < ynaga.txt
import sys, re

probs = []
for line in open (sys.argv[1]):
    probs.append (line[:-1].split(','))

n = 0
for line in sys.stdin:
    if re.search (r'=|>', line[:-1]):
        s  = re.sub (r'\s+', '', line[:-1]) # delete spaces
        s  = re.sub (r'>+', '>', s)         # reduce '>>' -> '>'
        fs = re.split (r'>', s)             # split by '>'
        fs = [[y for y in x.split ('=') if y in probs[n]] # check elements
              for x in fs]
        print ' > '.join ([' = '.join (z) for z in fs if z])  # convert to str
    else:
        if not line[:-1]:
            n += 1
        sys.stdout.write (line)
