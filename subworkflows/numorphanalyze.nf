
include { NUMORPHRESAMPLE   } from '../../../modules/local/numorphresample'
include { NUMORPHREGISTER   } from '../../../modules/local/numorphregister'


workflow  {
    
    take:
    ch_input_dir        // Channel: /path/to/input directory
    ch_parameter_file   // Channel: /path/to/parameter file
    ch_sample_name      // Channel: sample name

    main:
    ch_versions = Channel.empty()
    ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
    ch_parameter_file = Channel.fromPath(params.parameter_file )
    ch_sample_name = Channel.value(params.sample_name)


    NUMORPHRESAMPLE (
        ch_input_dir,
        stitch_out.stitched,
        stitch_out.stitch_variables,
        stitch_out.NM_variables,
        ch_parameter_file,
        ch_sample_name
    )
    def resample_out = NUMORPHRESAMPLE.out

     NUMORPHREGISTER (
        ch_input_dir,
        resample_out.resampled,
        resample_out.resample_variables,
        resample_out.stitched,
        resample_out.NM_variables,
        ch_parameter_file,
        ch_sample_name
    )
    def register_out = NUMORPHREGISTER.out

    ch_versions = ch_versions.mix(NUMORPHREGISTER.out.versions.first())
    

}
