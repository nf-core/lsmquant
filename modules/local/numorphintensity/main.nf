process NUMORPHINTENSITY {
    tag "$meta.id"
    label 'process_high_long'


    container "carolinschwitalla/numorph_preprocessing:latest"


    input:
    tuple val(meta), path(img_directory), path(parameter_file)

    output:
    path "results/samples/intensity_adjustment/*"            , emit: samples
    path "results/variables/adj_params.mat"                  , emit: adj_params_mat
    path "results/variables/path_table.mat"                  , emit: path_table_mat
    path "results/variables/thresholds.mat"                  , emit: thresholds_mat
    path "results/NM_variables.mat"                          , emit: NM_variables
    path "versions.yml"                                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo "Task working directory: \$PWD"
    mkdir -p ./results

    numorph_preprocessing 'input_dir' $img_directory 'output_dir' ./results 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'intensity'


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphintensity : 1.0
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p results/samples/intensity_adjustment
    mkdir -p results/variables

    touch results/variables/adj_params.mat
    touch results/variables/path_table.mat
    touch results/variables/thresholds.mat
    touch results/NM_variables.mat
    touch results/samples/intensity_adjustment/${meta.id}.png

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphintensity : 1.0
    END_VERSIONS
    """
}
