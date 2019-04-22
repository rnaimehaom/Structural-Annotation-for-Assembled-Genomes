#!/bin/bash
#SBATCH --job-name=repeat_modeler_db
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --partition=general
#SBATCH --mail-type=END
#SBATCH --mail-user=your.email@uconn.edu
#SBATCH --mem=50G
#SBATCH -o repeat_modeler_%j.out
#SBATCH -e repeat_modeler_%j.err
module load RepeatModeler
gunzip *.fa.gz
cat *.fa > athaliana.txt
mv athaliana.txt athaliana.fa
BuildDatabase -name "athaliana_db" -engine ncbi athaliana.fa
