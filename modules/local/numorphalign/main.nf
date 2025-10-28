process NUMORPHALIGN {
    tag "$meta.id"
    label 'process_high_long'


    container "nf-core/numorph_preprocessing:1.0.0"

    input:
    tuple val(meta), path(img_directory),  path(parameter_file)
    path adj_params_mat
    path path_table_mat
    path thresholds_mat
    path NM_variables


    output:
    path "results/samples/alignment/*"                    , emit: samples
    path "results/variables/path_table.mat"               , emit: path_table_mat
    path "results/variables/alignment_table.mat"          , emit: alignment_table_mat
    path "results/variables/z_displacement_align.mat"     , emit: z_displacement_align_mat
    path "results/NM_variables.mat"                       , emit: NM_variables
    path "versions.yml"                                   , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p results/samples/
    mkdir -p results/variables/
    mkdir -p ./images

    ln -sr ${img_directory} ./images
    ln -sr ${adj_params_mat} results/variables
    ln -sr ${path_table_mat} results/variables
    ln -sr ${thresholds_mat} results/variables

    # resolve symlinks and paths
    img_dir=\$(readlink -f ./images)
    parameter_file=\$(readlink -f ${parameter_file})
    results_dir=\$(readlink -f ./results)
    NM_variables=\$(readlink -f ${NM_variables})

    numorph_preprocessing 'input_dir' \$img_dir 'output_dir' \$results_dir 'parameter_file' \$parameter_file 'sample_name' ${meta.id} 'stage' 'align' 'NM_variables' \$NM_variables

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphalign: 1.0
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p results/samples/alignment
    mkdir -p results/variables

    touch results/variables/path_table.mat
    touch results/variables/alignment_table.mat
    touch results/variables/z_displacement_align.mat
    touch results/NM_variables.mat
    touch results/samples/alignment/${meta.id}_full.tif

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphalign: 1.0
    END_VERSIONS
    """
}
