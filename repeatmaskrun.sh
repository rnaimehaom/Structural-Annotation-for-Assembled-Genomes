#!/bin/bash
#SBATCH --job-name=repeatmaskrunhimem
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --partition=himem3
#SBATCH --mail-type=END
#SBATCH --mail-user=your.email@uconn.edu
#SBATCH --mem=256G
#SBATCH -o repeatmaskrun_%j.out
#SBATCH -e repeatmaskrun_%j.err
module load RepeatMasker
RepeatMasker -pa 16 -lib consensi.fa -xsmall /home/CAM/your_username/annotation_tutorial/athaliana.fa
