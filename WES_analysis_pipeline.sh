#!/bin/bash
# AUTHOR: Zeluan LI
# DATE: 2023.11
manual="
Description: a shell pipeline to conduct the WES analysis.
Usage: ./WES_analysis_pipeline.sh [options] ...        
Options:
	-a, --outDir             directory for output files, bydefault is the directory of the script
*	-b, --fastq_gz_Dir       directory of fq.gz files
	-c, --suffix             suffix of fq.gz files, can be fq.gz or fastq.gz, bydefault=fq.gz
*	-d, --refFa              path to the reference genome fasta
	-e, --bwa                Path to bwa, bydefault="bwa"
	-f, --nThread_b          number of threads for bwa mem, bydefault=6
	-g, --samtools           Path to samtools, bydefault="samtools"
	-h, --nThread_s          number of threads for samtools sort, bydefault=6
	-i, --picard             Path to picard.jar
	-j, --VarScan            Path to VarScan.jar
	-k, --gatk               Path to GATK, bydefault="gatk"
*	-l, --tumour	         Name of the tumour sample
*	-m, --normal	         Name of the normal sample
"

if [[ $# -lt 8 ]]; then
	echo -e "The number of input parameters is insufficient. Please see the manual below.\n ${manual}" >&2
	exit 1
fi

output_path=$(cd `dirname $0` && pwd)
suffix="fq.gz"
bwA="bwa"
n_thread_b=6
samtoolS="samtools"
n_thread_s=6
picard=~/software/picard.jar
varscan=~/software/VarScan.jar
gatK="gatk"
#
# Get options
OPTSTRING1="a:b:c:d:e:f:g:h:i:j:k:l:m:"
OPTSTRING="outDir:,fastq_gz_Dir:,suffix:,refFa:,bwa:,nThread_b:,samtools:,nThread_s:,picard:,VarsCan:,gatk:,tumour:,normal:"
set -- $(getopt -o ${OPTSTRING1} --long ${OPTSTRING} -- "$@")
echo "$@"
while true
do
case "$1" in
	'-a' | '--outDir')
		output_path=$(echo $2 | sed "s/'//g" | sed 's/\/$//g')
		echo "output_path: ${output_path}"
		shift 2;;
	'-b' | '--fastq_gz_Dir')
		fastq_gz_dir=$(echo $2 | sed "s/'//g" | sed 's/\/$//g')
		echo "fastq_gz_dir: ${fastq_gz_dir}"
		shift 2;;
	'-c' | '--suffix')
		suffix=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-d' | '--refFa')
		ref_fa=$(echo $2 | sed "s/'//g" | sed 's/\/$//g')
		echo "ref_fa: ${ref_fa}"
		shift 2;;
	'-e' | '--bwa')
		bwA=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-f' | '--nThread_b')
		n_thread_b=$(echo $2 | sed "s/'//g")
		echo "n_thread_bwa: ${n_thread_b}"
		shift 2;;
	'-g' | '--samtools')
		samtoolS=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-h' | '--nThread_s')
		n_thread_s=$(echo $2 | sed "s/'//g")
		echo "n_thread_samtools: ${n_thread_s}"
		shift 2;;
	'-i' | '--picard')
		picard=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-j' | '--VarScan')
		varscan=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-k' | '--gatk')
		gatK=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-l' | '--tumour')
		tumour=$(echo $2 | sed "s/'//g")
		shift 2;;
	'-m' | '--normal')
		normal=$(echo $2 | sed "s/'//g")
		shift 2;;	
	'--')
		break;;
	*)
		echo -e "Error: Unknown option: $1. Please see the manual below.\n ${manual}" >&2
		exit 1;;
esac
done && \
# 
# Create output directories
mkdir -p ${output_path}/02align && \
mkdir -p ${output_path}/03realign && \
mkdir -p ${output_path}/04mutation && \
# Conduct the analysis
start_time=`date +%s`
# Create sh files for analysis
for id in $tumour $normal;
do
# Align reads to the ref genome with BWA-MEM
{
$bwA mem -m 4G -t $n_thread_b \
-R "@RG\tID:$id\tSM:$id\tLB:WES\tPL:Illumina" \
$ref_fa \
$fastq_gz_dir/${id}_r1.${suffix} \
$fastq_gz_dir/${id}_r2.${suffix} | \
# Sort the BAM file by location of alignment on the ref genome for variant calling
$samtoolS sort -@ $n_thread_s -o $output_path/02align/${id}.bam - && \
# Mark duplicates by picard
java -jar $picard MarkDuplicates \
-I $output_path/02align/${id}.bam \
-O $output_path/02align/${id}_mdup.bam \
-M $output_path/02align/${id}_metrics.txt && \
# Index the sorted BAM file to enable efficient random access
$samtoolS index $output_path/02align/${id}_mdup.bam && \
# base recalibration
$gatK BaseRecalibrator \
-I $output_path/02align/${id}_mdup.bam \
-R $output_path/ref/Homo_sapiens_assembly38.fasta \
--known-sites $output_path/ref/1000G_phase1.snps.high_confidence.hg38.vcf.gz \
--known-sites $output_path/ref/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
--known-sites $output_path/ref/Homo_sapiens_assembly38.dbsnp138.vcf \
-O $output_path/03realign/${id}_recal.table && \
#
$gatK ApplyBQSR \
-I $output_path/02align/${id}_mdup.bam \
-R $output_path/ref/Homo_sapiens_assembly38.fasta \
--bqsr-recal-file $output_path/03realign/${id}_recal.table \
-O $output_path/03realign/${id}_mdup_recal.bam && \
rm $output_path/03realign/${id}_recal.table
} >${id}.log 2>&1 &
done && \
wait && \
echo "Bwa alignment, samtools sort, and mark duplicates of tumour and normal samples finished!"
# Turn the bam file into mpilefile
$samtoolS mpileup -q 1 -f $ref_fa -B $output_path/03realign/${normal}_mdup_recal.bam $output_path/03realign/${tumour}_mdup_recal.bam \
>$output_path/03realign/${normal}_${tumour}.mpileup && \
# Find the somatic mutation by Varscan
java -jar $varscan somatic $output_path/03realign/${normal}_${tumour}.mpileup \
$output_path/04mutation/${normal}_${tumour}_varscan --mpileup 1 --output-vcf && \
java -jar $varscan processSomatic $output_path/04mutation/${normal}_${tumour}_varscan.snp.vcf && \
java -jar $varscan processSomatic $output_path/04mutation/${normal}_${tumour}_varscan.indel.vcf && \
####
wait && \
end_time=`date +%s`
# Check the output
if [ $(find ${output_path}/04mutation/* | wc -l) -gt 0 ]
then
echo "Analysis finished!"
echo "Start time: ${start_time}"
echo "End time: ${end_time}"
else
echo "Analysis failed. There is no results output in ${output_path}/03mutation."
fi
