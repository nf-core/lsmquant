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

process NUMORPHREGISTER {
    tag "$ch_sample_name"
    label 'process_single'

    container "numorph_preprocessing_module:latest"

    input:
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf
    path ch_input_dir
    path resample_samples
    path resample_variables
    path resample_stitched
    path resample_resampled
    path NM_variables
    path ch_parameter_file
    val ch_sample_name

    output:
    path "results/samples/*"                    , emit: register_output_samples
    path "results/variables/*"                  , emit: register_output_variables
    path "results/NM_variables.json"            , emit: register_NM_variables    
    path "results/stitched/*"                   , emit: register_output_stitched
    path "results/resampled/*"                  , emit: register_output_resampled
    path "results/registered/*"                 , emit: register_output_registered
    path "versions.yml"                         , emit: versions                                     



            //errorStrategy { task.exitStatus == 249 ? 'ignore' : 'terminate' }


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${ch_sample_name}"
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    """
    mkdir -p \$PWD/results/samples/
    mkdir -p \$PWD/results/variables/
    mkdir -p \$PWD/results/stitched/
    mkdir -p \$PWD/results/resampled/

    mv $resample_samples \$PWD/results/samples
    mv $resample_variables \$PWD/results/variables
    mv $resample_stitched \$PWD/results/stitched
    mv $resample_resampled \$PWD/results/resampled
    
    results="\$PWD/results"

    /usr/bin/mlrtapp/numorph_preprocessing_module 'input_dir' \$PWD/$input 'output_dir' \$PWD/$outdir 'parameter_file' $parameter_file 'sample_name' $sample_name 'stage' 'register'
    
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
