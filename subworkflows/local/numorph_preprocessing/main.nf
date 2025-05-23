
include { NUMORPHINTENSITY                     } from '../../../modules/local/numorphintensity/'
include { NUMORPHALIGN                         } from '../../../modules/local/numorphalign/'
include { NUMORPHSTITCH                        } from '../../../modules/local/numorphstitch/'
include { MAT2JSON as MAT2JSON_INT             } from '../../../modules/local/mat2json/'
include { MAT2JSON as MAT2JSON_ALIGN           } from '../../../modules/local/mat2json/'
include { MAT2JSON as MAT2JSON_STITCH          } from '../../../modules/local/mat2json/'

workflow NUMORPH_PREPROCESSING {

    take:
    samplesheet  // channel: [ val(meta), path(imf_directory), path(parameter_file) ]

    main:

    ch_versions = Channel.empty()
    sample_meta = samplesheet.first().map { meta, img_dir, params -> meta }


    NUMORPHINTENSITY (samplesheet)
    def intensity_out = NUMORPHINTENSITY.out
    ch_versions = ch_versions.mix(intensity_out.versions)

    // Create a tuple channel with all mat files and appropriate meta
    sample_meta.combine(NUMORPHINTENSITY.out.adj_params_mat)
    .mix(
        sample_meta.combine(NUMORPHINTENSITY.out.path_table_mat),
        sample_meta.combine(NUMORPHINTENSITY.out.thresholds_mat),
        sample_meta.combine(NUMORPHINTENSITY.out.NM_variables)
    )
    .groupTuple(by: 0)
    .set { mat_files_ch }

    NUMORPHALIGN (
        samplesheet,
        intensity_out.adj_params_mat,
        intensity_out.path_table_mat,
        intensity_out.thresholds_mat,
        intensity_out.NM_variables
    )
    def align_out = NUMORPHALIGN.out
    ch_versions = ch_versions.mix(align_out.versions)

    sample_meta.combine(NUMORPHALIGN.out.alignment_table_mat)
    .mix(
        sample_meta.combine(NUMORPHALIGN.out.path_table_mat),
        sample_meta.combine(NUMORPHALIGN.out.z_displacement_align_mat),
        sample_meta.combine(NUMORPHALIGN.out.NM_variables)
    )
    .groupTuple(by: 0)
    .set { mat_files_align }


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
    ch_versions = ch_versions.mix(stitch_out.versions)

    stitch_out.variables
        .flatten()
        .filter { file -> file.toString().endsWith('.mat') }
        .combine(sample_meta)
        .map {file, meta -> tuple(meta, file) }
        .groupTuple()
        .set { mat_files_stitch }


    MAT2JSON_INT (mat_files_ch, "intensity" )
    MAT2JSON_ALIGN (mat_files_align, "align" )
    MAT2JSON_STITCH (mat_files_stitch, "stitch" )
    ch_versions = ch_versions.mix(MAT2JSON_INT.out.versions)

    emit:

    stitched                  = stitch_out.stitched                    // channel: [ path(stitched_dir) ]
    intensity_thresholds      = intensity_out.thresholds_mat          // channel: [path(thresholds_mat) ]
    NM_variables              = stitch_out.NM_variables             // channel: [path(NM_variables) ]
    versions                  = ch_versions                           // channel: [ versions.yml ]
}
