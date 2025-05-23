
include { NUMORPHRESAMPLE        } from '../../../modules/local/numorphresample/'
include { NUMORPHREGISTER        } from '../../../modules/local/numorphregister/'
include { MAT2JSON               } from '../../../modules/local/mat2json'

workflow ARAREGISTRATION {

    take:

    stitched_data // channel: [ val(meta), path(images), path(parameters.csv)  ]
    NM_variables

    main:

    ch_versions = Channel.empty()
    ch_NM_variables = NM_variables.ifEmpty( null )

    NUMORPHRESAMPLE (
            stitched_data,
            ch_NM_variables
        )

    def resample_output = NUMORPHRESAMPLE.out.resampled
    ch_versions = ch_versions.mix(NUMORPHRESAMPLE.out.versions)

    resample_output
        .join(stitched_data)
        .map { meta, resampled, stitched_img_directory, parameter_file ->
            tuple(meta, resampled, parameter_file)
        }
        .set { resample_data }

    NUMORPHREGISTER (
        resample_data,
        NUMORPHRESAMPLE.out.NM_variables
    )

    ch_versions = ch_versions.mix(NUMORPHREGISTER.out.versions)

    emit:

    reg_mask     = NUMORPHREGISTER.out.reg_mask     // channel: reg_mask
    registered   = NUMORPHREGISTER.out.registered   // channel: registered
    NM_variables = NUMORPHREGISTER.out.NM_variables // channel: NM_variables
    versions     = ch_versions                      // channel: [ versions.yml ]
}
