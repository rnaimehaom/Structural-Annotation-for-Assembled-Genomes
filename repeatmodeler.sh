#!/bin/bash
#SBATCH --job-name=repeatmodelerhimem
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 30
#SBATCH --partition=himem3
#SBATCH --mail-type=END
#SBATCH --mail-user=your.email@uconn.edu
#SBATCH --mem=256G
#SBATCH -o repeatmaskrun_%j.out
#SBATCH -e repeatmaskrun_%j.err
module load RepeatModeler
RepeatModeler -engine ncbi -pa 30 -database athaliana_db
