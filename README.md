
# Loading software 
Launch an interactive session
```bash
interact -n 1 -c 1 -a eande106 -m 10G -p express -t “30”
```


```bash
salmon_sif=/vast/eande106/singularity/salmon_1.10.1--h7e5ed60_0.sif

module load singularity

singularity shell $salmon_sif
```
This loads salmon v1.10.1 from a singularity file already on RF

# Generating salmon input files

## Transcriptome

The fasta file of the transcripts. Created with GFF read

The script `create_transcriptome.sh` creates a fasta file with the nucleotide sequences of features from the GFF. It takes the following inputs

- `genome_fa` genome.fa in this example would be a multi-fasta file with the genomic sequences of the target genome. Supplied as the `-g` parameter to gffread command
- `gff` gff file with transcripts to create a transcriptome

To create the transcriptome we use the `create_transcriptome.sh` script

```bash
module load singularity
singularity shell /vast/eande106/singularity/singularity-gffread-0.12.7--hdcf5f25_4.img
```
### C.briggsae
```bash
bash scripts/create_transcriptome.sh \
/vast/eande106/data/c_briggsae/genomes/QX1410_nanopore/Feb2020/c_briggsae.QX1410_nanopore.Feb2020.genome.fa \
data/proc/filtered_gffs/c_briggsae.QX1410_nanopore.Feb2020.csq.filtered.gff3 \
c_briggsae
```
### C.elegans
```bash
bash scripts/create_transcriptome.sh \
/vast/eande106/data/c_elegans/genomes/PRJNA13758/WS283/c_elegans.PRJNA13758.WS283.genome.fa \
data/proc/filtered_gffs/c_elegans.PRJNA13758.WS283.csq.filtered.gff3 \
c_elegans
```

### C.tropicalis
```bash
bash scripts/create_transcriptome.sh \
/vast/eande106/data/c_tropicalis/genomes/NIC58_nanopore/June2021/c_tropicalis.NIC58_nanopore.June2021.genome.fa \
data/proc/filtered_gffs/c_tropicalis.NIC58_nanopore.June2021.csq.filtered.gff3 \
c_tropicalis
```

### Filtering the GFF to remove transcripts

We need to remove gene prediction errors for the beta-tubulin genes from the gff before we create the transcriptome. This is performed with the `filter_gff.R` script. The output of this script is stored in `data/proc/filtered_gffs`

# Running salmon

## Running salmon without alignments

## Creating decoy transcriptomes
When salmon is not run in alignment mode it requires a decoy transcript data set

To create the decoy file set we have to load some software:
- bedtools V2.28.0
- mashmap V2.0
- awk 4.1.3

load conda
```bash
module load anaconda3/2022.05
``` 

```bash
conda create -n decoy_transcripts
```
/home/rmckeow1/.conda/envs/decoy_transcripts
Activate the env
```bash
source activate decoy_transcripts
```
Install bedtools
```bash
conda install bioconda::bedtools
```
Install Perl version that mashmap needs but conda command fails at
```bash
conda install conda-forge::perl
```
Install mashmap
```bash
conda install bioconda::mashmap
```
Run the script `run_create_decoys.sh`to generate decoy transcripts. This submits a job to the RF SLURM scheduler to run the `generateDecoyTransriptome.sh` script
```bash
bash scripts/generateDecoyTranscriptome.sh \
-g "/vast/eande106/data/c_briggsae/genomes/QX1410_nanopore/Feb2020/c_briggsae.QX1410_nanopore.Feb2020.genome.fa" \
-t "data/proc/ref_transcriptomes/c_briggsae/c_briggsae.QX1410_nanopore.Feb2020.csq.filtered.gff3.fa" \
-b "$HOME/.conda/envs/decoy_transcripts/bin/bedtools" \
-m "$HOME/.conda/envs/decoy_transcripts/bin/mashmap" \
-a "data/proc/filtered_gffs/c_briggsae.QX1410_nanopore.Feb2020.csq.filtered.gff3" \
-j 1 \
-o "data/proc/decoy_transcripts/c_briggsae"
```

## Running salmon in alignment mode
Salmon is run in alignment mode with the script `quant_alinged_reads.sh` with the command

```bash
salmon quant -t transcripts.fa -l A -a aln.bam -o salmon_quant
```
- `-t` is the transciptome file created by `create_transcriptome.sh`
- `-l` is a parmeter that specifes details about the sequencing library (relative-orientation of paired end reads). With the `-l A` flag we are telling salmon to automatically infer the orientation
- `-a` the alignments of the RNAseq reads
- `-o` name of the output

```bash
salmon_sif=/vast/eande106/singularity/salmon_1.10.1--h7e5ed60_0.sif

singularity shell $salmon_sif
```

C. briggsae

```bash 
bash scripts/quant_aligned_reads.sh \
"data/proc/ref_transcriptomes/c_briggsae/c_briggsae.QX1410_nanopore.Feb2020.csq.filtered.gff3.fa" \
"/vast/eande106/projects/Nicolas/c.briggsae/gene_predictions/QX1410/alignments/Aligned.out.bam"
```

## BAM files 

## C. briggsae & C. tropicalis
Nic shared the BAM files where RNA seq reads have already been aligned t

C.b:`/vast/eande106/projects/Nicolas/c.briggsae/gene_predictions/QX1410/alignmentsAligned.out.bam`

C.t:`/vast/eande106/projects/Nicolas/c.tropicalis/NIC58/alignments/Aligned.out.bam`
