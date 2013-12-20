pbd6595_F2013_project
=====================

Building and Running RDS Simulations

To Run RDS Simulation code following essentials must be installed on the Linux system:

1. R (2.14 and higher)
2. SNAP (Version 1.1)

The controller is written as shell script. The script performs two important functions:
1. Generate test graphs using ERGM's by calling code in R i.e. rds.r
2. Simulate RDS using SNAP library by calling cpp code i.e. statnet.cpp

Steps to run the code:
1. Make clean the cpp code: Command--> make clean
2. Compile cpp code using Makefile: Command--> make
3. Kickstart the controller which automatically calls code in R and cpp: Command--> ./runem1.sh

The code runs for a while depending on the number of simulations and produce output as pdf with box plots for each graph sizes.
