# Structural Annotation for Assembled Genomes
This repository is a usable, publicly available differential expression and functional annotation tutorial.
All steps have been provided for the UConn CBC Xanadu cluster here with appropriate headers for the Slurm scheduler that can be modified simply to run.  Commands should never be executed on the submit nodes of any HPC machine.  If working on the Xanadu cluster, you should use sbatch scriptname after modifying the script for each stage.  Basic editing of all scripts can be performed on the server with tools, such as nano, vim, or emacs.  If you are new to Linux, please use <a href="https://bioinformatics.uconn.edu/unix-basics/">this</a> handy guide for the operating system commands.  In this guide, you will be working with common bioinformatic file formats, such as <a href="https://en.wikipedia.org/wiki/FASTA_format">FASTA</a>, <a href="https://en.wikipedia.org/wiki/FASTQ_format">FASTQ</a>, <a href="https://en.wikipedia.org/wiki/SAM_(file_format)">SAM/BAM</a>, and <a href="https://en.wikipedia.org/wiki/General_feature_format">GFF3/GTF</a>. You can learn even more about each file format <a href="https://bioinformatics.uconn.edu/resources-and-events/tutorials/file-formats-tutorial/">here</a>. If you do not have a Xanadu account and are an affiliate of UConn/UCHC, please apply for one <a href="https://bioinformatics.uconn.edu/contact-us/">here</a>.
	
<div id="toc_container">
<p class="toc_title">Contents</p>
<ul class="toc_list">
<li><a href="#First_Point_Header">1 Overview<a/></li>
<li><a href="#Second_Point_Header">2 Downloading the data</a></li>
<li><a href="#Third_Point_Header">3 Identifying Regions of Genomic Repetition with RepeatModeler</a></li>
<li><a href="#Fourth_Point_Header">4 Masking Regions of Genomic Repetition with RepeatMasker</a></li>
<li><a href="#Fifth_Point_Header">5 Mapping RNA-Seq reads with HISAT2</a></li>
<li><a href="#Sixth_Point_Header">6 BRAKER2: Identifying and Predicting Genes with RNA-Seq data</a></li>
<li><a href="#EnTAP">7 EnTAP: Functional Annotation for Genomes</a></li>
 <li><a href="#Integration">8 Integrating the DE Results with the Annotation Results</a></li>
<li><a href="#Citation">Citations</a></li>
</ul>
</div>

<h2 id="First_Point_Header">Overview</h2>
In this tutorial we will be performing functional and structural annotation of <i>Arabidopsis thaliana</i> using <a href="https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP135923transcriptomic"></a> data of its leaves at 4 weeks of age and software on the Xanadu cluster. The Xanadu cluster may be accessed via SSH with the following terminal command:

<pre style="color: silver; background: black;">ssh your.user.name@xanadu-submit-ext-cam.uchc.edu</pre>

It is important that after connecting via SSH the directory is set to

<pre style="color: silver; background: black;">cd /home/CAM/$your.user.name/</pre> 

before proceeding. Your home directory contains 10TB of storage and will not pollute the capacities of other users on the cluster. 

The workflow may be cloned into the appropriate directory using the terminal command:
<pre style="color: silver; background: black;">$git clone https://github.com/wolf-adam-eily/structural_annotation_for_assembled_genomes_xanadu.git
$cd structural_annotation_for_assembled_genomes_xanadu
$ls  </pre>

<h2 id="Second_Point_Header">Downloading the data</h2>
Besides our RNA-Seq reads, the only other data required for our annotation is the <i>Arabidopsis thaliana</i> reference genome (this does not include the databases installed with the various software used in this tutorial). While the reference genome may be found on the NCBI website, we will be using the un-annotated genome located on Xanadu. You can copy the reference genome to your directory with the following command:
<pre style="color: silver; background: black;">cp /isg/shared/databases/alignerIndex/plant/Arabidopsis/thaliana/Athaliana_167_TAIR9.fa /$HOME/structural_annotation_for_assembled_genomes_xanadu/athaliana.fa</pre>

Now, we must download our RNA-Seq using the <a href="https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=toolkit_doc">SRA-toolkit</a>. We will be running this command as a <a href="https://bioinformatics.uconn.edu/resources-and-events/tutorials/xanadu/#Xanadu_6">Slurm scheduler</a> script. For more information, please visit the link provided. To initialize our Slurm script, we use the "nano" command as following:

