process NUMORPHRESAMPLE {
    tag "$meta.id"
    label 'process_high_long'

    container "carolinschwitalla/numorph_analyze:latest"

    input:
    tuple val(meta), path(stitch_directory), path(parameter_file)
    path NM_variables


    output:
    tuple val(meta), path("results/resampled/*")                , emit: resampled
    path "results/NM_variables.mat"                             , emit: NM_variables
    path "versions.yml"                                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def nm_variables = NM_variables ? "${NM_variables}" : ""

    """
    mkdir -p \$PWD/results/stitched/

    mv $stitch_directory \$PWD/results/stitched

    results="\$PWD/results"

    numorph_analyze 'input_dir' \$PWD/results/stitched 'output_dir' \$results 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'resample' 'NM_variables' \$PWD/$nm_variables 'use_processed_images' 'stitched'

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
