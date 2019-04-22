#!/bin/bash
#SBATCH --job-name=sra_download
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 30
#SBATCH --partition=himem
#SBATCH --mail-type=END
#SBATCH --mail-user=your.email@uconn.edu
#SBATCH --mem=256G
#SBATCH -o sra_download_%j.out
#SBATCH -e sra_download_%j.err
module load sratoolkit
module load sickle
fastq-dump --split-files SRR6852085
fastq-dump --split-files SRR6852086
sickle pe -s -t sanger -f SRR6852085_1.fastq -r SRR6852085_2.fastq -o trimmed_SRR6852085_1.fastq -p trimmed_SRR6852085_2.fastq -s trimmed_singles_6852085.fastq -q 30 -l 50
sickle pe -s -t sanger -f SRR6852086_1.fastq -r SRR6852086_2.fastq -o trimmed_SRR6852086_1.fastq -p trimmed_SRR6852086_2.fastq -s trimmed_singles_6852086.fastq -q 30 -l 50
