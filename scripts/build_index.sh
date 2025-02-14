#!/bin/bash
#SBATCH -J job_name  # Name of job with date and time
#SBATCH -A eande106            # Allocation
#SBATCH --partition=shared
#SBATCH -t 00:50:00            # Walltime/duration of the job (hh:mm:ss)
#SBATCH --cpus-per-task=4     # Number of cores (= processors = cpus) for each task
#SBATCH --mem-per-cpu=8G       # Memory per core needed for a job
#SBATCH -o /vast/eande106/projects/Ryan/ref_betatub_exp/data/proc/quant_reads/logs/decoy.out  # Standard output log
#SBATCH -e /vast/eande106/projects/Ryan/ref_betatub_exp/data/proc/quant_reads/logs/decoy.err  # Standard error log

salmon_sif=/vast/eande106/singularity/salmon_1.10.1--h7e5ed60_0.sif
module load singularity
singularity shell $salmon_sif


# path to transcriptome.fa 
transcriptome="data/proc/ref_transcriptomes/c_briggsae/c_briggsae.QX1410_nanopore.Feb2020.csq.filtered.gff3.fa"

# path to the decoy transcripts
decoys="data/proc/decoy_transcripts/c_briggsae/decoys.txt"

base_name=$(basename $transcriptome)
transcriptome_dir=$(dirname "$transcriptome")
index_path="$transcriptome_dir/transcripts_index"


salmon index -t $transcriptome -i $index_path --decoys $decoys -k 31
