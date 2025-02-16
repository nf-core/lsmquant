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
include { NUMORPHRESAMPLE        } from '../modules/local/numorphresample.nf'
include { NUMORPHREGISTER        } from '../modules/local/numorphregister.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/




workflow LSMQUANT {

    take:
    sample_data

    main:

    ch_versions = Channel.empty()


    if (params.stage == 'full') {
        NUMORPH_PREPROCESSING (sample_data)

        def stitched_data = NUMORPH_PREPROCESSING.out.stitched
        def NM_variables = NUMORPH_PREPROCESSING.out.NM_variables


        NUMORPHRESAMPLE (
            stitched_data,
            NM_variables
        )

        def resample_out = NUMORPHRESAMPLE.out

        NUMORPHREGISTER (
            resample_out.resampled,
            resample_out.NM_variables
        )



    }
    if (params.stage == 'preprocessing') {
        NUMORPH_PREPROCESSING (sample_data)

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
