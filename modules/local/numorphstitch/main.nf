process NUMORPHSTITCH {
    tag "$meta.id"
    label 'process_high_long'

    container "carolinschwitalla/numorph_preprocessing:latest"

    input:
    tuple val(meta), path(img_directory), path(parameter_file)
    path alignment_table_mat
    path z_displacement_align_mat
    path path_table_mat
    path thresholds_mat
    path adj_params_mat
    path NM_variables

    output:
    tuple val(meta),  path("results/stitched/*")                            , emit: stitched
    path "results/variables/*"                                              , emit: variables
    path "results/NM_variables.mat"                                         , emit: NM_variables
    path "versions.yml"                                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    mkdir -p \$PWD/results/variables/

    mv $alignment_table_mat \$PWD/results/variables
    mv $z_displacement_align_mat \$PWD/results/variables
    mv $thresholds_mat \$PWD/results/variables
    mv $adj_params_mat \$PWD/results/variables
    mv $path_table_mat \$PWD/results/variables

    results="\$PWD/results"

    /usr/bin/mlrtapp/numorph_preprocessing 'input_dir' \$PWD/$img_directory 'output_dir' \$results 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'stitch' 'NM_variables' \$PWD/$NM_variables

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorph: 1.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p results/stitched
    mkdir -p results/variables

    touch results/variables/z_dips_matrix.mat
    touch results/variables/stitch_tforms.mat
    touch results/variables/path_table.mat
    touch results/variables/adjusted_z.mat
    touch results/NM_variables.mat
    touch results/stitched/${meta.id}_stitched.tif

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphstitch: 1.0
    END_VERSIONS
    """
}
