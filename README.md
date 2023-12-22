# WES_workflow_full
A whole-exome sequencing (WES) pipeline to align the read pairs of tumour and normal samples to GRCh38 and identify somatic mutations in the tumour.  
It is a full version of WES pipeline with __GATK__ (v4).  

## The main tools used
__*bwa*__:   Align reads to the ref to generate a BAM file and add a header to the BAM file.  
__*Samtools*__:   Sort the BAM file. Later index the bam file after marking the duplicates by Picard.  
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

## Output Created  
The pipeline will generate  
log files: normal-chr2.log, tumour-chr2.log, and final.log.  
result files in three directories: 02align, 03realign, 04mutation  
  
Below is a example output using the fq files here:  
.  
├── normal-chr2.log  
├── tumour-chr2.log  
├── final.log  
├── 02align  
│   ├── normal-chr2.bam  
│   ├── normal-chr2_mdup.bam  
│   ├── normal-chr2_mdup.bam.bai  
│   ├── normal-chr2_metrics.txt  
│   ├── tumour-chr2.bam  
│   ├── tumour-chr2_mdup.bam  
│   ├── tumour-chr2_mdup.bam.bai  
│   └── tumour-chr2_metrics.txt  
├── 03realign  
│   ├── normal-chr2_mdup_recal.bai  
│   ├── normal-chr2_mdup_recal.bam  
│   ├── normal-chr2_tumour-chr2.mpileup  
│   ├── tumour-chr2_mdup_recal.bai  
│   └── tumour-chr2_mdup_recal.bam  
├── 04mutation  
│   ├── normal-chr2_tumour-chr2_varscan.indel.Germline.hc.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.indel.Germline.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.indel.LOH.hc.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.indel.LOH.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.indel.Somatic.hc.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.indel.Somatic.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.indel.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.snp.Germline.hc.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.snp.Germline.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.snp.LOH.hc.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.snp.LOH.vcf  
│   ├── normal-chr2_tumour-chr2_varscan.snp.Somatic.hc.vcf      # This file is our interested result of somatic mutation in the tumour.  
│   ├── normal-chr2_tumour-chr2_varscan.snp.Somatic.vcf  
│   └── normal-chr2_tumour-chr2_varscan.snp.vcf  

