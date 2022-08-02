#!/usr/bin/env python3

import argparse
import subprocess
import os
import sys
import reprlib
import logging

def detect_file_format(args):
	if args.read1.endswith('.gz') and args.read2.endswith('.gz'):
		return args.read1, args.read2
	if args.read1.endswith('.bz2') and args.read2.endswith('.bz2'):
		logging.info('BZ2 file format detected -- converting to GZ file format.')
		p1_bn, p2_bn = args.read1.split('.bz2')[0], args.read2.split('.bz2')[0]
		subprocess.call(['bunzip2', args.read1, args.read2])
		subprocess.call(['gzip', p1_bn, p2_bn])
		args.read1, args.read2 = p1_bn + '.gz', p2_bn + '.gz'
		return args.read1, args.read2
	if args.read1.endswith('.fastq') and args.read2.endswith('.fastq'):
		logging.info('Unzipped FASTQ format detected -- converting to GZ file format.')
		subprocess.call(['gzip', args.read1, args.read2])
		args.read1, args.read2 = args.read1 + '.gz', args.read2 + '.gz'
		return args.read1, args.read2
	if args.read1.endswith('.fq') and args.read2.endswith('.fq'):
		logging.info('Unzipped FQ format detected -- converting to GZ file format.')
		p1_bn, p2_bn = args.read1.split('.fq')[0] + '.fastq', args.read2.split('.fq')[0] + '.fastq'
		os.rename(args.read1, p1_bn)
		os.rename(args.read2, p2_bn)
		subprocess.call(['gzip', p1_bn, p2_bn])
		args.read1, args.read2 = p1_bn + '.gz', p2_bn + '.gz'
		return args.read1, args.read2
	else:
		logging.error('Unknown file format or paired end reads have different file formats.')
		raise RuntimeError('Paired end reads must be in a valid file format!')
	return


def trim_galore(args):
	## trim reads for adapter sequences with trim galore
	trim_galore_cmd = ['trim_galore', '--fastqc', '-q', '10', '-o', args.output, '--paired', args.read1, args.read2]
	with open(os.devnull, 'w') as f:
		subprocess.call(trim_galore_cmd, stderr=f, stdout=f)
	trim_output_1 = os.path.join(args.output, os.path.basename(args.read1).split('.fastq.gz')[0] + '_val_1.fq.gz')
	trim_output_2 = os.path.join(args.output, os.path.basename(args.read2).split('.fastq.gz')[0] + '_val_2.fq.gz')
	return trim_output_1, trim_output_2


def process_reads(args):
	output_prefix = os.path.join(args.output, args.name)
	align_log = output_prefix + '.align.log'
	sort_bam = output_prefix + '.sort.bam'
	md_bam = output_prefix + '.sort.md.bam'
	rmdup_bam = output_prefix + '.sort.filt.rmdup.bam'

	## align reads with bwa mem and pipe to samtools sort
	bwa_mem_cmd = ['bwa', 'mem', '-M', '-t', str(args.threads), args.reference, args.read1, args.read2]
	samtools_fixmate_cmd = ['samtools', 'fixmate', '-r', '-', '-']
	## sort reads with samtools
	samtools_sort_cmd = ['samtools', 'sort', '-m', '{}G'.format(args.memory), '-@', str(args.threads), '-']

	with open(align_log, 'w') as log, open(sort_bam, 'w') as bam_out:
		bwa_mem = subprocess.Popen(bwa_mem_cmd, stdout=subprocess.PIPE, stderr=log)
		fixmate = subprocess.Popen(samtools_fixmate_cmd, stdin=bwa_mem.stdout, stdout=subprocess.PIPE)
		subprocess.call(samtools_sort_cmd, stdin=fixmate.stdout, stdout=bam_out, stderr=log)

	metrics_file = output_prefix + '.picard_rmdup_metrics.txt'

	## use picard to mark duplicate reads
	md_cmd = ['java', '-Xmx{}G'.format(args.memory*args.threads), '-jar', args.picard_md, 'INPUT={}'.format(sort_bam), 'OUTPUT={}'.format(md_bam), 'REMOVE_DUPLICATES=false', 'ASSUME_SORTED=true', 'VALIDATION_STRINGENCY=LENIENT', 'METRICS_FILE={}'.format(metrics_file)]
	## use samtools to remove unmapped, unpaired, and duplicate reads and filter for autosomal + chrX reads
	rmdup_cmd = ['samtools', 'view', '-b', '-h', '-f', '3','-F', '4', '-F', '256','-F', '1024', '-F', '2048', '-q', str(args.quality), md_bam]

	autosomal_chr = ['chr' + str(c) for c in range(1,23)] + ['chrX']
	rmdup_cmd.extend(autosomal_chr)

	if os.path.exists(sort_bam) and os.path.getsize(sort_bam) != 0:
		with open(os.devnull, 'w') as f:
			subprocess.call(md_cmd, stderr=f)
	if os.path.exists(md_bam) and os.path.getsize(md_bam) != 0:
		subprocess.call(['samtools', 'index', md_bam])
		with open(rmdup_bam, 'w') as f:
			subprocess.call(rmdup_cmd, stdout=f)
		subprocess.call(['samtools', 'index', rmdup_bam])

	return md_bam, rmdup_bam


