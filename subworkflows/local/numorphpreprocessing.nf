// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { SAMTOOLS_SORT      } from '../../../modules/nf-core/samtools/sort/main'
include { SAMTOOLS_INDEX     } from '../../../modules/nf-core/samtools/index/main'
include { NUMORPHINTENSITY   } from '../../../modules/local/numorphintensity'
include { NUMORPHALIGN       } from '../../../modules/local/numorphalign'
include { NUMORPHSTITCH      } from '../../../modules/local/numorphstitch'

workflow NUMORPHPREPROCESSING {

    take:
    // TODO nf-core: edit input (take) channels]
    ch_input_dir        // Channel: /path/to/input directory
    ch_output_dir       // Channel: /path/to/output directory
    ch_parameter_file   // Channel: /path/to/parameter file
    ch_sample_name      // Channel: sample name
    ch_stage            // Channel: stage

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow

    // MODULE: Run NumorphIntensity
    NUMORPHINTENSITY(ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage)


    // MODULE: Run NumorphAlign
    NUMORPHALIGN (ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage)
    
    // MODULE: Run NumorphStitch
    NUMORPHSTITCH(ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage)

    

    
    ch_versions = ch_versions.mix(NUMORPHINTENSITY.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

