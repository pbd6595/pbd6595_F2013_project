#!/bin/bash -l
for size in 1000 835 715 625 555 525
do
	for w in 1.1 1.4 1.8 2
	do
		sbatch --qos=rc-normal -o c.1.out make-test-graphs.sh $size $w g-$size-$w
	done
done
