local_path=$(cd `dirname $0` && pwd)
# Download miniconda
# wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

# Step 1. Download bwa=0.7.17 samtools=1.18 bcftools=1.18 varscan=2.3 gsutil
# Build the conda env rnaseq from wes_env.yml
conda env create -f $local_path/wes_env.yml
conda activate wes

#### Or:
#### Download the tools step by step ######
# Conda add channels
# conda config --add channels defaults
# conda config --add channels bioconda
# conda config --add channels conda-forge

# conda create -n wes bwa=0.7.17 samtools=1.18 bcftools=1.18 varscan=2.3
# conda activate wes
# conda install gsutil



# Step 2. Download picard.jar and VarScan.jar
mkdir -p ~/software
cd ~/software
wget https://github.com/broadinstitute/picard/releases/download/2.25.5/picard.jar
wget --no-check-certificate https://nchc.dl.sourceforge.net/project/varscan/VarScan.v2.3.9.jar
mv VarScan.v2.3.9.jar VarScan.jar
