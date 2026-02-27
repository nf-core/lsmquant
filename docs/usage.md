# nf-core/lsmquant: Usage

## Introduction

## Samplesheet input

You will need to create a samplesheet with information about the samples you would like to analyze before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row as shown in the examples below.

```bash
--input '[path to samplesheet file]'
```

Samplesheet header:

```csv title="samplesheet.csv"
sample_id,img_directory,parameter_file
```

| Column           | Description                                                     |
| ---------------- | --------------------------------------------------------------- |
| `sample_id`      | Custom sample name.                                             |
| `img_directory`  | Full path to the image directory for the sample.                |
| `parameter_file` | Full path to the corresponding parameter_file for the analysis. |

### Single or Multiple samples

The pipeline always takes the samplesheet as input. For processing only one sample, you would only specify one sample in the samplesheet. The samplesheet below shows an example for processing multiple samples with the pipeline.

```csv title="samplesheet.csv"
sample_id,img_directory,parameter_file
TEST1,/path/to/TEST1/,/path/to/params_TEST1.csv
TEST2,/path/to/TEST2/,/path/to/params_TEST2.csv
TEST3,/path/to/TEST3/,/path/to/params_TEST3.csv
```

If different samples should be processed with the same parameter set specified in the `params.csv`, you can use the same `params.csv` for different samples.

### Parameter file

In the `parameter.csv` file you should specify processing parameters for your data and pipeline run. The `CSV` contains specific fields that are needed for the processes to run and only the value column should be modified. You can download a template parameter file [here](../assets/params_template_lsmquant.csv).
An example row is displayed below:

```csv title="params.csv"
Parameter,Value
z_window,5
```

The individual parameters are explained in the following section.

### Analysis specific parameters

