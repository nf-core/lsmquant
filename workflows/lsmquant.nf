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
include { STAGEFILES             } from '../modules/local/stagefiles'

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

    // stage input files into the working directory
    // if test profile then first data needs to be unzipped
    if ( workflow.profile.contains('test') ) {
        params.stage = 'preprocessing'

        samplesheet
            .map { meta, img_directory, parameter_file ->
                tuple(meta, img_directory)
            }
            .set { img_archive }

        UNZIPFILES (img_archive)
        ch_versions = ch_versions.mix(UNZIPFILES.out.versions)

        def unzipped_output = UNZIPFILES.out.files

        unzipped_output
            .join(samplesheet)
            .map { meta, unzipped, raw_img_directory, parameter_file ->
                tuple(meta, unzipped, parameter_file)
            }
            .set { ch_samplesheet }
    }
    else {
        samplesheet
            .map { meta, img_directory, parameter_file ->
                tuple(meta, img_directory)
            }
            .set { img_dir }

        STAGEFILES (img_dir)

        ch_versions = ch_versions.mix(STAGEFILES.out.versions)
        def staged_images = STAGEFILES.out.raw_files

        staged_images
            .join(samplesheet)
            .map { meta, staged, raw_img_directory, parameter_file ->
                tuple(meta, staged, parameter_file)
            }
            .set { ch_samplesheet }
    }

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
    // run ara registration
    if (params.ara_registration) {

            ARAREGISTRATION (samplesheet)
            ch_versions = ch_versions.mix(ARAREGISTRATION.out.versions)
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

}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
