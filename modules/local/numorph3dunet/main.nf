process NUMORPH3DUNET {
    tag "$meta.id"
    label 'process_gpu'


    container "carolinschwitalla/numorph-3dunet:latest"


    input:
    tuple val(meta), path(img_directory), path(parameter_file)
    path(model_file)

    output:
    path "results/*"              , emit: cellcounts
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    source /opt/conda/etc/profile.d/conda.sh
    conda activate 3dunet

    mkdir -p ./results
    mkdir -p ./images

    # move images to images directory
    mv ${img_directory} ./images/

    numorph_3dunet.predict \\
        -i images/ \\
        -o results \\
        --model_file ${model_file} \\
        --sample_id ${prefix} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorph3dunet: 1.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p \$PWD/results
    touch results/${prefix}.csv
    touch results/${prefix}_counts.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorph3dunet: 1.0
    END_VERSIONS
    """
}
