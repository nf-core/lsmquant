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
    //ch_output_dir       // Channel: /path/to/output directory dont need this 
    ch_parameter_file   // Channel: /path/to/parameter file
    ch_sample_name      // Channel: sample name
    //ch_stage            // Channel: stage

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    

    // create channels from params
    //ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
    //ch_output_dir = Channel.fromPath(params.outdir, type: 'dir')
    //ch_parameter_file = Channel.fromPath(params.parameter_file)
    //ch_sample_name = Channel.value(params.sample_name)
    //ch_stage = Channel.value(params.stage)

    //println "Workflow work directory: ${ch_output_dir}"
    

    //
    // MODULE: Run NumorphIntensity
    //
    NUMORPHINTENSITY(ch_input_dir, ch_parameter_file, ch_sample_name)

    def intensity_output = NUMORPHINTENSITY.out
    //ch_versions = ch_versions.mix(intensity_output.versions)
   
    // combine the output of intensity module
    //ch_int_combined = intensity_output.int_out_samples.mix(intensity_output.int_out_variables).mix(intensity_output.int_NM_variables)

    intensity_output.int_out_variables.view()
    intensity_output.int_output_samples.view()
    intensity_output.int_NM_variables.view()





    //
    // MODULE: Run NumorphAlign
    //
    // quick and dirfty solution 
    NUMORPHALIGN (ch_input_dir, intensity_output.int_output_samples,intensity_output.int_out_variables, intensity_output.int_NM_variables,ch_parameter_file, ch_sample_name)

    // 
    def align_output = NUMORPHALIGN.out
    // combine the output of align module
    //ch_align_combined = align_output.align_out_samples.mix(align_output.align_out_variables).mix(align_output.align_NM_variables)

    //
    // MODULE: Run NumorphStitch
    //
    // quick and dirfty solution 
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
    //int_output                      = intensity_output.
    //int_samples                      = intensity_output.int_output_samples
    //int_variables                    = intensity_output.int_out_variables
    //int_NM_variables                 = intensity_output.int_NM_variables
    out_samples              = stitch_output.stitch_output_samples
    out_variables            = stitch_output.stitch_output_variables
    NM_variables             = stitch_output.stitch_NM_variables
    out_stitched             = stitch_output.stitch_output_stitched

    //output                     = stitch_output.output

    //intensity_png             = intensity_output.png
    //intensity_tif             = intensity_output.tif
    //intensity_json            = intensity_output.json
    //intensity_mat             = intensity_output.mat
    //align_tif                 = align_output.align_tif
    //align_json                = align_output.json
    //align_mat                 = align_output.mat
    //align_int_png             = align_output.intensity_png
    //align_int_tif             = align_output.intensity_tif
    //stitch_tif                = stitch_output.stitch_tif
    //stitch_json               = stitch_output.json
    //stitch_mat                = stitch_output.mat
    //stitch_int_png            = stitch_output.intensity_png
    //stitch_int_tif            = stitch_output.intensity_tif
    //resample_int_png          = resample_output.intensity_png
    //resample_int_tif          = resample_output.intensity_tif
    //resample_stitch_tif       = resample_output.stitch_tif
    //resample_json             = resample_output.json
    //resample_mat              = resample_output.mat
    //resample_nii              = resample_output.resampled_nii
    


    versions        = ch_versions              // channel: [ path(versions.yml) ]

    
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
