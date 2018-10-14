# Bacterial Genome Assembly Pipeline <img src="ARES_Small.png" width=150 align="right">

This pipeline assembles and annotates bacterial genomes from MinION reads processed with the [ARES Processor](https://github.com/ares-lab/processor) pipeline. Significant code and inspiration from from @zhaoc1's [nanoflow](https://github.com/zhaoc1/nanoflow) pipeline.

## Installation

Requirements:

- snakemake 5.2.0 or greater

1. Create a conda environment: `conda create -n assembler -c bioconda snakemake>=5.2`
2. Enter environment: `source activate assembler`

## Configuration

Configuration is done through a `config.yaml` file. The relevant keys are:
- `processor_fp`: the path to the folder containing the Processor snakefile
- `processor_config_fp`: the path to the configuration file used in the Processor workflow
- `samplesheet_fp`: the path to the sample sheet used in the Processor workflow
