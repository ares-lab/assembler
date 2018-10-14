#=====================================================#
# ARES Assembler: Bacterial Genome Assembly Pipeline  #
# https://github.com/ares-lab/assembler               #
#=====================================================#

from snakemake.utils import update_config, min_version
import assembler
import yaml

# Setup
# ------------------------------------------------

min_version("5.2")
processor_config = yaml.safe_load(open(config['processor_config']))
if 'samplesheet_fp' in config:
    samples = assembler.parse_samplesheet(config['samplesheet_fp'])
else:
    samples = assembler.parse_samplesheet(processor_config['samplesheet_fp'])
    
subworkflow processor:
    snakefile: config['processor_snakefile']
    configfile: config['processor_config']

rule all:
    input:
        expand(
            config['output_dir'] + '/canu/barcode{bc}/canu.contigs.fasta',
            bc=assembler.padded_barcodes(samples))

        
# Denovo Assembly
# ------------------------------------------------

rule assemble_canu:
    input:
        processor_config['output_dir'] + '/trimmed/barcode{bc}.fastq.gz'
    output:
        config['output_dir'] + '/canu/barcode{bc}/canu.contigs.fasta',
        config['output_dir'] + '/canu/barcode{bc}/canu.correctedReads.fasta.gz'
    params:
        out_dir = config['output_dir'] + '/canu/barcode{bc}'
    resources:
        mem_mb = config['canu_max_memory']
    threads: 8
    conda:
        "envs/canu.yaml"
    shell:
        """
        canu \
        -p canu \
        -d {params.out_dir} \
        genomeSize={config[genome_size]} \
        correctedErrorRate=0.16 \
        useGrid=false maxMemory={resources.mem_mb}M maxThreads={threads} \
        -nanopore-raw {input} 
        """

rule assemble_unicycler:
    input:
        processor_config['output_dir'] + '/trimmed/barcode{bc}.fastq.gz'
    output:
        config['output_dir'] + '/unicycler/barcode{bc}/assembly.fasta'
    threads: 8
    params:
        out_dir = config['output_dir'] + '/unicycler/barcode{bc}'
    conda:
        "envs/unicycler.yaml"
    shell:
        "unicycler -l {input} -o {params.out_dir} -t {threads}"

        
# Reference-based Assembly
# ------------------------------------------------

