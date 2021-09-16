#!/bin/bash
# Requirements
#	- pv
#	- grep
#	- sed

IFS=$'\n'

OUT0="out/output_0_markov.txt"
OUT1="out/output_1_dedup.txt"
OUT2="out/output_2_contract.txt"
OUT3="out/output_3_sort.txt"
OUT4="out/output_4_deleted.txt"
OUT5="out/output_5_final.txt"

pv in/genres.txt | ./quick-markov/markov 10000 > $OUT0
grep -F -x -v -f in/genres.txt $OUT0 > $OUT1
cp $OUT1 $OUT2
for line in $(cat in/contractions.csv)
do
	MATCH=`echo $line | awk -F, '{OFS=",";print $1}'`
	REPLACE=`echo $line | awk -F, '{OFS=",";print $2}'`
	sed -E -i "s/$MATCH/$REPLACE/g" $OUT2
	sed -E -i "s/$MATCH/$REPLACE/g" $OUT2
done

pv $OUT2 | sort | uniq -u > $OUT3
grep -F -x -v -f in/delete.txt $OUT3 > $OUT4
grep -F -x -v -f in/genres.txt $OUT4 > $OUT5
