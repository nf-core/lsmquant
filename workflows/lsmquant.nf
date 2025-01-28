/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { NUMORPHINTENSITY       } from '../modules/local/numorphintensity'
include { NUMORPHALIGN           } from '../modules/local/numorphalign'
include { NUMORPHSTITCH          } from '../modules/local/numorphstitch'
include { NUMORPHRESAMPLE        } from '../modules/local/numorphresample'
include { NUMORPHREGISTER        } from '../modules/local/numorphregister'
include { BASICPY                } from '../modules/nf-core/basicpy'


include { paramsSummaryMap       } from 'plugin/nf-validation'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_lsmquant_pipeline'
//include { NUMORPHPREPROCESSING   } from '../subworkflows/local/numorphpreprocessing'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/




workflow LSMQUANT {

    take:
    //ch_input_dir        // Channel: /path/to/input directory
    //ch_parameter_file   // Channel: /path/to/parameter file
    //ch_sample_name      // Channel: sample name
    sample_data
    


    main:

    ch_versions = Channel.empty()
    //ch_input_dir = Channel.fromPath(params.input, type: 'dir', checkIfExists: true)
    //ch_parameter_file = Channel.fromPath(params.parameter_file )
    //ch_sample_name = Channel.value(params.sample_name)
    

        
    

 
    //Run workflow steps based on parameter input values
    //if (params.stage == 'intensity') {
      //  NUMORPHINTENSITY(ch_input_dir, ch_parameter_file, ch_sample_name)

    //}
    //if (params.stage == 'basicpy') {
    //    BASICPY()

   // }
    
    if (params.stage == 'preprocess') {

        NUMORPHINTENSITY (sample_data)
        def intensity_out = NUMORPHINTENSITY.out

        //sample_data
        //    .join(intensity_out.adj_params_mat)
        //    .join(intensity_out.path_table_mat)
         //   .join(intensity_out.thresholds_mat)
         //   .join(intensity_out.NM_variables)
        //    .map { meta, img_directory, parameter_file, adj_params_mat, path_table_mat, thresholds_mat, NM_variables ->
        //        meta + [
         //           img_directory: img_directory,
         //           parameter_file: parameter_file,
         //           adj_params_mat: adj_params_mat,
         //           path_table_mat: path_table_mat,
         //           thresholds_mat: thresholds_mat,
         //           NM_variables: NM_variables
         //       ]
          //      tuple(meta, img_directory, parameter_file, adj_params_mat, path_table_mat, thresholds_mat, NM_variables)
          //  }
  
        NUMORPHALIGN (
            sample_data,
            intensity_out.adj_params_mat,
            intensity_out.path_table_mat,
            intensity_out.thresholds_mat,
            intensity_out.NM_variables
        )
        def align_out = NUMORPHALIGN.out

        
   
        NUMORPHSTITCH (
            sample_data,
            align_out.alignment_table_mat,
            align_out.z_displacement_align_mat,
            align_out.path_table_mat,
            intensity_out.thresholds_mat,
            intensity_out.adj_params_mat,
            align_out.NM_variables
            )
    
        def stitch_out = NUMORPHSTITCH.out

        
    }

    
    
    
    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_pipeline_software_mqc_versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    
   
    
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
