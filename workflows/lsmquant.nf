/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { NUMORPH_PREPROCESSING  } from '../subworkflows/local/numorph_preprocessing'
include { ARAREGISTRATION        } from '../subworkflows/local/araregistration'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_lsmquant_pipeline'
include { MAT2JSON               } from '../modules/local/mat2json'
include { NUMORPH3DUNET          } from '../modules/local/numorph3dunet'
include { UNZIPFILES             } from '../modules/nf-core/unzipfiles'
include { UNZIP                  } from '../modules/nf-core/unzip'
include { STAGEFILES             } from '../modules/local/stagefiles'
include { MULTIQC                } from '../modules/nf-core/multiqc'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/



workflow LSMQUANT {

    take:
    samplesheet // channel: samplesheet read in from --input

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // branch input channel based on whether zip archive or directory
    samplesheet.branch { meta, img_directory, parameter_file ->
        zip_archive: img_directory[0].endsWith(".zip")
            return tuple(meta, img_directory, parameter_file)
        directory: true
            return tuple(meta, img_directory, parameter_file)
    }
    .set { samplesheet_split }


    // if zip archive then unzip first
    samplesheet_split.zip_archive
        .map { meta, zip, parameter_file ->
            tuple(meta, zip)
        }
        .set { zip_archive }

    UNZIP (zip_archive)
    ch_versions = ch_versions.mix(UNZIP.out.versions)
    unzipped_output = UNZIP.out.unzipped_archive
    // join unzipped output with  parameter file
    unzipped_output
        .join(samplesheet_split.zip_archive)
        .map { meta, unzipped, zip, parameter_file ->
            tuple(meta, unzipped, parameter_file)
        }
        .set { ch_unzipped }

    // if directory then stage files
    samplesheet_split.directory
        .map { meta, img_directory, parameter_file ->
            tuple(meta, img_directory)
        }
        .set { img_dir }

    STAGEFILES (img_dir)
    ch_versions = ch_versions.mix(STAGEFILES.out.versions)
    staged_images = STAGEFILES.out.raw_files

    staged_images
        .join(samplesheet_split.directory)
        .map { meta, staged, raw_img_directory, parameter_file ->
            tuple(meta, staged, parameter_file)
        }
        .set { ch_stagedfiles }

    // combine unzipped and staged files channels
    ch_samplesheet = Channel.empty()
    ch_samplesheet = ch_unzipped.mix(ch_stagedfiles)

    // run different workflows according to parameter setting
    // the complete analysis workflow with the option of ara registration
    if (params.stage == 'full') {
        NUMORPH_PREPROCESSING (ch_samplesheet)

        def stitched_output = NUMORPH_PREPROCESSING.out.stitched
        def NM_variables = NUMORPH_PREPROCESSING.out.NM_variables
        ch_versions = ch_versions.mix(NUMORPH_PREPROCESSING.out.versions)

        stitched_output
            .join(samplesheet)
            .map { meta, stitched, raw_img_directory, parameter_file ->
                tuple(meta, stitched, parameter_file)
            }
            .set { stitched_data }

        if (params.ara_registration) {
            ARAREGISTRATION (stitched_data)
            ch_versions = ch_versions.mix(ARAREGISTRATION.out.versions)
        }

        model_file = Channel.fromPath(params.model_file, checkIfExists: !params.model_file.startsWith('http'))
        NUMORPH3DUNET (stitched_data, model_file)
        ch_versions = ch_versions.mix(NUMORPH3DUNET.out.versions)
    }



    // run preprocessing workflow with the option to run ara registration
    if (params.stage == 'preprocessing') {
        NUMORPH_PREPROCESSING (ch_samplesheet)
        ch_versions = ch_versions.mix(NUMORPH_PREPROCESSING.out.versions)

        def stitched_output = NUMORPH_PREPROCESSING.out.stitched

        stitched_output
            .join(samplesheet)
            .map { meta, stitched, raw_img_directory, parameter_file ->
                tuple(meta, stitched, parameter_file)
            }
            .set { stitched_data }

        if (params.ara_registration) {
            ARAREGISTRATION (stitched_data)
            ch_versions = ch_versions.mix(ARAREGISTRATION.out.versions)
        }

    }


    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'lsmquant_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

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
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

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
        ch_multiqc_logo.toList(),
        [],
        []
    )
    multiqc_report = MULTIQC.out.report.toList()

    emit:
    multiqc_report          // channel: final MultiQC report
    ch_collated_versions    // channel: collated software versions in YAML file

}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
