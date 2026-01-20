process NUMORPHSTITCH {
    tag "$meta.id"
    label 'process_high_long'

    container "nf-core/numorph_preprocessing:1.0.0"

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
    def alignment_table = alignment_table_mat.name ? alignment_table_mat : ''
    def z_displacement_align = z_displacement_align_mat ? z_displacement_align_mat : ''
    """

    mkdir -p results/variables/

    if [ -n "${alignment_table}" ]; then
        ln -sr ${alignment_table} results/variables/
    fi

    if [ -n "${z_displacement_align}" ]; then
        ln -sr ${z_displacement_align} results/variables
    fi

    ln -sr ${thresholds_mat} results/variables
    ln -sr ${adj_params_mat} results/variables
    ln -sr ${path_table_mat} results/variables

    # resolve symlinks and paths
    img_dir=\$(readlink -f ${img_directory})
    parameter_file=\$(readlink -f ${parameter_file})
    results_dir=\$(readlink -f ./results)
    NM_variables=\$(readlink -f ${NM_variables})

    numorph_preprocessing 'input_dir' \$img_dir 'output_dir' \$results_dir 'parameter_file' \$parameter_file 'sample_name' ${meta.id} 'stage' 'stitch' 'NM_variables' \$NM_variables


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphstitch: 1.0
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
