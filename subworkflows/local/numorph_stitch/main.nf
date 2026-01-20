include { NUMORPHINTENSITY                     } from '../../../modules/local/numorphintensity/'
include { NUMORPHSTITCH                        } from '../../../modules/local/numorphstitch/'
include { MAT2JSON as MAT2JSON_INT             } from '../../../modules/local/mat2json/'
include { MAT2JSON as MAT2JSON_STITCH          } from '../../../modules/local/mat2json/'
include { softwareVersionsToYAML               } from '../../../subworkflows/nf-core/utils_nfcore_pipeline/'

workflow NUMORPH_STITCH {

    take:

    samplesheet  // channel: [ val(meta), path(img_directory), path(parameter_file) ]


    main:

    ch_versions = Channel.empty()

    sample_meta = samplesheet.map { meta, img_dir, params -> meta }

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
    .set { mat_files_int}

    // empty channels for alignment outputs
    empty_align_table_mat = samplesheet.map {[]}
    empty_z_displacement_align_mat = samplesheet.map {[]}

    NUMORPHSTITCH (
        samplesheet,
        empty_align_table_mat,
        empty_z_displacement_align_mat,
        intensity_out.path_table_mat,
        intensity_out.thresholds_mat,
        intensity_out.adj_params_mat,
        intensity_out.NM_variables
        )

    def stitch_out = NUMORPHSTITCH.out
    ch_versions = ch_versions.mix(stitch_out.versions)

    stitch_out.variables
        .flatten()
        .filter { file -> file.toString().endsWith('.mat') }
        .combine(sample_meta)
        .map {file, meta -> tuple(meta, file) }
        .set { mat_files_stitch }

    MAT2JSON_INT (mat_files_int, "intensity" )
    MAT2JSON_STITCH (mat_files_stitch, "stitch" )
    ch_versions = ch_versions.mix(MAT2JSON_INT.out.versions)

    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'lsmquant_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    emit:
    stitched                  = stitch_out.stitched                    // channel: [ path(stitched_dir) ]
    intensity_thresholds      = intensity_out.thresholds_mat           // channel: [path(thresholds_mat) ]
    NM_variables              = stitch_out.NM_variables                // channel: [path(NM_variables) ]
    versions                  = ch_collated_versions
}
