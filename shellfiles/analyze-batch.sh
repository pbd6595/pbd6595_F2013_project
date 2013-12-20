#!/bin/bash -l
for bias in 0 1 2
do
	for burn in 0 100
	do
		sbatch --qos=rc-normal -o c.$bias.$burn.0.2.6.err analyze.sh $w $bias $burn 0 2 6
		sbatch --qos=rc-normal -o c.$bias.$burn.1.1.6.out analyze.sh $w $bias $burn 1 1 6
		sbatch --qos=rc-normal -o c.$bias.$burn.1.1.1.out analyze.sh $w $bias $burn 1 1 1
		sbatch --qos=rc-normal -o c.$bias.$burn.1.2.6.out analyze.sh $w $bias $burn 1 2 6 
		sbatch --qos=rc-normal -o c.$bias.$burn.2.2.6.out analyze.sh $w $bias $burn 2 2 6 
	done
done
