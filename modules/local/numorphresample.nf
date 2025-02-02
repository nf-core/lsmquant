// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/modules/nf-core/
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.

process NUMORPHRESAMPLE {
    tag "$meta.id"
    label 'process_single'

    container "numorph_analyze:latest"

   

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
    mv $NM_variables \$PWD/results

    results="\$PWD/results"


    /usr/bin/mlrtapp/numorph_analyze 'input_dir' \$PWD/results/stitched 'output_dir' \$results 'parameter_file' $parameter_file 'sample_name' $meta.id 'stage' 'resample'
    
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
        numorphresample: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
