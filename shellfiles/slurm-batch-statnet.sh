#!/bin/bash -l

sbatch --qos=rc-normal -o q.15.out slurm-statnet.sh 6 0 1 100 1 g2-s6-mcmc-inf-b100
sbatch --qos=rc-normal -o q.14.out slurm-statnet.sh 6 1 1 100 1 g2-s6-mcmc-non-b100
sbatch --qos=rc-normal -o q.15.out slurm-statnet.sh 6 0 1 0 1 g2-s6-mcmc-inf
sbatch --qos=rc-normal -o q.14.out slurm-statnet.sh 6 1 1 0 1 g2-s6-mcmc-non
sbatch --qos=rc-normal -o q.15.out slurm-statnet.sh 6 0 0 200 2 g2-s6-rds-inf-b200
sbatch --qos=rc-normal -o q.14.out slurm-statnet.sh 6 1 0 200 2 g2-s6-rds-non-b200
sbatch --qos=rc-normal -o q.0.out slurm-statnet.sh 6 0 0 0 2 g2-s6-rds-inf
sbatch --qos=rc-normal -o q.13.out slurm-statnet.sh 6 1 0 0 2 g2-s6-rds-non
sbatch --qos=rc-normal -o q.2.out slurm-statnet.sh 6 0 1 0 2 g2-s6-replace-inf
sbatch --qos=rc-normal -o q.3.out slurm-statnet.sh 6 1 1 0 2 g2-s6-replace-non
sbatch --qos=rc-normal -o q.1.out slurm-statnet.sh 6 0 2 200 2 g2-s6-dag-inf-b200
sbatch --qos=rc-normal -o q.12.out slurm-statnet.sh 6 1 2 200 2 g2-s6-dag-non-b200
sbatch --qos=rc-normal -o q.2.out slurm-statnet.sh 6 0 1 200 2 g2-s6-replace-inf-b200
sbatch --qos=rc-normal -o q.3.out slurm-statnet.sh 6 1 1 200 2 g2-s6-replace-non-b200
sbatch --qos=rc-normal -o q.4.out slurm-statnet.sh 10 1 2 100 2 g2-s10-dag-non-b100
sbatch --qos=rc-normal -o q.5.out slurm-statnet.sh 10 0 2 100 2 g2-s10-dag-inf-b100
sbatch --qos=rc-normal -o q.6.out slurm-statnet.sh 10 1 1 100 2 g2-s10-replace-non-b100
sbatch --qos=rc-normal -o q.7.out slurm-statnet.sh 10 0 1 100 2 g2-s10-replace-inf-b100
sbatch --qos=rc-normal -o q.8.out slurm-statnet.sh 4 1 2 100 2 g2-s4-dag-non-b100
sbatch --qos=rc-normal -o q.9.out slurm-statnet.sh 4 0 2 100 2 g2-s4-dag-inf-b100
sbatch --qos=rc-normal -o q.10.out slurm-statnet.sh 4 1 1 100 2 g2-s4-replace-non-b100
sbatch --qos=rc-normal -o q.11.out slurm-statnet.sh 4 0 1 100 2 g2-s4-replace-inf-b100

