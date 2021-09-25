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
OUT4="out/output_4_final.txt"

echo "Running markov chain..."
pv in/genres.txt | ./quick-markov/markov 2000 > $OUT0
grep -F -x -v -f in/genres.txt $OUT0 > $OUT1
cp $OUT1 $OUT2

echo "Applying grammatical transformations..."
for line in $(cat in/contractions.csv)
do
	MATCH=`echo $line | awk -F, '{OFS=",";print $1}'`
	REPLACE=`echo $line | awk -F, '{OFS=",";print $2}'`
	sed -E -i "s/$MATCH/$REPLACE/g" $OUT2
	sed -E -i "s/$MATCH/$REPLACE/g" $OUT2
done

echo "Sorting output and discarding duplicates..."
IN=$(cat $OUT2 | wc -l)
pv $OUT2 | sort | uniq -u > $OUT3
OUT=$(cat $OUT3 | wc -l)
RATIO=$(calc "$OUT / $IN * 100")
echo "$RATIO% of output was duplicates"

echo -n "Deleting boring genres..."
grep -F -x -v -f in/delete.txt $OUT3 > $OUT4
IN=$(cat $OUT4 | wc -l)
RATIO=$(calc "$IN / $OUT * 100")
echo "$RATIO% reduction."

# Checks output by comparing the input corpus against the output
echo -n "Checking output uniqueness out of curiosity..."
OUT=$(comm -12 <(sort $OUT4) <(sort in/genres.txt) | wc -l)
IN=$(cat in/genres.txt | wc -l)
RATIO=$(calc "$OUT / $IN * 100")
echo "$RATIO%"