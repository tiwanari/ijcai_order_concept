#!/bin/sh
n=`grep -c '' all.txt`
for i in `seq 1 $n`
do
    mkdir -p query$i
    head -$i all.txt | tail -1 | tr "," '\n' > query$i/concepts.txt
    head -$i all_adj.txt | tail -1  > query$i/adjective.txt
    head -$i all_ant.txt | tail -1  > query$i/antonym.txt
done
