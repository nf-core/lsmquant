process NUMORPHRESAMPLE {
    tag "$meta.id"
    label 'process_single'

    container "carolinschwitalla/numorph_analyze:latest"



    input:
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf

    tuple val(meta), path(stitch_directory), path(parameter_file)
    path NM_variables


    output:
    tuple val(meta), path("results/resampled/*"), path(parameter_file)                  , emit: resampled
    path "results/NM_variables.mat"                                                     , emit: NM_variables
    path "versions.yml"                                                                 , emit: versions

    //errorStrategy { task.exitStatus == 249 ? 'ignore' : 'terminate' }


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p \$PWD/results/stitched/

    mv $stitch_directory \$PWD/results/stitched

    results="\$PWD/results"

    /usr/bin/mlrtapp/numorph_analyze 'input_dir' \$PWD/results/stitched 'output_dir' \$results 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'resample' 'NM_variables' \$PWD/$NM_variables 'use_processed_images' 'stitched'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphresample: 1.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p results/resampled

    touch results/resampled/${meta.id}_resampled.tif
    touch results/NM_variables.mat

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorphresample: 1.0
    END_VERSIONS
    """
}
