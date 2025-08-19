/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { NUMORPHINTENSITY       } from '../modules/local/numorphintensity'
include { NUMORPHALIGN           } from '../modules/local/numorphalign'
include { NUMORPHSTITCH          } from '../modules/local/numorphstitch'
include { NUMORPH_PREPROCESSING  } from '../subworkflows/local/numorph_preprocessing'
include { ARAREGISTRATION        } from '../subworkflows/local/araregistration'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_lsmquant_pipeline'
include { NUMORPHRESAMPLE        } from '../modules/local/numorphresample/'
include { NUMORPHREGISTER        } from '../modules/local/numorphregister/'
include { MAT2JSON               } from '../modules/local/mat2json'
include { UNZIP                  } from '../modules/nf-core/unzip'
include { NUMORPH3DUNET         } from '../modules/local/numorph3dunet'

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


    // if test profile then first data needs to be unzipped
    if ( workflow.profile.contains('test') ) {
        params.stage = 'preprocessing'

        samplesheet
            .map { meta, img_directory, parameter_file ->
                tuple(meta, img_directory)
            }
            .set { img_archive }

        UNZIP (img_archive)
        ch_versions = ch_versions.mix(UNZIP.out.versions)

        def unzipped_output = UNZIP.out.unzipped_archive

        unzipped_output
            .join(samplesheet)
            .map { meta, unzipped, raw_img_directory, parameter_file ->
                def img_files = file("${unzipped}")
                tuple(meta, img_files, parameter_file)
            }
            .set { samplesheet }
    }

    // the complete analysis workflow
    if (params.stage == 'full') {
        NUMORPH_PREPROCESSING (samplesheet)

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
            ARAREGISTRATION (stitched_data, NM_variables)
            ch_versions = ch_versions.mix(ARAREGISTRATION.out.versions)
        }

        model_file = Channel.fromPath(params.model_file, checkIfExists: !params.model_file.startsWith('http'))
        NUMORPH3DUNET (stitched_data, model_file)
        ch_versions = ch_versions.mix(NUMORPH3DUNET.out.versions)
    }

    if (params.stage == 'preprocessing') {
        NUMORPH_PREPROCESSING (samplesheet)
        ch_versions = ch_versions.mix(NUMORPH_PREPROCESSING.out.versions)

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
