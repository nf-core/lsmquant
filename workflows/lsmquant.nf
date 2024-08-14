/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { NUMORPHINTENSITY       } from '../modules/local/numorphintensity'
include { NUMORPHALIGN           } from '../modules/local/numorphalign'
include { NUMORPHSTITCH          } from '../modules/local/numorphstitch'
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
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
    ch_output_dir       // Channel: /path/to/output directory
    ch_parameter_file   // Channel: /path/to/parameter file
    ch_sample_name      // Channel: sample name
    ch_stage            // Channel: stage

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // create channels from params
    ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
    ch_output_dir = Channel.fromPath(params.outdir, type: 'dir')
    ch_parameter_file = Channel.fromPath(params.parameter_file)
    ch_sample_name = Channel.value(params.sample_name)
    ch_stage = Channel.value(params.stage)



    //
    // MODULE: Run NumorphIntensity
    //
    NUMORPHINTENSITY(ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage)

    def intensity_output = NUMORPHINTENSITY.out


    // TODO caro: get output from intensity and pass to align



    //
    // MODULE: Run NumorphAlign
    //
    // TODO caro: stage needs to be set to align in this step
    //NUMORPHALIGN (ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage)
    
    //def align_output = NUMORPHALIGN.out

    //
    // MODULE: Run NumorphStitch
    //
    // TODO caro: stage needs to be set to stitch in this step
    //NUMORPHSTITCH (ch_input_dir, ch_output_dir, ch_parameter_file, ch_sample_name, ch_stage)


    //
    // MODULE: Run FastQC
    //
    /*
    FASTQC (
        ch_samplesheet
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())
    */
    ch_versions = ch_versions.mix(intensity_output.versions)
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

    /*
    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = Channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        Channel.fromPath(params.multiqc_config, checkIfExists: true) :
        Channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        Channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))

    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )
    */
    emit:
    intensity_png             = intensity_output.png
    intensity_tif             = intensity_output.tif
    intensity_json            = intensity_output.json
    intensity_mat             = intensity_output.mat
    //align_tif                 = align_output.align_tif
    //align_json                = align_output.json
    //align_mat                 = align_output.mat
    //align_int_png             = align_output.intensity_png
    //align_int_tif             = align_output.intensity_tif




    versions        = ch_versions              // channel: [ path(versions.yml) ]

    
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
