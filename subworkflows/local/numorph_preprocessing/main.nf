//
// NUMORPH PREPROCESSING
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT  MODULES 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { NUMORPH_INTENSITYADJUSTMENT } from '../modules/local/numorph/intensityadjustment/main'
include { NUMORPH_CHANNEL_ALIGNMENT } from '../modules/local/numorph/channel_alignment/main'
include { NUMOPRH_STITCHING } from '../modules/local/numorph/stitching/main'


/*
========================================================================================
    SUBWORKFLOW FOR PREPROCESSING
========================================================================================
*/

workflow NUMORPH_PREPROCESSING {

    take:
    input_dir
    output_dir
    parameter_file
    sample_name
    stage

    main:
    versions = Channel.empty()

    NUMORPH_INTENSITYADJUSTMENT(input_dir, output_dir, parameter_file, sample_name, stage) 

    
    emit:
    

   

}