<pre style="color: silver; background: black;">nano sra_download.sh
 GNU nano 2.3.1            File: sra_download.sh                               




















                                  [ New File ]
^G Get Help  ^O WriteOut  ^R Read File ^Y Prev Page ^K Cut Text  ^C Cur Pos
^X Exit      ^J Justify   ^W Where Is  ^V Next Page ^U UnCut Text^T To Spell</pre>

We may now begin writing our "&#35;SBATCH" arguments followed by our actual script commands (edit the email argument or you will not receive your process updates!):

<pre style="color: silver; background: black;">  GNU nano 2.3.1            File: sra_download.sh                     Modified  

#!/bin/bash
#SBATCH --job-name=sra_download.sh
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




^G Get Help  ^O WriteOut  ^R Read File ^Y Prev Page ^K Cut Text  ^C Cur Pos
^X Exit      ^J Justify   ^W Where Is  ^V Next Page ^U UnCut Text^T To Spell</pre>

Press CTRL+X, "y", "enter" to save your script. You may only use software previously loaded onto the Xanadu server, and cannot load your own. To view which modules you may use on Xanadu enter:
<pre style="color: silver; background: black;">module avail</pre>
Because of this, we must load the modules we wish to use in each script. In this case, we are going to utilize the sratookit with the command:
<pre style="color: silver; background: black;">module load sratoolkit</pre>
It is important to know the layout of your SRA reads. For us, we are using paired-end reads. In future steps, we will want to be able to have two files, right-hand and left-hand, for each read which we can instruct our software to treat as paired. However, the SRA reads are compiled into a single file! To subvert this, we use the "--split-files" option of the sratoolkit to save each read in two separate files corresponding to the left-hand and right-hand reads. We also want to trim our files to only take high-quality reads. We use the program <a href="https://github.com/najoshi/sickle">sickle</a> to trim our files. For information on sickle and its options, you may visit the paired-end reference section of the github provided prior. To view the options for paired-end reads we use:
<pre style="color: silver; background: black;">module load sickle
sickle
Usage: sickle <command> [options]

Command:
pe	paired-end sequence trimming
se	single-end sequence trimming

sickle pe

Options:
Paired-end separated reads
--------------------------
-f, --pe-file1, Input paired-end forward fastq file (Input files must have same number of records)
-r, --pe-file2, Input paired-end reverse fastq file
-o, --output-pe1, Output trimmed forward fastq file
-p, --output-pe2, Output trimmed reverse fastq file. Must use -s option.</pre>

Let's submit our script and view the results:
<pre style="color: silver; background: black;">sbatch sra_download.sh
ls
SRR6852085_1.fastq
SRR6852085_2.fastq
SRR6852086_1.fastq
SRR6852086_2.fastq
trimmed_SRR6852085_1.fastq
trimmed_SRR6852085_2.fastq
trimmed_SRR6852086_1.fastq
trimmed_SRR6852086_2.fastq
</pre>

<h2 id="Third_Point_Header">Identifying Regions of Genomic Repetition with RepeatModeler</h2>
The largest proportion of genomes are low complexity regions, often consisting of <a href="https://en.wikipedia.org/wiki/Repeated_sequence_(DNA)">repetitive elements</a>. While these regions play crucial roles in safe-guarding the genome from deleterious mutations, novel protein synthesis, reproduction, and other processes, by virtue of their low-complexity they are quite common across organisms, even somewhat distantly unrelated organisms. Because of this, it can be hazardous to include these regions in alignment processes, as there is run a risk of false positives in the alignment profile. However, discarding low-complexity regions may also run the risk of removing high quality gene models alongside them. It is important to bear in mind your research goals and ambitions, choosing your modifications wisely. We will first be identifying our regions of low complexity using the <a href="http://www.repeatmasker.org/RepeatModeler/">RepeatModeler</a>. Before we identify our repeat regions, we must first compile our database using the "BuildDatabase" command of RepeatModeler. We may see our options with the following code in the bash:

<pre style="color: silver; background: black;">module load RepeatModeler
BuildDatabase
No query sequence file indicated

