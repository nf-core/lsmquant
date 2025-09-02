process NUMORPHREGISTER {
    tag "$meta.id"
    label 'process_high_long'

    container "carolinschwitalla/numorph_analyze:latest"

    input:
    tuple val(meta), path(resampled_directory), path(parameter_file)
    path NM_variables


    output:
    path "results/variables/reg_params.mat"      , emit: reg_params_mat
    path "results/variables/*_mask.mat"          , emit: reg_mask
    path "results/NM_variables.mat"              , emit: NM_variables
    path "results/registered/*"                 , emit: registered
    path "versions.yml"                         , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def nm_variables = NM_variables ? "${NM_variables}" : ""

    """
    mkdir -p \$PWD/results/variables/
    mkdir -p \$PWD/results/resampled/
    mkdir -p \$PWD/results/registered/

    mv $resampled_directory \$PWD/results/resampled

    results="\$PWD/results"

    numorph_analyze 'input_dir' \$PWD/$resampled_directory 'output_dir' \$PWD/results/ 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'register' 'NM_variables' \$PWD/$nm_variables 'use_processed_images' 'resampled'


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
    touch results/variables/${meta.id}_mask.mat
    touch results/NM_variables.mat
    touch results/registered/${meta.id}_registered.tif

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphregister: 1.0
    END_VERSIONS
    """
}
