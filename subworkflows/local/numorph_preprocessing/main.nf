
include { NUMORPH_INTENSITY                    } from '../../../modules/nf-core/numorph/intensity'
include { NUMORPHALIGN                         } from '../../../modules/local/numorphalign/'
include { NUMORPHSTITCH                        } from '../../../modules/local/numorphstitch/'
include { MAT2JSON                             } from '../../../modules/nf-core/mat2json/'
include { softwareVersionsToYAML               } from '../../../subworkflows/nf-core/utils_nfcore_pipeline/'

workflow NUMORPH_PREPROCESSING {

    take:
    samplesheet  // channel: [ val(meta), path(img_directory), path(parameter_file) ]

    main:


    NUMORPH_INTENSITY (samplesheet)


    def align_input = samplesheet
        .combine(NUMORPH_INTENSITY.out.variables)
        .combine(NUMORPH_INTENSITY.out.NM_variable)
        .map { meta, img_dir, parameter_file, meta2, variables, meta3, NM_variable ->
            [
                meta,
                img_dir,
                parameter_file,
                variables,
                NM_variable
            ]
        }

    NUMORPHALIGN (align_input)

    def stitch_input = samplesheet
        .combine(NUMORPHALIGN.out.variables_alignment)
        .combine(NUMORPHALIGN.out.NM_variable)
        .map { meta, img_dir, parameter_file, meta2, variables_alignment, meta3, NM_variable ->
            [
                meta,
                img_dir,
                parameter_file,
                variables_alignment,
                NM_variable
            ]
        }

    NUMORPHSTITCH (stitch_input)

    def mat_files = NUMORPHSTITCH.out.variables_stitched
        .flatMap { meta, variables_dir ->
            variables_dir.listFiles()
                .findAll { it.name.endsWith('.mat') }
                .collect { matfile ->  [meta, matfile] }
        }

    MAT2JSON (mat_files, "preprocessing" )

    emit:

    variables                 = NUMORPHSTITCH.out.variables_stitched          // channel: [ path(variables_dir) ]
    stitched                  = NUMORPHSTITCH.out.stitched                   // channel: [ path(stitched_dir) ]
    NM_variables              = NUMORPHSTITCH.out.NM_variable                // channel: [path(NM_variables) ]

}
