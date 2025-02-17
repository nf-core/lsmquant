process NUMORPHREGISTER {
    tag "$meta.id"
    label 'process_single'

    container "carolinschwitalla/numorph_analyze:latest"

    input:
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf
    tuple val(meta), path(resampled_directory), path(parameter_file)
    path NM_variables


    output:
    path "results/variables/reg_params.mat"      , emit: reg_params_mat
    path "results/variables/*_mask.mat"          , emit: reg_mask
    path "results/NM_variables.mat"              , emit: NM_variables
    path "results/registered/*"                 , emit: registered
    path "versions.yml"                         , emit: versions



            //errorStrategy { task.exitStatus == 249 ? 'ignore' : 'terminate' }


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir -p \$PWD/results/variables/
    mkdir -p \$PWD/results/resampled/
    mkdir -p \$PWD/results/registered/

    mv $resampled_directory \$PWD/results/resampled

    results="\$PWD/results"

    /usr/bin/mlrtapp/numorph_analyze 'input_dir' \$PWD/$resampled_directory 'output_dir' \$PWD/results/ 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'register' 'NM_variables' \$PWD/$NM_variables 'use_processed_images' 'resampled'


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
        numoprhregister: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
