


include { NUMORPHINTENSITY   } from '../../modules/local/numorphintensity/'
include { NUMORPHALIGN       } from '../../modules/local/numorphalign/'
include { NUMORPHSTITCH      } from '../../modules/local/numorphstitch/'

workflow NUMORPH_PREPROCESSING {

    take:
    samplesheet  // channel: [ val(meta), path(imf_directory), path(parameter_file) ]

    main:

    ch_versions = Channel.empty()

    NUMORPHINTENSITY (samplesheet)
    def intensity_out = NUMORPHINTENSITY.out


    NUMORPHALIGN (
        samplesheet,
        intensity_out.adj_params_mat,
        intensity_out.path_table_mat,
        intensity_out.thresholds_mat,
        intensity_out.NM_variables
    )
    def align_out = NUMORPHALIGN.out


    NUMORPHSTITCH (
        samplesheet,
        align_out.alignment_table_mat,
        align_out.z_displacement_align_mat,
        align_out.path_table_mat,
        intensity_out.thresholds_mat,
        intensity_out.adj_params_mat,
        align_out.NM_variables
        )

    def stitch_out = NUMORPHSTITCH.out

    emit:

    stitched                  = stitch_out.stitched                    // channel: [ path(stitched_dir) ]
    intensity_thresholds      = intensity_out.thresholds_mat          // channel: [path(thresholds_mat) ]
    NM_variables              = stitch_out.NM_variables             // channel: [path(NM_variables) ]
    versions                  = ch_versions                           // channel: [ versions.yml ]
}
