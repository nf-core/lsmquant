process NUMORPHALIGN {
    tag "$meta.id"
    label 'process_single'


    container "carolinschwitalla/numorph_preprocessing:latest"

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
    echo "Task working directory: \$PWD"

    mkdir -p \$PWD/results/samples/
    mkdir -p \$PWD/results/variables/

    mv $adj_params_mat \$PWD/results/variables
    mv $path_table_mat \$PWD/results/variables
    mv $thresholds_mat \$PWD/results/variables

    results="\$PWD/results"
    echo \$results


    /usr/bin/mlrtapp/numorph_preprocessing 'input_dir' \$PWD/$img_directory 'output_dir' \$results 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'align' 'NM_variables' \$PWD/$NM_variables

    echo "my output files"
    ls -lha \$PWD

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorph: 1.0
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphalign: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
