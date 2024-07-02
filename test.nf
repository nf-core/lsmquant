#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// define parameters 
params.input_dir = 'input'
params.output_dir = 'output'
params.parameter_file = 'parameters.txt'
params.sample_name = 'sample'
params.stage = 'intensity'

// define channels
input = Channel.of(params.input_dir)
output = Channel.of(params.output_dir)
parameters = Channel.of(params.parameter_file)
sample_name = Channel.of(params.sample_name)
stage = Channel.of(params.stage)

process INTENSITY {

    container 'numorph_preprocessing_module:latest'

    input:
    val input
    val output
    val parameters
    val sample_name
    val stage   

    output:
    path 'results_*'

    script:
    """
    numorph_preprocessing_module 'input_dir' ${input} 'output_dir' ${output} 'parameter_file' ${parameters} 'sample_name' ${sample_name} 'stage' ${stage}
    """
}

workflow {
    input.view()
    output.view()
    parameters.view()
    sample_name.view()
    stage.view()
    INTENSITY(input, output, parameters, sample_name, stage)
}