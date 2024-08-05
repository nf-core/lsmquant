#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//define parameters 
params.input_dir = 'input'
params.output_dir = 'output'
params.parameter_file = 'parameters.txt'
params.sample_name = 'sample'
params.stage = 'intensity'

// define channels
input_dir = Channel.fromPath(params.input_dir, type: 'dir', checkIfExists: true)
output_dir = Channel.fromPath(params.output_dir, type: 'dir')
parameter_file = Channel.fromPath(params.parameter_file, )
sample_name = Channel.value(params.sample_name)
stage = Channel.value(params.stage)

process INTENSITY {

    container 'numorph_preprocessing_module:latest'

    input:
    path(input_dir)
    path(output_dir)
    path(parameter_file)
    val(sample_name)
    val(stage)

    output:
    path 'results_*'

    script:
    """
    pwd > pwd.txt
    ls  > ls.txt
    /usr/bin/mlrtapp/numorph_preprocessing_module 'input_dir' \$PWD/${input_dir} 'output_dir' ${output_dir} 'parameter_file' ${parameter_file} 'sample_name' ${sample_name} 'stage' ${stage}
    """
}

workflow {
    input_dir.view()
    output_dir.view()
    parameter_file.view()
    sample_name.view()
    stage.view()
    INTENSITY(input_dir, output_dir, parameter_file, sample_name, stage)
}