
include { NUMORPHRESAMPLE        } from '../../../modules/local/numorphresample/'
include { NUMORPHREGISTER        } from '../../../modules/local/numorphregister/'
include { MAT2JSON               } from '../../../modules/local/mat2json'
include { softwareVersionsToYAML } from '../../../subworkflows/nf-core/utils_nfcore_pipeline/'

workflow ARAREGISTRATION {

    take:

    stitched_data // channel: [ val(meta), path(images), path(parameters.csv)  ]
    main:

    ch_versions = Channel.empty()
    sample_meta = stitched_data.map { meta, img_dir, params -> meta }

    NUMORPHRESAMPLE (
            stitched_data
        )

    def resample_output = NUMORPHRESAMPLE.out.resampled
    ch_versions = ch_versions.mix(NUMORPHRESAMPLE.out.versions)

    
def resample_data = resample_output
        .join(stitched_data)
        .map { meta, resampled, stitched_img_directory, parameter_file ->
            tuple(meta, resampled, parameter_file)
        }

    NUMORPHREGISTER (
        resample_data
    )

    ch_versions = ch_versions.mix(NUMORPHREGISTER.out.versions)
    def reg_output = NUMORPHREGISTER.out

    def registration_files = reg_output.variables.flatten()

    sample_meta.combine(registration_files)
            .mix (
                sample_meta.combine(reg_output.res_mat),
                sample_meta.combine(reg_output.NM_variables)
            )
            .set {mat_files_reg}

    MAT2JSON (mat_files_reg, "registration")
    ch_versions = ch_versions.mix(MAT2JSON.out.versions)

    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'lsmquant_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    emit:

    res_mat     = NUMORPHREGISTER.out.res_mat
    variables    = NUMORPHREGISTER.out.variables            // channel: variables
    registered   = NUMORPHREGISTER.out.registered           // channel: registered
    NM_variables = NUMORPHREGISTER.out.NM_variables         // channel: NM_variables
    versions     = ch_collated_versions                     // channel: [ versions.yml ]
}
