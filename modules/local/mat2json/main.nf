
process MAT2JSON {
    tag "$meta.id"
    label 'process_single'

    container 'carolinschwitalla/mat2json:latest'

    input:
    tuple val(meta), path(matfiles)
    val process

    output:
    tuple val(meta), path("${process}/*.*"),     emit: converted_file
    path "versions.yml"              ,     emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p ${process}
    for matfile in ${matfiles.join(' ')}; do
        /usr/bin/mlrtapp/mat2json \$matfile
    done

    mv -f *.json ${process}/ 2>/dev/null || true
    mv -f *.csv ${process}/ 2>/dev/null || true

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
