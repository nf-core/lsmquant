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
include { LSMQUANT                      } from './workflows/lsmquant'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Channels
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
//ch_output_dir = Channel.fromPath(params.outdir, type: 'dir')
ch_parameter_file = Channel.fromPath(params.parameter_file )
ch_sample_name = Channel.value(params.sample_name)
ch_stage = Channel.value(params.stage)

println "Output directory is: ${params.outdir}"


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
    //ch_output_dir
    ch_parameter_file
    ch_sample_name
    //ch_stage

    main:
    LSMQUANT(ch_input_dir, ch_parameter_file, ch_sample_name)
    
    def lsmquant_output = LSMQUANT.out

    emit:
    versions                       = lsmquant_output.versions
    out_samples                    = lsmquant_output.out_samples
    out_variables                  = lsmquant_output.out_variables
    out_NM_variables               = lsmquant_output.NM_variables
    out_stitched                   = lsmquant_output.out_stitched
    //int_samples                   = lsmquant_output.int_samples
    //int_variables                 = lsmquant_output.int_variables
    //NM_variables                  = lsmquant_output.int_NM_variables
    //intensity_output         = lsmquant_output.intensity_output
    //align_output             = lsmquant_output.align_output
    //stitch_output            = lsmquant_output.stitch_output

    //intensity_png             = lsmquant_output.intensity_png
    //intensity_tif             = lsmquant_output.intensity_tif
    //intensity_json            = lsmquant_output.intensity_json
    //intensity_mat             = lsmquant_output.intensity_mat
    //align_tif                 = lsmquant_output.align_tif
    //align_json                = lsmquant_output.align_json
    //align_mat                 = lsmquant_output.align_mat
    //align_int_png             = lsmquant_output.align_int_png
    //align_int_tif             = lsmquant_output.align_int_tif
    //stitch_tif                = lsmquant_output.stitch_tif
    //stitch_json               = lsmquant_output.stitch_json
    //stitch_mat                = lsmquant_output.stitch_mat
    //stitch_int_png            = lsmquant_output.stitch_int_png
    //stitch_int_tif            = lsmquant_output.stitch_int_tif
    //resample_nii             = lsmquant_output.resample_nii
    //resample_int_png          = lsmquant_output.resample_int_png
    //resample_int_tif          = lsmquant_output.resample_int_tif
    //resample_json             = lsmquant_output.resample_json
    //resample_mat              = lsmquant_output.resample_mat
    //resample_stitch_tif       = lsmquant_output.resample_stitch_tif


    
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
        //ch_output_dir,
        ch_parameter_file,
        ch_sample_name,
        //ch_stage
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
