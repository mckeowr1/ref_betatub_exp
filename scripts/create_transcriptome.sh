#!/bin/bash

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

# Accessing arguments
echo "genome_fa: $1"
echo "gff: $2"
echo "species: $3"

genome_fa=$1
gff_file=$2
species=$3

# get the name of the file without the extension
base_name=$(basename $gff_file)
out_file="data/proc/ref_transcriptomes/$species/$base_name.fa"

# Check if the directory exists, if not create it
dir=$(dirname $out_file)
if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
fi

gffread -w $out_file -g $genome_fa $gff_file 