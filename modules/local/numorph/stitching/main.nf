

process NUMOPRH_STITCHING {
    tag "$meta.id"
    label 'process_single'

    container "numorph_preprocessing_module:latest"

    input:
    tuple val(meta), path(meta.input_dir), path(meta.output_dir), path(meta.param_file)
    
    output:
    tuple val(meta)
    path("${meta.output_dir}/*")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    stage = stitch

    
    ./numorph_preprocessing_module \\
        'input_dir' '${meta.input_dir}' \\
        'output_dir' '${meta.output_dir}' \\
        'parameter_file' '${meta.param_file}' \\
        'sample_name' '${meta.sample_name}' \\
        \${stage} \\
        

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        numorph: 1.0
    END_VERSIONS
    """


    
}