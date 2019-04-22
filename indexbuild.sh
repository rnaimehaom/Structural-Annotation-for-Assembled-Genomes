#!/bin/bash
#SBATCH --job-name=indexbuild
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --partition=general
#SBATCH --mail-type=END
#SBATCH --mail-user=
#SBATCH --mem=50G
#SBATCH -o indexbuild_%j.out
#SBATCH -e indexbuild_%j.err
module load hisat2
hisat2-build -p 8 athaliana.fa.masked arabidopsis_masked
