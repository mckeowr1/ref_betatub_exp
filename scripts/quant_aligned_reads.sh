#!/bin/bash

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

# Accessing arguments
echo "transcriptome: $1"
echo "bam: $2"


transcriptome="$1"
bam="$2"

base_name=$(basename $transcriptome)
out_folder="data/proc/quant_reads/$base_name"

salmon quant -t $transcriptome -l A -a $bam -o $out_folder