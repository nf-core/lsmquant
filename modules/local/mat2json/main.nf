
process MAT2JSON {
    tag "$meta.id"
    label 'process_single'

    container 'carolinschwitalla/mat2json:latest'

    input:
    tuple val(meta), path(matfile)

    output:
    tuple val(meta), path("*.*"),     emit: converted_file
    path "versions.yml"              ,     emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    /usr/bin/mlrtapp/mat2json $matfile

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mat2json: 1.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mat2json: 1.0
    END_VERSIONS
    """
}
