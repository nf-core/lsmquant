<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/nf-core-lsmquant_logo_dark.png">
    <img alt="nf-core/lsmquant" src="docs/images/nf-core-lsmquant_logo_light.png">
  </picture>
</h1>

[![GitHub Actions CI Status](https://github.com/nf-core/lsmquant/actions/workflows/nf-test.yml/badge.svg)](https://github.com/nf-core/lsmquant/actions/workflows/nf-test.yml)
[![GitHub Actions Linting Status](https://github.com/nf-core/lsmquant/actions/workflows/linting.yml/badge.svg)](https://github.com/nf-core/lsmquant/actions/workflows/linting.yml)[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/lsmquant/results)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A524.10.5-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-3.3.2-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/3.3.2)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/nf-core/lsmquant)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23lsmquant-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/lsmquant)[![Follow on Bluesky](https://img.shields.io/badge/bluesky-%40nf__core-1185fe?labelColor=000000&logo=bluesky)](https://bsky.app/profile/nf-co.re)[![Follow on Mastodon](https://img.shields.io/badge/mastodon-nf__core-6364ff?labelColor=FFFFFF&logo=mastodon)](https://mstdn.science/@nf_core)[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)
![HiRSE Code Promo Badge](https://img.shields.io/badge/Promo-8db427?style=plastic&label=HiRSE&labelColor=005aa0&link=https%3A%2F%2Fgo.fzj.de%2FCodePromo)

## Introduction

**nf-core/lsmquant** is a bioinformatics pipeline that performs preprocessing and analysis of light-sheet microscopy images of tissue cleared samples. The pipeline takes 2D single-channel 16-bit `.tif` images as input. The preprocessing consists of intesity adjustment, channel alignment, and tile stitching to reconstruct the 3D image. For mousebrain samples it offers a registration to the Allen Mouse Brain Reference Atlas for precise region annotation. Cell nuclei quantification is perfomed on the nuclear channel by a 3D-Unet.

<div style="text-align: center;">
<img src="docs/images/lsmquant-metromap.svg" alt="lasmquant metromap">
</div>

## Basic workflow

**Preprocessing**

1. Intensity Adjustment
2. Channel Alignment
3. Iterative Stitching

**ARA Registration**

4. ARA Registration subworkflow (optional)
5. Cell Nuclei Quantification

**Full**

1. Preprocessing
2. Nuclei quantification

## Pipeline Summary

The pipeline consists of two major workflows `preprocessing` and the `full` workflow. The `ara-regsitration` is an optional subworkflow that works only for whole mouse brain samples.

### Preprocessing

Preprocessing is performed on raw 2D single-channel 16-bit `.tif` images produced by a light sheet microscope. Three individual steps are performed:

- **Intensity adjustments** to correct for the Gaussian shape of the lightsheet and intensity differences between adjacent tiles
- **Image channel alignment** using a 2D rigid approach or a nonlinear 3D approach using Elastix.
- **Image tile stitching** via an iterative 2D stitching approach by calculating z displacements and xy translations using phase correlation and SIFT.

### Full

Quantification of cell-nuclei is performed using a 3D-Unet. It is performed on the nuclear channel only, assuming that the corresponding image file names contain the pattern `C1`.

### ARA Registration

Optional registration to the Allen Reference Atlas (ARA) for functional brain region annotation can be perfomed before segmentation.
This includes the following two steps:

- Downsampling of the high resolution stitched images
- Registration to the ARA

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

To run the pipeline you need to provide a samplesheet with your data in the following structure:

`samplesheet.csv`

```csv
sample_id,img_directory,parameter_file
TEST1,path/to/image-files,path/to/parameter/file.csv
```

The parameter csv file includes sample specific parameters that are used for processing the given data. It needs to follow a specific structure.

Please get the basic template file [here](../assets/params_template_lsmquant.csv).
`parametersheet.csv`

Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run nf-core/lsmquant \
   -profile <docker/singularity/.../institute> \
   --input <samplesheet.csv> \
   --outdir <OUTDIR> \
   --stage <stage>
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/lsmquant/usage) and the [parameter documentation](https://nf-co.re/lsmquant/parameters).

## Pipeline output

To see the results of an example test run with a full size dataset refer to the [results](https://nf-co.re/lsmquant/results) tab on the nf-core website pipeline page.
For more details about the output files and reports, please refer to the
[output documentation](https://nf-co.re/lsmquant/output).

## Credits

nf-core/lsmquant was originally written by [Carolin Schwitalla](https://github.com/CaroAMN) at the Quantitative Biology Center Tuebingen ([QBiC](https://www.info.qbic.uni-tuebingen.de/)).

The pipeline is mainly based on the NuMorph (Nuclear-Based Morphometry) toolbox developed by Krupa et al., 2021.

> **NuMorph: Tools for cortical cellular phenotyping in tissue-cleared whole-brain images**
>
> Krupa O, Fragola G, Hadden-Ford E, Mory JT, Liu T, Humphrey Z, Rees BW, Krishnamurthy A, Snider WD, Zylka MJ, Wu G, Xing L, Stein JL.
>
> Cell Rep. 2021 Oct 12, doi: [10.1016/j.celrep.2021.109802](https://doi.org/10.1016%2Fj.celrep.2021.109802)

We thank the following people for their extensive assistance in the development of this pipeline:

[Matthias Hörtenhuber](https://github.com/mashehu)\
[Famke Bäuerle](https://github.com/famosab)\
[Mark Polster](https://github.com/mapo9)\
[Susi Jo](https://github.com/SusiJo)\
[Luis Kuhn Cuellar](https://github.com/luiskuhn)\
[Daniel Straub](https://github.com/d4straub)
[Tatiana Woller](https://github.com/tatianawoller)\
[Niklas Grote](https://github.com/HomoPolyethylen)\
Jason Stein\
Felix Kyere\
Ian Curtin

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#lsmquant` channel](https://nfcore.slack.com/channels/lsmquant) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use nf-core/lsmquant for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
