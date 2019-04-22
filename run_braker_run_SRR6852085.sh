#!/bin/bash
#SBATCH --job-name=run_braker_run_SRR6852085
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --partition=himem5
#SBATCH --mail-type=END
#SBATCH --mail-user=
#SBATCH --mem=256G
#SBATCH -o run_braker_run_SRR6852085_%j.out
#SBATCH -e run_braker_run_SRR6852085_%j.err
module load BRAKER
braker.pl --genome=athaliana.fa.masked --bam sorted_SRR6852085.bam --softmasking --AUGUSTUS_CONFIG_PATH=/home/CAM/your_username/3.2.3/config/