NAME
    BuildDatabase - Format FASTA files for use with RepeatModeler

SYNOPSIS
      BuildDatabase [-options] -name "mydb" <seqfile(s) in fasta format>
     or 
      BuildDatabase [-options] -name "mydb" 
                                  -dir <dir containing fasta files &#42;.fa, &#42;.fasta,
                                         &#42;.fast, &#42;.FA, &#42;.FASTA, &#42;.FAST, &#42;.dna,
                                         and  &#42;.DNA > 
     or
      BuildDatabase [-options] -name "mydb" 
                                  -batch <file containing a list of fasta files></pre>

Let's build our database using nano to create our Slurm script:
<pre style="color: silver; background: black;">nano repeat_modeler_db.sh
  GNU nano 2.3.1          File: repeat_modeler_db.sh                            

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
BuildDatabase -name "athaliana_db" -engine ncbi athaliana.fa


^G Get Help  ^O WriteOut  ^R Read File ^Y Prev Page ^K Cut Text  ^C Cur Pos
^X Exit      ^J Justify   ^W Where Is  ^V Next Page ^U UnCut Text^T To Spell</pre>

<pre style="color: silver; background: black;">sbatch repeat_modeler_db.sh
ls
athaliana_db.nhr
athaliana_db.nin
athaliana_db.nni
athaliana_db.nog
athaliana_db.nsq
athaliana_db.translation
</pre>

It is not important that you understand what each file represents. However, if you are interested in varying that all of your choromosomes were compiled, you may view the .translation file. It should look like:
<pre style="color: silver; background: black;">head athaliana_db.translation
Chr1	1
Chr2	2
Chr3	3
Chr4	4
Chr5	5
ChrM	6
ChrC	7</pre>

We see that all seven chromosomes were succesffuly compiled!

We are now ready to run the RepeatModeler. But first, let's have a look at our options:

<pre style="color: silver; background: black;">RepeatModeler
No database indicated

NAME
    RepeatModeler - Model repetitive DNA

SYNOPSIS
      RepeatModeler [-options] -database <XDF Database>

DESCRIPTION
    The options are:

    -h(elp)
        Detailed help

    -database
        The prefix name of a XDF formatted sequence database containing the
        genomic sequence to use when building repeat models. The database
        may be created with the WUBlast "xdformat" utility or with the
        RepeatModeler wrapper script "BuildXDFDatabase".

    -engine <abblast|wublast|ncbi>
        The name of the search engine we are using. I.e abblast/wublast or
        ncbi (rmblast version).

    -pa #
        Specify the number of shared-memory processors available to this
        program. RepeatModeler will use the processors to run BLAST searches
        in parallel. i.e on a machine with 10 cores one might use 1 core for
        the script and 9 cores for the BLAST searches by running with "-pa
        9".

    -recoverDir <Previous Output Directory>
        If a run fails in the middle of processing, it may be possible
        recover some results and continue where the previous run left off.
        Simply supply the output directory where the results of the failed
        run were saved and the program will attempt to recover and continue
        the run.</pre>
	
The options are quite straightforward. Let's go ahead and run our RepeatModeler process (the "nano" initialization of the Slurm script will be excluded from this point forward. <b>DO NOT SUBMIT THESE VIA THE BASH TERMINAL</b>. You must still initialize your Slurm script, or, alternatively, submit the batch files provided in this repository after addending your own email).

<pre style="color: silver; background: black;">nano repeatmodeler.sh
    GNU nano 2.3.1                                                     File: repeatmaskrun.sh                                             
#!/bin/bash
#SBATCH --job-name=repeatmodelerhimem
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --partition=himem3
#SBATCH --mail-type=END
#SBATCH --mail-user=your.email@uconn.edu
#SBATCH --mem=256G
#SBATCH -o repeatmaskrun_%j.out
#SBATCH -e repeatmaskrun_%j.err
module load RepeatModeler
RepeatModeler -engine ncbi -pa 32 -database athaliana_db</pre>
</pre>

This process may run for over a day, so be patient and do not submit the job more than once! After completion of the run, there should be a directory called RM&#42;. Let's have a look at its contents:

<pre style="color: silver; background: black;">cd RM&#42;
ls
consensi.fa             consensi.fa.masked  round-2  round-4
consensi.fa.classified  round-1             round-3  round-5
</pre>