This section describes every parameter that can be set in the `parameter.csv`. In order for the pipeline to run correctly all named parameters need to be present in the parameter file and its recommended to use the [provided parameter file]((../assets/params_template_lsmquant.csv). Every parameter has a default value that will be set if not otherwise defined in the `parameter.csv`.

#### Sample specific information

|                        |                                                                                                                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `group`                | Group name/id.**Default: TEST;WT;R1**                                                                                                                                    |
| `channel_num`          | Channel id.**Default: C01;C00**                                                                                                                                          |
| `markers`              | Name of present markers.**Default: topro;ctip2**                                                                                                                         |
| `position_exp`         | 1x3 string of regular expression specifying image row(y), column(x), slice(z).**Default: [\d*;\d*];Z\d**                                                                 |
| `resolution`           | Image resolution in um/voxel.**Default: ''**                                                                                                                             |
| `orientation`          | 1x3 string specifying sample orientation. **Default: ail**                                                                                                               |
| `hemisphere`           | "left","right","both","none". **Default: left**                                                                                                                          |
| `use_processed_images` | false or name of sub-directory in output directory (i.e. aligned, stitched...); Load previously processed images in output directory as input images. **Default: false** |
| `ignore_markers`       | completely ignore marker from processing steps. **Default: Auto**                                                                                                        |
| `save_images`          | true or false; Save images during processing. Otherwise only parameters will be calculated and saved. **Default: true**                                                  |
| `save_samples`         | true, false; Save sample results for each major step. **Default: true**                                                                                                  |

#### Parameters for adjusting intensities

|                             |                                                                                                                                                                                                    |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `adjust_intensity`          | true, update, false; Whether to calculate and apply any of the following intensity adjustments. Intensity adjustment measurements should typically be performed on raw images. **Default: update** |
| `darkfield_intensity`       | 1xn_channels; Constant darkfield intensity value (i.e. average intensity of image with nothing present). **Default: 101**                                                                          |
| `adjust_tile_shading`       | basic, manual, false; Can be 1xn_channels. Perform shading correction using BaSIC algorithm or using manual measurements from UMII microscope. **Default: basic**                                  |
| `adjust_tile_position`      | true, false; Can be 1xn_channels. Normalize tile intensities by position using overlapping regions. **Default: true**                                                                              |
| `adjust_tile_position`      | true, false; Can be 1xn_channels. Normalize tile intensities by position using overlapping regions. **Default: true**                                                                              |
| `update_intensity_channels` | integers; Update intensity adjustments only to certain channels                                                                                                                                    |

Manual tile shading correction (specific for LaVision Ultramicroscope II):
| | |
|-----|------|
| `single_sheet` | true, false; Whether a single sheet was used for acquisition |
| `ls_width` | 1xn_channels integer. Light sheet width setting for UltraMicroscope II as percentage. **Default: 50** |
| `laser_y_displacement` | [-0.5,0.5]; Displacement of light-sheet along y axis. Value of 0.5 means light-sheet center is positioned at the top of the image. **Default: 0** |

Shading correction using BaSiC:
| | |
|-----|------|
| `sampling_frequency` | [0,1]; The proportion of images to sample for BaSiC. These sampled images will be used to compute shading correction and flatfield for the entire dataset. Setting to 1 means use all images. **Default: 0.2** |
| `shading_correction_tiles` | Integer vector. Subset tile positions for calculating shading correction (row major order). It's recommended that bright regions are avoided |
| `shading_smoothness` | numeric >= 1; Factor for adjusting smoothness of shading correction. Greater values lead to a smoother flatfield image. **Default: 2** |
| `shading_intensity` | numeric >= 1; Factor for adjusting the total effect of shading correction. Greater values lead to a smaller overall adjustment. **Default: 1** |

#### Parameters for channel alignment

|                     |                                                                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `channel_alignment` | true, update, false; Channel alignment. **Default: true**                                                                       |
| `align_method`      | elastix, translation; Channel alignment by rigid, 2D translation or non-rigid B-splines using elastix. **Default: translation** |
| `align_tiles`       | Option to align only certain stacks and not all stacks. Row-major order. **Default: ''**                                        |
| `align_channels`    | Option to align only certain channels (set to >1). **Default: ''**                                                              |
| `align_slices`      | Option to align only certain slice ranges. Set as cell array for non-continuous ranges (i.e. {1:100,200:300}). **Default: ''**  |

Z alignment parameters (for stitching and align by translation)
| | |
| ------------- | ---------- |
| `update_z_adjustment` | true, false; Update z adjustment steps with new parameters. Otherwise pipeline will search for previously calculated parameters. **Default: false** |
| `z_positions` | integer or numeric; Sampling positions along adjacent image stacks to determine z displacement. If <1, uses fraction of all images. Set to 0 for no adjustment, only if you're confident tiles are aligned along z dimension. **Default: 0.01** |
| `z_window` | integer; Search window for finding corresponding tiles (i.e. +/-n z positions). **Default: 5** |
| `z_initial` | 1xn_channels-1 integer; Predicted initial z displacement between reference channel and secondary channel. **Default: 0** |

For align by translation
| | |
| ------------- | ---------- |
| `align_stepsize` | integer; Only for alignment by translation. Number of images sampled for determining translations. Images in between are interpolated. **Default: 5** |
| `only_pc` | true, false; Use only phase correlation for registration. This gives only a quick estimate for channel alignment. **Default: false** |

Specific for align by elastix
| | |
| ------------- | ---------- |
| `align_chunks` | Only for alignment by elastix. Option to align only certain chunks. **Default: ''** |
| `elastix_params` | 1xn_channels-1 string; Name of folders containing elastix registration parameters. Place in /supplementary_data/elastix_parameter_files/channel_alignment. **Default: 32_bins** |
| `pre_align` | true, false; (Experimental) Option to pre-align using translation method prior to non-linear registration. **Default: false** |
| `max_chunk_size` | integer; Chunk size for elastix alignment. Decreasing may improve precision but can give spurious results. **Default: 300** |
| `chunk_pad` | integer; Padding around chunks. Should be set to value greater than the maximum expected translation in z. **Default: 30** |
| `mask_int_threshold` | numeric; Mask intensity threshold for choosing signal pixels in elastix channel alignment. Leave empty to calculate automatically. **Default: ''** |
| `resample_s` | 1x3 integer. Amount of downsampling along each axis. Some downsampling, ideally close to isotropic resolution, is recommended. **Default: 3;3;1** |
| `hist_match` | 1xn_channels-1 integer; Match histogram bins to reference channel? If so, specify number of bins. Otherwise leave empty or set to 0. This can be useful for low contrast images. **Default: 64** |

#### Stitching parameters

Specific for iterative 2D stitching
| | |
| ------------- | ---------- |
| `stitch_images` | true, update, false; 2D iterative stitching. **Default: true** |
| `sift_refinement` | true, false; Refine stitching using SIFT algorithm (requires vl_fleat toolbox). **Default: true** |
| `load_alignment_params` | true, false; Apply channel alignment translations during stitching. **Default: true** |
| `overlap` | 0:1; overlap between tiles as fraction. **Default: 0.20** |
| `stitch_sub_stack` | z positions; If only stitching a certain z range from all the images. **Default: ''** |
| `stitch_sub_channel` | channel index; If only stitching certain channels. **Default: ''** |
| `stitch_start_slice` | z index; Start stitching from specific position. Otherwise this will be optimized. **Default: ''** |
| `blending_method` | sigmoid, linear, max. **Default: sigmoid** |
| `sd` | 0:1; Recommended: ~0.05. Steepness of sigmoid-based blending. Larger values give more block-like blending. **Default: 0.05** |
| `border_pad` | integer >= 0; Crops borders during stitching. Increase if images shift significantly between channels to prevent zeros values from entering stitched image. **Default: 25** |

#### Postprocessing parameters

These are applied during the stitching process after the image has been merged.

Parameters for rescale intensities

|                       |                                                                                                      |
| --------------------- | ---------------------------------------------------------------------------------------------------- |
| `rescale_intensities` | true, false; Rescaling intensities and applying gamma. **Default: false**                            |
| `lowerThresh`         | 1xn_channels numeric; Lower intensity for rescaling. **Default: ''**                                 |
| `signalThresh`        | 1xn_channels numeric; Rough estimate for minimal intensity for features of interest. **Default: ''** |
| `upperThresh`         | 1xn_channels numeric; Upper intensity for rescaling. **Default: ''**                                 |
| `Gamma`               | 1xn_channels numeric; Gamma intensity adjustment. **Default: ''**                                    |

Parameters for background subtraction
| | |
| --------------------------- | -------------- |
| `subtract_background` | true, false. Subtract background (similar to Fiji's rolling ball background subtraction).**Default: false** |
| `nuc_radius` | numeric >= 1; Max radius of cell nuclei along x/y in pixels. Required also for DoG filtering.**Default: 13** |

Difference-of-Gaussian filter
| | |
| --------------------------- | -------------- |
| `DoG_img` | true,false; Apply difference of gaussian enhancement of blobs.**Default: false** |
| `DoG_minmax` | 1x2 numeric; Min/max sigma values to take differences from.**Default: 0.8;2** |
| `DoG_factor` | [0,1]; Factor controlling amount of adjustment to apply. Set to 1 for absolute DoG.**Default: 1** |

Smoothing filters
| | |
| --------------------------- | -------------- |
| `smooth_img` | 1xn_channels, "gaussian", "median", "guided". Apply a smoothing filter.**Default: false** |
| `smooth_sigma` | 1xn_channels numeric; Size of smoothing kernel. For median and guided filters, it is the dimension of the kernel size. **Default: ''** |

Update sample orientation
| | |
| --------------------------- | -------------- |
| `flip_axis` | "none", "horizontal", "vertical", "both"; Flip image along horizontal or vertical axis.**Default: none** |
| `rotate_axis` | 0, 90 or -90; Rotate image.**Default: 0** |

|                   |                                                                                            |
| ----------------- | ------------------------------------------------------------------------------------------ |
| `resample_images` | true, update, false; Perform image resampling. **Default: true**                           |
| `register_images` | true, update, false; Register image to reference atlas. **Default: true**                  |
| `count_nuclei`    | true, update, false; Count cell nuclei or other blob objects.**Default: true**             |
| `classify_cells`  | true, update, false; Classify cell-types for detected nuclei centroids. **Default: false** |

#### Resampling and annotations parameters

|                         |                                                                                                                |
| ----------------------- | -------------------------------------------------------------------------------------------------------------- |
| `resample_resolution`   | Isotropic resample resolution. This is also the resolution at which registration is performed. **Default: 25** |
| `resample_channels`     | Resample specific channels. If empty, only registration channels will be resampled. **Default: ''**            |
| `use_annotation_mask`   | true, false; Use annotation mask for cell counting. **Default: false**                                         |
| `annotation_mapping`    | atlas, image; Specify whether annotation file is mapped to the atlas or light-sheet image. **Default: atlas**  |
| `annotation_file`       | File for storing structure annotation data. **Default: ''**                                                    |
| `annotation_resolution` | Isotropic resolution of the annotation file. Only needed when mapping is to the image. **Default: 25**         |

#### Registration parameters

|                             |                                                                                                                                                         |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `registration_direction`    | atlas_to_image, image_to_atlas; Direction to perform registration. **Default: atlas_to_image**                                                          |
| `registration_parameters`   | default, points, or name of folder containing elastix registration parameters in /data/elastix_parameter_files/atlas_registration. **Default: default** |
| `registration_channels`     | integer; Which light-sheet channels to register. Can select more than 1. **Default: 1**                                                                 |
| `registration_prealignment` | image. Pre-align multiple light-sheet images by rigid transformation prior to registration. **Default: image**                                          |
| `atlas_file`                | ara_nissl_25.nii and/or average_template_25.nii and/or a specific atlas .nii file in /data/atlas. **Default: 3Drecon-ADMBA-P4_atlasVolume.nii**         |
| `use_points`                | Use points during registration. **Default: false**                                                                                                      |
| `prealign_annotation_index` | Not used. **Default: ''**                                                                                                                               |
| `points_file`               | Name of points file to guide registration. **Default: ''**                                                                                              |
| `save_registered_images`    | Whether to save registered images. **Default: true**                                                                                                    |
| `mask_cerebellum_olfactory` | Remove olfactory bulbs and cerebellum from atlas ROI. **Default: true**                                                                                 |

#### Nuclei Detection

|                 |                                                       |
| --------------- | ----------------------------------------------------- |
| `count_method`  | **Default: 3dunet**                                   |
| `int_threshold` | Minimum intensity of positive cells. **Default: 200** |

3-DUnet specific parameters
| | |
| --------------------------- | -------------- |
| `model_file` | Model file name. **Default: ''** |
| `gpu` | Cuda visible device index. **Default: 0** |
| `chunk_size` | Chunk size in voxels. **Default: [112, 112, 32]** |
| `chunk_overlap` | Overlap between chunks in voxels. **Default: [16, 16, 8]** |
| `pred_threshold` | Prediction threshold. **Default: 0.5** |
| `normalize_intensity` | Whether to normalize intensities using min/max. **Default: true** |
| `resample_chunks` | Whether to resample image to match trained image resolution. Note: increases computation time. **Default: false** |
| `tree_radius` | Pixel radius for removing centroids near each other. **Default: 2** |
| `acquired_img_resolution` | Resolution of acquired images. **Default: [0.75, 0.75, 4]** |
| `trained_img_resolution` | Resolution of images the model was trained on. **Default: [0.75, 0.75, 2.5]** |
| `measure_coloc` | Measure intensity of co-localized channels. **Default: false** |
| `n_channels` | Number of channels. **Default: ''** |
| `use_mask` | Use mask. **Default: false** |
| `mask_file` | Mask file. **Default: ''** |
| `resample_resolution` | Resolution of resampled images. **Default: 25** |

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run nf-core/lsmquant --input ./samplesheet.csv --outdir ./results -profile docker -work-dir ./work
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

For this pipeline it is recommended to specify the location of the work directory as well with `-work-dir`. The directory will contain any nextflow working files which includes all in- and output files. The work directory will be larger than the input sample size. If you don't specify a location, the work directory will be created in the location from where the pipeline got started.

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

> [!WARNING]
> Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), other infrastructural tweaks (such as output directories), or module arguments (args).

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run nf-core/lsmquant -profile docker -params-file params.yaml
```

with:

```yaml title="params.yaml"
input: './samplesheet.csv'
outdir: './results/'
<...>
```

You can also generate such `YAML`/`JSON` files via [nf-core/launch](https://nf-co.re/launch).

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull nf-core/lsmquant
```

### Reproducibility

It is a good idea to specify the pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [nf-core/lsmquant releases page](https://github.com/nf-core/lsmquant/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future. For example, at the bottom of the MultiQC reports.

To further assist in reproducibility, you can use share and reuse [parameter files](#running-the-pipeline) to repeat pipeline runs with the same settings without having to write out a command with every single parameter.

> [!TIP]
> If you wish to share such profile (such as upload as supplementary material for academic publications), make sure to NOT include cluster specific paths to files, nor institutional specific profiles.

## Core Nextflow arguments

> [!NOTE]
> These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen)

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

> [!IMPORTANT]
> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to check if your system is supported, please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer environment.

- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters
- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://charliecloud.io/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow ` 24.03.0-edge` or later).
- `conda`
  - This profile is not available for nf-core/lsmquant

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customize the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources request (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases, you may wish to change the container or conda environment used by a pipeline steps for a particular tool. By default, nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However, in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

To learn how to provide additional arguments to a particular tool of the pipeline, please see the [customising tool arguments](https://nf-co.re/docs/usage/configuration#customising-tool-arguments) section of the nf-core website.

### nf-core/configs

In most cases, you will only need to create a custom config as a one-off but if you and others within your organization are likely to be running nf-core pipelines regularly and need to use the same settings regularly it may be a good idea to request that your custom config file is uploaded to the `nf-core/configs` git repository. Before you do this please can you test that the config file works with your pipeline of choice using the `-c` parameter. You can then create a pull request to the `nf-core/configs` repository with the addition of your config file, associated documentation file (see examples in [`nf-core/configs/docs`](https://github.com/nf-core/configs/tree/master/docs)), and amending [`nfcore_custom.config`](https://github.com/nf-core/configs/blob/master/nfcore_custom.config) to include your custom profile.

See the main [Nextflow documentation](https://www.nextflow.io/docs/latest/config.html) for more information about creating your own configuration files.

If you have any questions or issues please send us a message on [Slack](https://nf-co.re/join/slack) on the [`#configs` channel](https://nfcore.slack.com/channels/configs).

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```

## Methods description

This section provides a detailed explanation for the individual processing steps, based on the original NuMorph toolbox [publication](https://www.sciencedirect.com/science/article/pii/S2211124721012626?via%3Dihub).

### Intensity adjustment

This step performs two types of intensity adjustments to the raw images before tile stitching:

- Shading correction (Option: BaSiC, manual)

- Normalizing intensities between tile stacks

**Shading correction by using BaSiC**

The Gaussian shape of the light-sheet causes uneven illumination and shading across the y-axis. To correct these effects the tool BaSiC (MATLAB tool for retrospective shading correction) is used. A fraction of all images is used to estimate the flatfield for each channel. Every image is then divided by the estimated flatfield to normalize illumination. With the parameter `sampling_frequency`, the fraction of images to use for BaSiC, is specified as a decimal. For example setting the `sampling_frequency` to `0.1`, `10%` of all images will be used to estimate the flatfield.

**Normalizing intensities between tile stacks**

Photo-bleaching and light attenuation can cause differences in brightness between tile stacks. To account for that, the differences in intensities are measured in overlapping regions (vertical and horizontal) of adjacent tiles. Next the adjustment factor $t^{adj}$, based on the 95th percentile of pixel intensities in overlapping regions, is calculated. For this 5% of all images are used.
The final adjustment is applied with the following formula:

$$
I^{adj}(x,y) = (I(x,y) - D) \cdot t^{adj}(x,y) + D
$$

- $I(x,y)$: Original measured image intensities at tile position (x,y)
- $I^{adj}(x,y)$: Adjusted image intensities at tile position (x,y)
- $t^{adj}$: Adjustment factor based on the 95th percentile of intensity differences
- $D$: Darkfield intensity (constant value based on the 5th percentile of pixel intensities across all measured regions)

### Channel alignment

Drifts in sample positions and stage can occur during imaging multiple channels causing spatial misalignment. To correct for these shifts between channels two methods can be chosen:

- Rigid 2D translation: `align_method: translation{:groovy}`
- Nonlinear 3D registration using Elastix : `align_method: elastix{:groovy}`

Both methods expect the nuclear channel as reference, to which all other immunolabeled channels will be aligned to.

#### Rigid 2D translation

This approach estimates first the relative z displacement between the nuclei reference channel and every other channel. Within each tile, a number evenly spaced z slices of the reference channel is chosen by the parameter `z_position`. For every z position, phase corelation is calculated between all images from another channel in a search window (set by `z_window`) and summed up.
The z position with the highest image similarity based on intensity correlation defines the inter-channel z displacement

Next, multimodal 2D registration is performed on each slices in the image stack by using MATLAB's Image Processing toolbox, to determine xy translations. Outlier translations are defined as translations that are greater than 3 scaled median absolute deviations within a local window of 10 slices. These outliers are corrected by linear interpolation of adjacent images in the stack.

**Nonlinear 3D registration using Elastix**

To correct for rotations and other drifts for which 2D rigid translation is not sufficient, a nonlinear 3D B-spline registration using Elastix can be applied on individual tiles.

1. **Downsampling**:
   A full tile stack is loaded and downsampled by a factor of 3 in the x/y dimensions to create a nearly isotropic volume and reduce the computation time.
2. **Normalizing intensities**:
   For comparable brightness and contrast, intensity histogram matching is performed across all channels of the stack.

3. **Generation of foreground mask**:
   A mask for the nuclei channel is generated by using a threshold that limits sampling from the background.

4. **Initial global alignment**:
   An initial 3D translational registration to the full stack is applied.

5. **Local rigid alignment**:
   The stack is subdivided into chunks of 300 slices and a rigid 3D registration on each chunk is performed. This step corrects rotational drift and improves the alignment within local regions.

6. **Nonlinear refinement**:
   A nonlinear B-spline registration is performed on each chunk by using an advanced Mattes mutual information metric. This accounts for xy drift along the z axis. The control point grid of the B-spline transformation are set to be sparse along xy compared to z to balance alignment accuracy and computational cost.

### Iterative image stitching

The iterative 2D stitching procedure to assemble the whole image, consists of two main stages:

- Estimation of z correspondence between tile stacks
- Iterative xy alignment and stitching

**Estimation of z correspondence between tile stacks**

To determine optimal z correspondence for adjacent tiles, a sample of evenly spaced images (set with `z_position`) from within a stack are registered to every z position within a image window (set by `z_window`) of a adjacent stack (vertically and horizontally) by phase correlation. Z correspondences are ranked by the amount of peak correlations among the z positions, where the highest count represent the best correspondence. In addition, the difference between the best and the 2nd best z correlation is taken as a weight, indicating the strength of a correspondence (larger difference = stronger correspondence).
Finally this results in 4 matrices for a stack representing pairwise horizontal and vertical z displacements and their corresponding weights. To calculate the final z displacement for each tile a minimum spanning tree is used, where displacements are used as vertices and their weights as edges.

**Iterative xy alignment and stitching**
Stitching process proceeds with iterative alignment in the x–y plane. The starting point for the iterative stitching along the stack is chosen near the middle of the volume. At this position, all tiles contained sufficient signal above background, defined as at least one standard deviation above the darkfield intensity. The initial translations for each tile are computed using phase correlation, providing a robust estimate of relative positioning. These translations are then refined using the Scale-Invariant Feature Transform (SIFT) algorithm, which improves accuracy by matching distinctive image features across overlapping regions. Stitching begins from the top-left tile to maintain consistent positioning and prevent cumulative shifts along the z-axis. Overlapping areas between tiles are blended using a sigmoidal function, ensuring smooth transitions and preserving image contrast. To handle cases where slices lack sufficient tissue content, shifts greater than five pixels compared to the previous iteration are replaced with the previous iteration’s values.

### Nuclei quantification

Images are subdivided into patches of 112 × 112 × 32 voxels with an overlap of 16 × 16 × 8 voxels to reduce boundary artifacts. Each patch is then passed to a modified pretrained 3D‑UNet (based on Çiçek et al., 2016 and Isensee et al., 2018) to predict binary nuclei masks. Individual nuclei are obtained via connected‑component analysis, and centroid coordinates are extracted from these components. To prevent duplicate detections introduced by overlapping patches, centroids located closer than half the overlap to a patch border (< 8 pixels in x/y or < 4 pixels in z) are removed under the assumption they will be captured by the neighboring patch. Remaining centroids across all patches are merged using a kd‑tree nearest‑neighbor search, eliminating duplicates within 1.5 voxels of each other to ensure each nucleus is counted exactly once.
