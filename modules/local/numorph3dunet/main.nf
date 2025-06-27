process NUMORPH3DUNET {
    tag "$meta.id"
    label 'process_medium'
    label 'gpu'


    container "carolinschwitalla/numorph-3dunet:latest"

    input:
    tuple val(meta), path(input_dir), path(parameter_file)
    path(model)
    val n_channels


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

    mkdir -p \$PWD/results
    results="\$PWD/results"

    mkdir -p \$PWD/input_dir
    mv $input_dir \$PWD/input_dir
    input_dir="\$PWD/input_dir"

    numorph_3dunet.predict \
        -i \$input_dir \
        -o \$results \
        --model ${model} \
        --n_channels ${n_channels} \
        --sample_id ${prefix} \
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
