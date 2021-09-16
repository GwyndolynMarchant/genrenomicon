#!/bin/bash
# Requirements
#	- pv
#	- grep
#	- sed

IFS=$'\n'

pv genres.txt | ./quick-markov/markov 10000 > output_0_markov.txt; grep -F -x -v -f genres.txt output_0_markov.txt > output_1_dedup.txt
cp output_1_dedup.txt output_2_contract.txt
for line in $(cat contractions.csv)
do
	MATCH=`echo $line | awk -F, '{OFS=",";print $1}'`
	REPLACE=`echo $line | awk -F, '{OFS=",";print $2}'`
	sed -E -i "s/$MATCH/$REPLACE/g" output_2_contract.txt
	sed -E -i "s/$MATCH/$REPLACE/g" output_2_contract.txt
done

pv output_2_contract.txt | sort | uniq -u > output_3_sort.txt
grep -F -x -v -f delete.txt output_3_sort.txt > output_4_deleted.txt
grep -F -x -v -f genres.txt output_4_deleted.txt > output_5_final.txt
