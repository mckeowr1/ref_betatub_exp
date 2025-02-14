#!/bin/bash

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

# Accessing arguments
echo "genome: $1"
echo "transcriptome: $2"
echo "gff: $3"


genome="$1"
transcriptome="$2"
gff="$3"

base_name=$(basename $transcriptome)
out_folder="data/proc/quant_reads/$base_name"