Per the RepeatModeler <a href="http://www.repeatmasker.org/RepeatModeler/">webpage</a>, we see each file as:
<pre style="color: silver; background: black;">          round-1/
               sampleDB-&#35;.fa       : The genomic sample used in this round
               sampleDB-&#35;.fa.lfreq : The RepeatScout lmer table
               sampleDB-&#35;.fa.rscons: The RepeatScout generated consensi
               sampleDB-&#35;.fa.rscons.filtered : The simple repeat/low
                                               complexity filtered
                                               version of &#42;.rscons
               consensi.fa         : The final consensi db for this round
               family-&#35;-cons.html  : A visualization of the model
                                     refinement process.  This can be opened
                                     in web browsers that support zooming.
                                     ( such as firefox ).
                                     This is used to track down problems
                                     with the Refiner.pl
               index.html          : A HTML index to all the family-&#35;-cons.html
                                     files.
          round-2/
               sampleDB-&#35;.fa       : The genomic sample used in this round
               msps.out            : The output of the sample all-vs-all
                                     comparison
               summary/            : The RECON output directory
                    eles           : The RECON family output
               consensi.fa         : Same as above
               family-&#35;-cons.html  : Same as above
               index.html          : Same as above
          round-3/
               Same as round-2
           ..
          round-n/</pre>
We see that we have information about the genomic sample used in each round, a consensus seqeuence frequency matrix for the genomic sample, the generated predicted consensus sequences, and visualizations. This format is repeated for various rounds with summaries of all rounds compiled in the summary directories. Our complete, predicted consensus sequences may be found in the various "consensi" fastas. Now that we have generated our consensus sequences, we are ready to mask our genome using the RepeatMasker.

<h2 id="Fourth_Point_Header">Masking Regions of Genomic Repetition with RepeatMasker</h2>
Now that we have identified our consensus sequences, we are ready to mask them using the RepeatMasker. RepeatMasker requires two arguments, a library of repetitive regions for your organism and the genome fasta for your organism. RepeatMasker will align the repetitive regions to your genome followed by masking those repetitive regions within your genome appropriately. Let's have a look at the RepeatMasker options:

<pre style="color: silver; background: black;">module load RepeatMasker
RepeatMasker
::small preview of options::
   -lib
   	Rather than use a database, use your own RepeatModeler consensus fasta to ammend your genome
   -small
       Returns complete .masked sequence in lower case

   -xsmall
       Returns repetitive regions in lowercase (rest capitals) rather than
       masked

   -x  Returns repetitive regions masked with Xs rather than Ns</pre>
   
We want to softmask only repetitive regions, so we will be using the option "xsmall". Notice that in our athaliana.fa file, the headers contain spaces. For future reference, that is asking for software errors in the future. Let's truncate our headers and remove the whitespaces. We can do that with the sed command:

<pre style="color: silver; background: black;">sed -i 's/Chr1.&#42;/Chr1/g; s/Chr2.&#42;/Chr2/g; s/Chr3.&#42;/Chr3/g; s/Chr4.&#42;4/Chr4/g; s/Chr5.&#42;/Chr5/g; s/ChrM.&#42;/ChrM/g; s/ChrC.&#42;/ChrC/g;' athaliana.fa</pre>

The -i option commands sed to edit the file in its place, requiring no new file, while 's/Chr1.&#42;/Chr1/g;' commands sed to replace all lines which begin with Chr1 with simply Chr1. We simply stack our replacement set within the quotes, separated by semi-colons. And voila! We are now ready to run RepeatMasker.

Let's initialize our slurm script:
  
<pre style="color: silver; background: black;">nano repeatmaskrun.sh
    GNU nano 2.3.1                                                     File: repeatmaskrun.sh                                             
#!/bin/bash
#SBATCH --job-name=repeatmaskrunhimem
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 10
#SBATCH --partition=himem3
#SBATCH --mail-type=END
#SBATCH --mail-user=your.email@uconn.edu
#SBATCH --mem=80G
#SBATCH -o repeatmaskrun_%j.out
#SBATCH -e repeatmaskrun_%j.err
module load RepeatMasker
RepeatMasker -pa 10 -lib consensi.fa -xsmall /home/CAM/your_username/annotation_tutorial/athaliana.fa

                                                                                             [ Read 13 lines ]
