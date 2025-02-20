/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { NUMORPHINTENSITY       } from '../modules/local/numorphintensity'
include { NUMORPHALIGN           } from '../modules/local/numorphalign'
include { NUMORPHSTITCH          } from '../modules/local/numorphstitch'
include { NUMORPH_PREPROCESSING  } from '../subworkflows/local/numorph_preprocessing'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_lsmquant_pipeline'
include { NUMORPHRESAMPLE        } from '../modules/local/numorphresample/'
include { NUMORPHREGISTER        } from '../modules/local/numorphregister/'

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


    if (params.stage == 'full') {
        NUMORPH_PREPROCESSING (samplesheet)

        def stitched_output = NUMORPH_PREPROCESSING.out.stitched
        def NM_variables = NUMORPH_PREPROCESSING.out.NM_variables

        stitched_output
            .join(samplesheet)
            .map { meta, stitched, raw_img_directory, parameter_file ->
                tuple(meta, stitched, parameter_file)
            }
            .set { stitched_data }

        NUMORPHRESAMPLE (
            stitched_data,
            NM_variables
        )

        def resample_output = NUMORPHRESAMPLE.out.resampled

        resample_output
            .join(samplesheet)
            .map { meta, resampled, raw_img_directory, parameter_file ->
                tuple(meta, resampled, parameter_file)
            }
            .set { resample_data }

        NUMORPHREGISTER (
            resample_data,
            NUMORPHRESAMPLE.out.NM_variables
        )



    }
    if (params.stage == 'preprocessing') {
        NUMORPH_PREPROCESSING (samplesheet)

    }
    //
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
