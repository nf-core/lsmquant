#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/lsmquant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/lsmquant
    Website: https://nf-co.re/lsmquant
    Slack  : https://nfcore.slack.com/channels/lsmquant
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//include { NUMORPH_PREPROCESSING } from './subworkflows/local/numorph_preprocessing'
include { PIPELINE_INITIALISATION       } from './subworkflows/local/utils_nfcore_lsmquant_pipeline'
include { PIPELINE_COMPLETION           } from './subworkflows/local/utils_nfcore_lsmquant_pipeline'
include { NUMORPH_INTENSITYADJUSTMENT   } from './modules/local/numorph/intensityadjustment'
include { LSMQUANT                      } from './workflows/lsmquant'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Channels
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
ch_output_dir = Channel.fromPath(params.outdir, type: 'dir')
ch_parameter_file = Channel.fromPath(params.parameter_file )
ch_sample_name = Channel.value(params.sample_name)
ch_stage = Channel.value(params.stage)



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow NFCORE_LSMQUANT {

    take:
    ch_input_dir
    ch_output_dir
    ch_parameter_file
    ch_sample_name
    ch_stage

    main:
    LSMQUANT(ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage)
    
    def lsmquant_output = LSMQUANT.out

    emit:
    versions        = lsmquant_output.versions
    intensity_png             = lsmquant_output.intensity_png
    intensity_tif             = lsmquant_output.intensity_tif
    intensity_json            = lsmquant_output.intensity_json
    intensity_mat             = lsmquant_output.intensity_mat
    //align_tif                 = lsmquant_output.align_tif
    //align_json                = lsmquant_output.align_json
    //align_mat                 = lsmquant_output.align_mat
    //align_int_png             = lsmquant_output.align_int_png
    //align_int_tif             = lsmquant_output.align_int_tif 
    

}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:

    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.help,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input
    )

    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_LSMQUANT (
        ch_input_dir,
        ch_output_dir,
        ch_parameter_file,
        ch_sample_name,
        ch_stage
    )

    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
       
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