^G Get Help                       ^O WriteOut                       ^R Read File                      ^Y Prev Page                      ^K Cut Text                       ^C Cur Pos
^X Exit                           ^J Justify                        ^W Where Is                       ^V Next Page                      ^U UnCut Text                     ^T To Spell
</pre>

We now run our script:
<pre style="color: silver; background: black;">sbatch repeatmaskrun.sh
cd /home/CAM/your_username/structural_annotation_for_assembled_genomes_xanadu/
ls
athaliana.fa
athaliana.fa.cat.gz
athaliana.fa.masked
athaliana.fa.ori.out
athaliana.fa.out
athaliana.fa.tbl
</pre>

For information about the files see section 4 of this RepeatMasker <a href="http://sebastien.tempel.free.fr/Boulot/UsingRepeatMasker.pdf">manual</a>. We are mainly interested in the masked fasta, let's give it a quick look:

<pre style="color: silver; background: black;">head athaliana.fa.masked
>Chr1
ccctaaaccctaaaccctaaaccctaaacctctgaatccttaatccctaa
atccctaaatctttaaatcctacatccatgaatccctaaatacctaattc
cctaaacccgaaaccGGTTTCTCTGGTTGAAAATCATTGTGTATATAATG
ATAATTTTATCGTTTTTATGTAATTGCTTATTGTTGTGTGTAGATTTTTT
AAAAATATCATTTGAGGTCAATACAAATCCTATTTCTTGTGGTTTTCTTT
CCTTCACTTAGCTATGGATGGTTTATCTTCATTTGTTATATTGGATACAA
GCTTTGCTACGATCTACATTTGGGAATGTGAGTCTCTTATTGTAACCTTA
GGGTTGGTTTATCTCAAGAATCTTATTAATTGTTTGGACTGTTTATGTTT
GGACATTTATTGTCATTCTTACTCCTTTGTGGAAATGTTTGTTCTATCAA</pre>

Look at that! We have successfully soft-masked our genome!

