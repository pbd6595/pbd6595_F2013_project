#!/bin/bash -l
# NOTE the -l flag!
#

# This is an example job file for a single core CPU bound program
# Note that all of the following statements below that begin
# with #SBATCH are actually commands to the SLURM scheduler.
# Please copy this file to your home directory and modify it
# to suit your needs.
# 
# If you need any help, please email rc-help@rit.edu
#

# Name of the job - You'll probably want to customize this.
#SBATCH -J svm_tg.1

# Standard out and Standard Error output files

#To send emails, set the adcdress below and remove one of the "#" signs.  
#SBATCH --mail-user cmh@cs.rit.edu 
# notify on state change: BEGIN, END, FAIL or ALL #SBATCH --mail-type=ALL

# Request 5 minutes run time MAX, anything over will be KILLED
#SBATCH -t 12:0:0

# Put the job in the "debug" partition and request one core
# "debug" is a limited partition.  You'll likely want to change
# it to "work" once you understand how this all works.
#SBATCH -p work -n 1

# Job memory requirements in MB
#SBATCH --mem=12000

#
# Your job script goes below this line.  
modeNames=(rds rep dag)
biasNames=(inf non all)
pre=-s$5-${biasNames[$1]}-bu$2-${modeNames[$3]}-$4
mkfifo g$pre.pipe
echo -e "source ('rds.r')\ndraw.four('g--1.1$pre.join', 'g--1.4$pre.join', 'g--1.8$pre.join', 'g--3$pre.join',1.1,1.4,1.8,3)" >> g$pre.pipe &
R CMD BATCH g$pre.pipe g$pre.out
rm g$pre.pipe

