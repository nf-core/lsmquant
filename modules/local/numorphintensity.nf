
process NUMORPHINTENSITY {
    tag "$meta.id"
    label 'process_single'
 
    container "numorph_preprocessing:latest"

    input:
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf
    
    //path ch_input_dir
    //path ch_parameter_file
    //val ch_sample_name
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
    results="\$PWD/results"
    echo \$PWD/$img_directory
    echo \$results

    /usr/bin/mlrtapp/numorph_preprocessing 'input_dir' \$PWD/$img_directory 'output_dir' \$results 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'intensity'
    

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
        numorph: 1.0
    END_VERSIONS
    """
}
