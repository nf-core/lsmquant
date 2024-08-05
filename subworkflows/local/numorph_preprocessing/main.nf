//
// NUMORPH PREPROCESSING
//
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Check if the input directory exists

// Check mendatory parameters

// Create Channles for input parameters

ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
ch_output_dir = Channel.fromPath(params.outdir, type: 'dir')
ch_parameter_file = Channel.fromPath(params.parameter_file)
ch_sample_name = Channel.value(params.sample_name)
ch_stage = Channel.value(params.stage)


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT  MODULES 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { NUMORPH_INTENSITYADJUSTMENT } from '../../../modules/local/numorph/intensityadjustment'
//include { NUMORPH_CHANNEL_ALIGNMENT } from '../modules/local/numorph/channel_alignment/main'
//include { NUMOPRH_STITCHING } from '../modules/local/numorph/stitching/main'

//lsmquant/nf-core-lsmquant/modules/local/numorph/intensityadjustment
/*
========================================================================================
    SUBWORKFLOW FOR PREPROCESSING
========================================================================================
*/

workflow NUMORPH_PREPROCESSING {

    take:
    ch_input_dir
    ch_output_dir
    ch_parameter_file
    ch_sample_name
    ch_stage

    main:
    versions = Channel.empty()

    NUMORPH_INTENSITYADJUSTMENT(ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage) 

    
    //emit:
    

   

}