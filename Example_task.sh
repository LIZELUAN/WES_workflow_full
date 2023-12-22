local_path=$(cd `dirname $0` && pwd)
chmod +x $local_path/WES_analysis_pipeline.sh
nohup $local_path/WES_analysis_pipeline.sh -b $local_path/fq -d $local_path/ref/Homo_sapiens_assembly38.fasta -l tumour-chr2 -m normal-chr2 >$local_path/final.log 2>&1 &
