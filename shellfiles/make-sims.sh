#!/bin/bash
modeNames=(rds rep dag not)
biasNames=(inf non all)
echo ./statnet -sbias:$2 -burn:$3 -mode:$4 -branch:$5 -seeds:$6 -file:$1 -graphstats:0
./statnet -sbias:$2 -burn:$3 -mode:$4 -branch:$5 -seeds:$6 -file:$1 -graphstats:0
