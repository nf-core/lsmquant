/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { NUMORPHINTENSITY       } from '../modules/local/numorphintensity'
include { NUMORPHALIGN           } from '../modules/local/numorphalign'
include { NUMORPHSTITCH          } from '../modules/local/numorphstitch'
//include { NUMORPHRESAMPLE        } from '../modules/local/numorphresample'
//include { NUMORPHREGISTER        } from '../modules/local/numorphregister'
//include { FASTQC                 } from '../modules/nf-core/fastqc/main'
//include { MULTIQC                } from '../modules/nf-core/multiqc/main'
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
    ch_multiqc_files = Channel.empty()
    

    //
    // MODULE: Run NumorphIntensity
    //
    NUMORPHINTENSITY(ch_input_dir, ch_parameter_file, ch_sample_name)

    def intensity_output = NUMORPHINTENSITY.out
  
    //
    // MODULE: Run NumorphAlign
    //
    NUMORPHALIGN (ch_input_dir, intensity_output.int_output_samples,intensity_output.int_out_variables, intensity_output.int_NM_variables,ch_parameter_file, ch_sample_name)

    // 
    def align_output = NUMORPHALIGN.out
   
    //
    // MODULE: Run NumorphStitch
    //
    NUMORPHSTITCH (ch_input_dir, align_output.align_output_samples,align_output.align_output_variables,align_output.align_NM_variables , ch_parameter_file, ch_sample_name)

    def stitch_output = NUMORPHSTITCH.out


    //
    // MODULE: Run NumorphResample
    //
    //NUMORPHRESAMPLE (stitch_output.input, stitch_output.outdir, stitch_output.parameter_file, stitch_output.sample_name, Channel.value("resample"))
   
    //def resample_output = NUMORPHRESAMPLE.out


    //
    // MODULE: Run NumorphRegister
    // not ready yet
    //NUMORPHREGISTER (ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage)

    //def register_output = NUMORPHREGISTER.out


    
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

    
    emit:
    out_samples              = stitch_output.stitch_output_samples
    out_variables            = stitch_output.stitch_output_variables
    NM_variables             = stitch_output.stitch_NM_variables
    out_stitched             = stitch_output.stitch_output_stitched
    versions        = ch_versions              // channel: [ path(versions.yml) ]

    
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
