// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules


include { NUMORPHINTENSITY   } from '../../../modules/local/numorphintensity'
include { NUMORPHALIGN       } from '../../../modules/local/numorphalign'
include { NUMORPHSTITCH      } from '../../../modules/local/numorphstitch'

workflow NUMORPHPREPROCESSING {

    take:
    ch_input_dir        // Channel: /path/to/input directory
    ch_parameter_file   // Channel: /path/to/parameter file
    ch_sample_name      // Channel: sample name
    

    main:

    ch_versions = Channel.empty()
    ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
    ch_parameter_file = Channel.fromPath(params.parameter_file )
    ch_sample_name = Channel.value(params.sample_name)
    //ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
    //ch_parameter_file = Channel.fromPath(params.parameter_file )
    //ch_sample_name = Channel.value(params.sample_name)


    NUMORPHINTENSITY (
        ch_input_dir,
        ch_parameter_file,
        ch_sample_name
    )
    def intensity_out = NUMORPHINTENSITY.out

    NUMORPHALIGN (
        ch_input_dir,
        intensity_out.adj_params_mat,
        intensity_out.path_table_mat,
        intensity_out.thresholds_mat,
        intensity_out.NM_variables,
        ch_parameter_file,
        ch_sample_name
    )
    def align_out = NUMORPHALIGN.out

    NUMORPHSTITCH (
        ch_input_dir,
        align_out.alignment_table_mat,
        align_out.z_displacement_align_mat,
        align_out.path_table_mat,
        intensity_out.thresholds_mat,
        intensity_out.adj_params_mat,
        align_out.NM_variables,
        ch_parameter_file,
        ch_sample_name
    )

    def stitch_out = NUMORPHSTITCH.out

    

    
    ch_versions = ch_versions.mix(NUMORPHSTITCH.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels


    versions = ch_versions                     // channel: [ versions.yml ]
}

