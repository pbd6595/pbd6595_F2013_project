#!/bin/bash
mkfifo $3.pipe
echo -e "source ('rds.r')\nget.more.tests($1,$2,'$3')" >> $3.pipe &
R CMD BATCH $3.pipe $3.output
rm $3.pipe