<h2 id="Fifth_Point_Header">Mapping RNA-Seq reads with HISAT2</h2>
We will now be mapping our RNA-Seq reads to the masked genome using <a href="https://github.com/infphilo/hisat2/blob/master/MANUAL">HISAT2</a>. Before aligning our reads, we need to build an index of our masked genome. First, let's have a look at our options:
<pre style="color: silver; background: black;">module load hisat2
hisat2-build
-bash-4.2$ hisat2-build
No input sequence or sequence file specified!
HISAT2 version 2.1.0 by Daehwan Kim (infphilo@gmail.com, http://www.ccb.jhu.edu/people/infphilo)
Usage: hisat2-build [options]* <reference_in> <ht2_index_base>
    reference_in            comma-separated list of files with ref sequences
    hisat2_index_base       write ht2 data to files with this dir/basename</pre>
We initialize and run the following script:
<pre style="color: silver; background: black;">nano indexbuild.sh
  GNU nano 2.3.1                                                      File: indexbuild.sh                                                                                                                   

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

                                                                                             [ Read 13 lines ]
^G Get Help                       ^O WriteOut                       ^R Read File                      ^Y Prev Page                      ^K Cut Text                       ^C Cur Pos
^X Exit                           ^J Justify                        ^W Where Is                       ^V Next Page                      ^U UnCut Text                     ^T To Spell</pre>
<pre style="color: silver; background: black;">sbatch indexbuild.sh
ls
arabidopsis_masked.1.ht2
arabidopsis_masked.2.ht2
arabidopsis_masked.3.ht2
arabidopsis_masked.4.ht2
arabidopsis_masked.5.ht2
arabidopsis_masked.6.ht2
arabidopsis_masked.7.ht2</pre>

We have a few goals to achieve in our script. We want to align our reads to our masked index, convert the SAM output to its binary, and lastly sort the BAM files and merge them into a single BAM file. The script is going to be presented here, but its theory will not due to its posting <a href="https://github.com/wolf-adam-eily/refseq_diffexp_funct_annotation_uconn#Fourth_Point_Header">here</a>(where you can learn why we must build an index, as well). RNA-Seq alignment is perhaps the most common operation a bioinformatician will perform in her work. Therefore, it is advised to truly familiarize yourself with the pipeline, as you will most likely be performing it several times per week:

<pre style="color: silver; background: black;">nano hisat2run.sh
  GNU nano 2.3.1                                                      File: hisat2run.sh                                                                                                                    

#!/bin/bash
#SBATCH --job-name=hisat2run
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --partition=general
#SBATCH --mail-type=END
#SBATCH --mail-user=
#SBATCH --mem=100G
#SBATCH -o hisat2run_%j.out
#SBATCH -e hisat2run_%j.err
module load hisat2
module load samtools
hisat2 -x arabidopsis_masked -1 trimmed_SRR6852085_1.fastq -2 trimmed_SRR6852085_2.fastq -p 16 -S SRR6852085.sam
samtools view -@ 16 -uhS SRR6852085.sam | samtools sort -@ 16 -o sorted_SRR6852085.bam
hisat2 -x arabidopsis_masked -1 trimmed_SRR6852086_1.fastq -2 trimmed_SRR6852085_2.fastq -p 16 -S SRR6852086.sam
samtools view -@ 16 -uhS SRR6852086.sam | samtools sort -@ 16 -o sorted_SRR6852086.bam
samtools merge finalbamfile.bam sorted_SRR6852085.bam sorted_SRR6852086.bam
                                                                                             [ Read 17 lines ]
^G Get Help                       ^O WriteOut                       ^R Read File                      ^Y Prev Page                      ^K Cut Text                       ^C Cur Pos
^X Exit                           ^J Justify                        ^W Where Is                       ^V Next Page                      ^U UnCut Text                     ^T To Spell</pre>
<pre style="color: silver; background: black;">sbatch hisat2run.sh
ls</pre>

We can view some simple statistics of our mappings using samtool's "flagstat" option. Let's see how our masking has affected our alignment profile:
<pre style="color: silver; background: black;">module load flagstat
samtools flagstat sorted_SRR6852085.bam
34756336 + 0 in total (QC-passed reads + QC-failed reads)
1004238 + 0 secondary
0 + 0 supplementary
0 + 0 duplicates
32246430 + 0 mapped (92.78% : N/A)
33752098 + 0 paired in sequencing
16876049 + 0 read1
16876049 + 0 read2
29870128 + 0 properly paired (88.50% : N/A)
30528672 + 0 with itself and mate mapped
713520 + 0 singletons (2.11% : N/A)
269532 + 0 with mate mapped to a different chr
258958 + 0 with mate mapped to a different chr (mapQ>=5)

samtools flagstat sorted_SRR6852086.bam
34588524 + 0 in total (QC-passed reads + QC-failed reads)
836428 + 0 secondary
0 + 0 supplementary
0 + 0 duplicates
31990899 + 0 mapped (92.49% : N/A)
33752096 + 0 paired in sequencing
16876048 + 0 read1
16876048 + 0 read2
114832 + 0 properly paired (0.34% : N/A)
28789736 + 0 with itself and mate mapped
2364735 + 0 singletons (7.01% : N/A)
22546350 + 0 with mate mapped to a different chr
22047363 + 0 with mate mapped to a different chr (mapQ>=5)</pre>

We see that we aligned a large proportion of our reads to our masked genomes. Because we know that the reads correspond to mRNA sequences extracted from the <i>A. thaliana</i> leaves, we can safely assume that each mapped region of our masked genome is either a part of or contains an active, functional gene. However, there is no guarantee that we have even accounted for <i>most</i> of the functional genes in our biosample. We may use what alignments we do have to train our machines to detect un-identified but plausible gene models in our genomes. This, combined with our alignments, provides a much more thorough annotation than the alignments alone. The reason for this is quite simple, consider if a set of genes by happenstance were untranscribed during sampling -- they would not become annotated if we used our alignments only even if these genes <i>are</i> active in our samples! 

<h2 id="Sixth_Point_Header">BRAKER2: Identifying and Predicting Genes with RNA-Seq Data</h2>
We will be using <a href="https://academic.oup.com/bioinformatics/article/32/5/767/1744611">BRAKER2</a> for our identification and prediction of gene models using our RNA-Seq data. BRAKER2 utilizes <a href="http://opal.biology.gatech.edu/GeneMark/">GeneMark</a> as the unsupervised machine learning process which produces gene models without the need for any sample data. Following this step, <a href="http://bioinf.uni-greifswald.de/augustus/">AUGUSTUS</a>, a supervised machine learning process, is trained with the gene models provided by GeneMark, as well as the aligned RNA-Seq data. The symbiosis of these two processes enables for improved accuracy and sensititivy by providing a system against which it may check its own work. BRAKER requires writer privileges to the config directory. However, we cannot write in that path! To circumvent this we simply copy the AUGUSTUS executable path to our parent directory:
<pre style="color: silver; background: black;">cp -rf /isg/shared/apps/augustus/3.2.3/ /home/CAM/$USER/</pre>


We are now ready to run our process and may see our options for BRAKER with the following code:

<pre style="color: silver; background: black;">module load BRAKER
braker.pl
braker.pl     Pipeline for predicting genes with GeneMark-ET and AUGUSTUS with
            RNA-Seq

SYNOPSIS

braker.pl [OPTIONS] --genome=genome.fa --bam=rnaseq.bam

INPUT FILE OPTIONS

--genome=genome.fa                  fasta file with DNA sequences
--bam=rnaseq.bam                    bam file with spliced alignments from 
                                    RNA-Seq
--softmasking                       Softmasking option for soft masked genome 
                                    files. Set to 'on' or '1'</pre>
BRAKER is a very computationally expensive tool. Because of this, we will want to max-out the capacity on a himem node of Xanadu. Let's initialize our Slurm script:
<pre style="color: silver; background: black;">nano run_braker_run_SRR6852085.sh
  GNU nano 2.3.1                                                 File: run_braker_run_SRR6852085.sh                                                                                               Modified  

#!/bin/bash
#SBATCH --job-name=run_braker_run_SRR6852085
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --partition=himem5
#SBATCH --mail-type=END
#SBATCH --mail-user=
#SBATCH --mem=125G
#SBATCH -o run_braker_run_SRR6852085_%j.out
#SBATCH -e run_braker_run_SRR6852085_%j.err
module load BRAKER

mkdir /home/CAM/$USER/tmp/
export TMPDIR=/home/CAM/$USER/tmp/
export AUGUSTUS_CONFIG_PATH=/home/CAM/$USER/3.2.3/config/
export AUGUSTUS_BIN_PATH=/home/CAM/$USER/3.2.3/bin/
export AUGUSTUS_SCRIPTS_PATH=/home/CAM/$USER/3.2.3/scripts

braker.pl --genome=athaliana.fa.masked --bam finalbamfile.bam --softmasking

^G Get Help                       ^O WriteOut                       ^R Read File                      ^Y Prev Page                      ^K Cut Text                       ^C Cur Pos
^X Exit                           ^J Justify                        ^W Where Is                       ^V Next Page                      ^U UnCut Text                     ^T To Spell</pre>

We initialize a temp directory to provide a writable path in which BRAKER can operate, and export our AUGUSTUS options as environment variables, letting BRAKER know that there is a writable AUGUSTUS path, as well. After the process has completed, you will have a 'braker' directory. Let's check it out:
<pre style="color: silver; background: black;">cd braker
ls
Sp_9
cd Sp_9
ls
augustus.hints.aa         augustus.hints.gtf  filterGenemark.stdout  genbank.good.gb.test   genemark.gb             genome.split.2.fa  genome.split.6.fa         secondetraining.stdout
augustus.hints.cdsexons   bam_header.map      firstetraining.stdout  genbank.good.gb.train  genemark_hintsfile.gff  genome.split.3.fa  header.map                secondtest.stdout
augustus.hints.codingseq  braker.log          firsttest.stdout       GeneMark-ET            genome.fa               genome.split.4.fa  hintsfile.gff             species
augustus.hints.gff        errors              genbank.good.gb        GeneMark-ET.stdout     genome.split.1.fa       genome.split.5.fa  optimize_augustus.stdout</pre>

We will not be going into each file here. However, it should be at least somewhat self-explanatory -- we have our predicted amino acid sequences, predicted introns, exons, coding sequences, and complete gff and gtf files. We are now going to use our 
