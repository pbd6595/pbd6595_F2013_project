#!/bin/bash -l
for w in 1.1 1.4 1.8 3
do
	for bias in 0 1 2
	do
		for burn in 0 100
		do
	#		sbatch --qos=rc-normal -o c.$w.$bias.$burn.0.2.6.err make-sims.sh $w $bias $burn 0 2 6
	#		sbatch --qos=rc-normal -o c.$w.$bias.$burn.1.1.6.out make-sims.sh $w $bias $burn 1 1 6
	#		sbatch --qos=rc-normal -o c.$w.$bias.$burn.1.1.1.out make-sims.sh $w $bias $burn 1 1 1
	#		sbatch --qos=rc-normal -o c.$w.$bias.$burn.1.2.6.out make-sims.sh $w $bias $burn 1 2 6 
	#		sbatch --qos=rc-normal -o c.$w.$bias.$burn.2.2.6.out make-sims.sh $w $bias $burn 2 2 6 
			sbatch --qos=rc-normal -o c.$w.$bias.$burn.2.2.6.out make-sims.sh $w $bias $burn 3 2 6 
		done
	done
done
