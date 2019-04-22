#SBATCH --job-name=hisat2run
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --partition=general
#SBATCH --mail-type=END
#SBATCH --mail-user=
#SBATCH --mem=50G
#SBATCH -o hisat2run_%j.out
#SBATCH -e hisat2run_%j.err
module load hisat2
module load samtools
hisat2 -x arabidopsis_masked -1 trimmed_SRR6852085_1.fastq -2 trimmed_SRR6852085_2.fastq -p 16 -S SRR6852085.sam
samtools view -@ 16 -uhS SRR6852085.sam | samtools sort -@ 16 -o sorted_SRR6852085.bam
hisat2 -x arabidopsis_masked -1 trimmed_SRR6852086_1.fastq -2 trimmed_SRR6852085_2.fastq -p 16 -S SRR6852086.sam
samtools view -@ 16 -uhS SRR6852086.sam | samtools sort -@ 16 -o sorted_SRR6852086
