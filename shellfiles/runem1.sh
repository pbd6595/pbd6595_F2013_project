#!/bin/bash
biasNames=(inf non all)
for size in 1000 715 525
do
	for w in 1.1 3
	do
		./make-test-graphs.sh $size $w g-$size-$w
		echo ./make-test-graphs.sh $size $w g-$size-$w
	done
done
for bias in 0
do
	for burn in 0
	do
		for w in 1.1 3
		do
			./make-sims.sh $w $bias $burn 0 2 6
			./make-sims.sh $w $bias $burn 2 2 6
			./make-sims.sh $w $bias $burn 1 2 6
		done
	done
	mkfifo draw.pipe
	echo -e "source('rds.r')\ndraw.twelve('s6-${biasNames[${bias}]}-bu${burn}')" >> draw.pipe &
	R CMD BATCH draw.pipe draw.output
	rm draw.pipe
done

