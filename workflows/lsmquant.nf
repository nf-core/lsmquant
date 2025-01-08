/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { NUMORPHINTENSITY       } from '../modules/local/numorphintensity'
include { NUMORPHALIGN           } from '../modules/local/numorphalign'
include { NUMORPHSTITCH          } from '../modules/local/numorphstitch'
include { NUMORPHRESAMPLE        } from '../modules/local/numorphresample'
include { NUMORPHREGISTER        } from '../modules/local/numorphregister'
include { BASICPY                } from '../modules/nf-core/basicpy'


include { paramsSummaryMap       } from 'plugin/nf-validation'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_lsmquant_pipeline'
//include { NUMORPHPREPROCESSING   } from '../subworkflows/local/numorphpreprocessing'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/




workflow LSMQUANT {

    take:
    ch_input_dir        // Channel: /path/to/input directory
    ch_parameter_file   // Channel: /path/to/parameter file
    ch_sample_name      // Channel: sample name
    


    main:

    ch_versions = Channel.empty()
    ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
    ch_parameter_file = Channel.fromPath(params.parameter_file )
    ch_sample_name = Channel.value(params.sample_name)

 
    //Run workflow steps based on parameter input values
    if (params.intensity) {
        NUMORPHINTENSITY(ch_input_dir, ch_parameter_file, ch_sample_name)

    }
    if (params.basicpy ) {
        BASICPY()

    }
    
    if (params.numorph) {
        //
    // MODULE: Run NumorphIntensity
    //
    NUMORPHINTENSITY (
        ch_input_dir,
        ch_parameter_file,
        ch_sample_name
    )

    def intensity_out = NUMORPHINTENSITY.out
  
    //
    // MODULE: Run NumorphAlign
    //
    NUMORPHALIGN (
        ch_input_dir,
        intensity_out.samples,
        intensity_out.variables,
        intensity_out.int_NM_variables,
        ch_parameter_file,
        ch_sample_name
        )

    // 
    def align_out = NUMORPHALIGN.out
   
    //
    // MODULE: Run NumorphStitch
    //
    NUMORPHSTITCH (
        ch_input_dir,
        intensity_out.samples,
        align_out.samples,
        align_out.variables,
        align_out.align_NM_variables,
        ch_parameter_file,
        ch_sample_name
        )

    def stitch_out = NUMORPHSTITCH.out


    //
    // MODULE: Run NumorphResample
    //
    NUMORPHRESAMPLE (
        ch_input_dir,
        align_out.samples,
        stitch_out.variables,
        stitch_out.stitched,
        stitch_out.NM_variables,
        ch_parameter_file,
        ch_sample_name
        )
   
    def resample_out = NUMORPHRESAMPLE.out


    //
    // MODULE: Run NumorphRegister
    // 
    NUMORPHREGISTER (
        ch_input_dir,
        align_out.samples,
        stitch_out.variables,
        stitch_out.stitched,
        resample_out.resampled,
        resample_out.NM_variables,
        ch_parameter_file,
        ch_sample_name
        )

    def register_output = NUMORPHREGISTER.out
      
    }

    


    
    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_pipeline_software_mqc_versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    
   
    
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
