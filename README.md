# WES_workflow_full
A whole-exome sequencing (WES) pipeline to align the read pairs of tumour and normal samples to GRCh38 and identify somatic mutations in the tumour.  
A full and completed version with __GATK(v4)__.  

## The main tools used
__*bwa*__:   Align reads to the ref to generate a BAM file and add a header to the BAM file.  
__*Samtools*__:   Sort the BAM file. Later index the bam file after marking the duplicates by picard.  
__*Picard*__:   Mark duplicates of the BAM file.  
__*GATK*__:   Conduct base recalibration of the BAM file.  
__*VarScan*__:   Find the somatic mutations from BAM files of tumour sample and normal sample.  

## How to run
__*1. Configure the environment for the pipeline*__  
Please see `env_config_for_wes.sh` and `wes_env.yml`.    
<br>
__*2. Simply Run by changing the Example_task.sh file*__  
Please see the pipeline at `WES_analysis_pipeline.sh`.  
Example command to run the pipeline: `Example_task.sh`.
