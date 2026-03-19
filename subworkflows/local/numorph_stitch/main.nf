include { NUMORPH_INTENSITY                    } from '../../../modules/nf-core/numorph/intensity'
include { NUMORPHSTITCH                        } from '../../../modules/local/numorphstitch/'
include { MAT2JSON                             } from '../../../modules/nf-core/mat2json/'

workflow NUMORPH_STITCH {

    take:

    samplesheet  // channel: [ val(meta), path(img_directory), path(parameter_file) ]


    main:


    NUMORPH_INTENSITY (samplesheet)

    def stitch_input = samplesheet
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

    NUMORPHSTITCH (stitch_input)

    def stitch_out = NUMORPHSTITCH.out


    def mat_files = NUMORPHSTITCH.out.variables_stitched
        .flatMap { meta, variables_dir ->
            variables_dir.listFiles()
                .findAll { it.name.endsWith('.mat') }
                .collect { matfile ->  [meta, matfile] }
        }

    MAT2JSON (mat_files, "numorph_stitch" )


    emit:
    variables                 = NUMORPHSTITCH.out.variables_stitched
    stitched                  = NUMORPHSTITCH.out.stitched
    NM_variable               = NUMORPHSTITCH.out.NM_variable

}
