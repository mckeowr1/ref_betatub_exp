#!/bin/bash
#SBATCH -J job_name  # Name of job with date and time
#SBATCH -A eande106            # Allocation
#SBATCH --partition=shared
#SBATCH -t 00:30:00            # Walltime/duration of the job (hh:mm:ss)
#SBATCH --cpus-per-task=4     # Number of cores (= processors = cpus) for each task
#SBATCH --mem-per-cpu=8G       # Memory per core needed for a job
#SBATCH -o /vast/eande106/projects/Ryan/ref_betatub_exp/data/proc/decoy_transcripts/logs/decoy.out  # Standard output log
#SBATCH -e /vast/eande106/projects/Ryan/ref_betatub_exp/data/proc/decoy_transcripts/logs/decoy.err  # Standard error log


out_dir="data/proc/decoy_transcripts/c_briggsae"

# Check if the output directory exists
if [ -d "$out_dir" ]; then
  # If it exists, delete its content
  rm -rf "$out_dir"/*
else
  # If it doesn't exist, create it
  mkdir -p "$out_dir"
fi

module load anaconda3/2022.05
source activate decoy_transcripts

bash scripts/generateDecoyTranscriptome.sh \
-g "/vast/eande106/data/c_briggsae/genomes/QX1410_nanopore/Feb2020/c_briggsae.QX1410_nanopore.Feb2020.genome.fa" \
-t "data/proc/ref_transcriptomes/c_briggsae/c_briggsae.QX1410_nanopore.Feb2020.csq.gff3.fa" \
-b "$HOME/.conda/envs/decoy_transcripts/bin/bedtools" \
-m "$HOME/.conda/envs/decoy_transcripts/bin/mashmap" \
-a "/vast/eande106/data/c_briggsae/genomes/QX1410_nanopore/Feb2020/csq/c_briggsae.QX1410_nanopore.Feb2020.csq.gff3" \
-j 8 \
-o "$out_dir"

