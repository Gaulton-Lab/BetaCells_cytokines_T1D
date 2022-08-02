BWA=/software/bwa-0.7.12/bwa
CUTADAPT=/home/nnariai/anaconda2/envs/dhs/bin/cutadapt
SAMTOOLS=/frazer01/software/samtools-1.4/samtools
BEDTOOLS=/frazer01/software/bedtools-2.25.0/bin/bedtools
FASTUNIQ=/software/FastUniq-1.1/source/fastuniq

CYCLE=cycle4
#WELL=2_A1
NUM=347

gen_index:
	mkdir -p fasta
	cat /projects/T2D/analysis/selex_fasta/fasta/t2d_20170425_extended.fasta | ./add_prefix_fasta.pl T2D_ > fasta/t2d_ref.fa
	cat /projects/T2D/analysis/selex_fasta/fasta/t1d_20170425_extended.fasta | ./add_prefix_fasta.pl T1D_ > fasta/t1d_ref.fa
	cat fasta/t2d_ref.fa fasta/t1d_ref.fa > fasta/selex_ref.fa
	${BWA} index fasta/selex_ref.fa

initialize: gen_index gen_well_list gen_sh
# for each CYCLE and WELL
#run_pipeline_nonzero: prepare_dir read_mapping get_count get_num_reads get_num_snps
#run_pipeline_nonzero: dedup_count
run_pipeline_nonzero: run_homer

prepare_dir:
	mkdir -p ${CYCLE}
	mkdir -p ${CYCLE}/${WELL}

filter_read:
	mkdir ${CYCLE}/${WELL}/fastq
	ls /projects/T2D/data/Ren/SELEX_170830/rep1/${WELL}_*${CYCLE}*R?.fastq > ${CYCLE}/${WELL}/fastq/input.txt
	${FASTUNIQ} -i ${CYCLE}/${WELL}/fastq/input.txt -o ${CYCLE}/${WELL}/fastq/R1.fastq -p ${CYCLE}/${WELL}/fastq/R2.fastq

dedup_count:
	wc -l ${CYCLE}/${WELL}/fastq/R1.fastq > ${CYCLE}/${WELL}/stats/num_lines_dedup.txt

read_mapping: filter_read
	
	mkdir -p ${CYCLE}/${WELL}/alignment
	${BWA} mem -t 8 fasta/selex_ref.fa ${CYCLE}/${WELL}/fastq/R1.fastq ${CYCLE}/${WELL}/fastq/R2.fastq > ${CYCLE}/${WELL}/alignment/${WELL}.sam

get_count:
	cat ${CYCLE}/${WELL}/alignment/${WELL}.sam | ./get_read_mapping.pl | sort | uniq -c > ${CYCLE}/${WELL}/alignment/${WELL}_count_per_snp.txt
	${SAMTOOLS} view -F 2048 ${CYCLE}/${WELL}/alignment/${WELL}.sam | ./get_read_mapping_PE.pl | sort | uniq -c > ${CYCLE}/${WELL}/alignment/${WELL}_count.txt

get_num_reads:
	mkdir -p ${CYCLE}/${WELL}/stats
	wc -l /projects/T2D/data/Ren/SELEX_170830/rep1/${WELL}_*${CYCLE}*R1.fastq > ${CYCLE}/${WELL}/stats/num_lines.txt
	cat ${CYCLE}/${WELL}/stats/num_lines.txt | ./parse_lines.pl > ${CYCLE}/${WELL}/stats/num_reads.txt
	cat ${CYCLE}/${WELL}/alignment/${WELL}_count.txt | ./parse_num_probe.pl > ${CYCLE}/${WELL}/stats/count_parsed.txt

get_num_snps:
	cat ${CYCLE}/${WELL}/alignment/${WELL}_count.txt | ./get_num_snp_testable.pl > ${CYCLE}/${WELL}/stats/num_snps.txt
	cat ${CYCLE}/${WELL}/alignment/${WELL}_count.txt | ./get_num_snp_mincov.pl > ${CYCLE}/${WELL}/stats/num_snps_mincov.txt
	cat ${CYCLE}/${WELL}/alignment/${WELL}_count.txt | ./get_num_indel_mincov.pl > ${CYCLE}/${WELL}/stats/num_indel_mincov.txt
	wc -l ${CYCLE}/${WELL}/alignment/${WELL}_count_per_snp.txt > ${CYCLE}/${WELL}/stats/num_snps_exist.txt

# for running all wells
gen_well_list:
	./gen_well_list_nonzero.pl > well_list.txt

# gen bash script
gen_sh:
	mkdir -p sh
	./gen_bash_scripts_nonzero.pl well_list.txt cycle1 > sh/run_pipeline_cycle1.sh
	./gen_bash_scripts_nonzero.pl well_list.txt cycle2 > sh/run_pipeline_cycle2.sh
	./gen_bash_scripts_nonzero.pl well_list.txt cycle3 > sh/run_pipeline_cycle3.sh
	./gen_bash_scripts_nonzero.pl well_list.txt cycle4 > sh/run_pipeline_cycle4.sh

run_homer:
	cat ${CYCLE}/${WELL}/stats/num_snps_mincov.txt | ./stats_to_bed.pl > ${CYCLE}/${WELL}/stats/num_snps.bed
#	sort -k1,1 -k2,2n ${CYCLE}/${WELL}/stats/num_snps.bed | ${BEDTOOLS} merge 
	mkdir -p ${CYCLE}/${WELL}/homer
	findMotifsGenome.pl \
	${CYCLE}/${WELL}/stats/num_snps.bed \
	hg19 \
	${CYCLE}/${WELL}/homer/well_motif \
	-size 40 \
	-p 1 \
	-mask -nomotif 
#-preparse

run_meme:
	awk -v OFS="\t" '{print $$1,$$2-20,$$3+20}' ${CYCLE}/${WELL}/stats/num_snps.bed > ${CYCLE}/${WELL}/stats/num_snps_40bp.bed
	bedtools getfasta -fi /publicdata/hg19_20151104/hg19_sorted.fa -bed ${CYCLE}/${WELL}/stats/num_snps_40bp.bed -fo ${CYCLE}/${WELL}/stats/num_snps.fasta
	meme-chip -oc ${CYCLE}/${WELL}/memechip_out -db /projects/T2D/analysis/selex_t2d_t1d/info/combined.motif_database.meme -meme-mod anr -spamo-skip -fimo-skip ${CYCLE}/${WELL}/stats/num_snps.fasta



run_all:
	mkdir -p error_${CYCLE}
	mkdir -p stdouts_${CYCLE}
	qsub -t 1-$(NUM) -pe smp 6 -cwd -e error_${CYCLE} -o stdouts_${CYCLE} -l opt -V -N run_all_${CYCLE} sh/run_pipeline_${CYCLE}.sh

