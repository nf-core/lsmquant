process NUMORPHREGISTER {
    tag "$meta.id"
    label 'process_high_long'

    container "numorph_analyze:latest"

    input:
    tuple val(meta), path(resampled_directory), path(parameter_file)

    output:
    path "results/*results.mat"                 , emit: res_mat
    path "results/variables/*"                  , emit: variables
    path "results/NM_variables.mat"             , emit: NM_variables
    path "results/registered/*"                 , emit: registered
    path "versions.yml"                         , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p results/variables/
    mkdir -p results/resampled/
    mkdir -p results/registered/


    ln -sr ${resampled_directory} results/resampled

    #resolve symlinks and paths
    resampled_directory=\$(readlink -f ./results/resampled/)
    parameter_file=\$(readlink -f ${parameter_file})
    results_dir=\$(readlink -f ./results)

    numorph_analyze 'input_dir' \$resampled_directory 'output_dir' \$results_dir 'parameter_file' \$parameter_file 'sample_name' ${prefix} 'stage' 'register' 'NM_variables' '' 'use_processed_images' 'resampled'


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphregister: 1.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p results/registered
    mkdir -p results/variables

    touch results/variables/reg_params.mat
    touch results/variables/${prefix}_mask.mat
    touch results/NM_variables.mat
    touch results/${prefix}_results.mat
    touch results/registered/${prefix}_registered.tif

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphregister: 1.0
    END_VERSIONS
    """
}