def call_peaks(args, input_bam):
	output_prefix = os.path.join(args.output, args.name)
	macs2_log = os.path.join(args.output, '.'.join([args.name, 'macs2_callpeaks.log']))
	## use MACS2 to call peaks from de-duplicated reads
	macs2_cmd = ['macs2', 'callpeak', '-t', input_bam, '--outdir', args.output, '-n', args.name, '-g', args.macs2_genome, '--nomodel', '-B', '--shift', '-100', '--extsize', '200', '--keep-dup', 'all']
	## sort the bedgraph file prior to conversion to bigWig
	sort_cmd = ['sort', '-k1,1', '-k2,2n', '-S', '16G', output_prefix + '_treat_pileup.bdg', '-o', output_prefix + '_treat_pileup.bdg']
	## make a bigWig signal track that can be viewed on a genome browser
	bigwig_cmd = ['bedGraphToBigWig', output_prefix + '_treat_pileup.bdg', args.genome_size, output_prefix + '.ATAC.bw']
	with open(macs2_log, 'w') as f:
		subprocess.call(macs2_cmd, stderr=f)
		subprocess.call(sort_cmd)
		subprocess.call(bigwig_cmd, stderr=f)
	return


def main(args):
	logging.info('Starting up.')
	if not os.path.isdir(args.output):
		try:
			os.makedirs(args.output)
		except OSError:
			pass

	args.read1, args.read2 = detect_file_format(args)

	if not args.skip_trim:
		try:
			logging.info('Trimming reads with trim_galore.')
			args.read1, args.read2 = trim_galore(args)
		except Exception as e:
			logging.error('Failed during adaptor trimming step with trim_galore.')
			print('Check options -r1 and -r2: ' + repr(e), file=sys.stderr)
			sys.exit(1)
	if not args.skip_align:
		try:
			logging.info('Aligning reads with bwa and filtering reads with samtools.')
			md_bam, rmdup_bam = process_reads(args)
		except Exception as e:
			logging.error('Failed during alignment step with bwa mem.')
			print(repr(e), file=sys.stderr)
			sys.exit(1)
	if not args.skip_peaks:
		try:
			logging.info('Calling peaks with MACS2.')
			output_prefix = os.path.join(args.output, args.name)
			rmdup_bam = output_prefix + '.sort.filt.rmdup.bam'
			call_peaks(args, rmdup_bam)
		except Exception as e:
			logging.error('Failed during MACS2 peak calling step.')
			print(repr(e), file=sys.stderr)
			sys.exit(1)
	logging.info('Finishing up.')
	return


def process_args():
	parser = argparse.ArgumentParser(description='Pipeline for ATAC-seq to trim reads, align them to a reference genome, call peaks, and generate a genome browser signal track.')

	io_group = parser.add_argument_group('I/O arguments')
	io_group.add_argument('-r1', '--read1', required=True, type=str, help='Path to paired-end reads 1 file')
	io_group.add_argument('-r2', '--read2', required=True, type=str, help='Path to paired-end reads 2 file')
	io_group.add_argument('-o', '--output', required=True, type=str, help='Output directory for processed files')
	io_group.add_argument('-n', '--name', required=False, type=str, default='sample', help='Output sample name to prepend')

	align_group = parser.add_argument_group('Alignment arguments')
	align_group.add_argument('-t', '--threads', required=False, type=int, default=4, help='Number of threads to use [4]')
	align_group.add_argument('-m', '--memory', required=False, type=int, default=4, help='Maximum memory (in Gb) per thread for samtools sort [4]')
	align_group.add_argument('-q', '--quality', required=False, type=int, default=30, help='Mapping quality cutoff for samtools [30]')
	align_group.add_argument('--reference', required=False, type=str, default='/home/ysun/reference/ucsc.hg19.fasta', help='Path to BWA-prepared reference genome [/home/ysun/reference/ucsc.hg19.fasta]')
	align_group.add_argument('--picard_md', required=False, type=str, default='/home/joshchiou/bin/MarkDuplicates.jar', help='Path to picard MarkDuplicates.jar [/home/joshchiou/bin/MarkDuplicates.jar]')

	macs2_group = parser.add_argument_group('MACS2 arguments')
	macs2_group.add_argument('--macs2_genome', required=False, type=str, default='hs', help='MACS2 genome (e.g. hs or mm) for peak calling')
	macs2_group.add_argument('--genome_size', required=False, type=str, default='/home/joshchiou/references/hg19.chrom.sizes', help='Genome size file for hg19 from UCSC [/home/joshchiou/references/hg19.chrom.sizes]')

	skip_group = parser.add_argument_group('Skip processing steps')
	skip_group.add_argument('--skip_trim', required=False, action='store_true', default=False, help='Skip adapter trimming step [OFF]')
	skip_group.add_argument('--skip_align', required=False, action='store_true', default=False, help='Skip read alignment step [OFF]')
	skip_group.add_argument('--skip_peaks', required=False, action='store_true', default=False, help='Skip calling peaks step [OFF]')

	return parser.parse_args()


if __name__ == '__main__':
	logging.basicConfig(format='[%(filename)s] %(asctime)s %(levelname)s: %(message)s', datefmt='%I:%M:%S', level=logging.DEBUG)
	args = process_args()
	main(args)
