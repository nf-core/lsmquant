
include { NUMORPHINTENSITY   } from '../../../modules/local/numorphintensity/'
include { NUMORPHALIGN       } from '../../../modules/local/numorphalign/'
include { NUMORPHSTITCH      } from '../../../modules/local/numorphstitch/'
include { MAT2JSON           } from '../../../modules/local/mat2json/'

workflow NUMORPH_PREPROCESSING {

    take:
    samplesheet  // channel: [ val(meta), path(imf_directory), path(parameter_file) ]

    main:

    ch_versions = Channel.empty()

    NUMORPHINTENSITY (samplesheet)
    def intensity_out = NUMORPHINTENSITY.out
    /*
    intensity_out
        .flatten()
        .filter { file -> file.path.endsWith(".mat") }
        .set { filtered_mat_files }
    samplesheet
        .combine(filtered_mat_files)
        .map { meta, img_directory, parameter_file, matfile ->
            tuple(meta, matfile)
        }
        .set { mat_files }

    MAT2JSON (mat_files)
    */

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
