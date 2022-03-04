.. _Main-Pipeline :

-------------
Main Pipeline
-------------

To facilitate reproducible analyses, we developed a Singularity container-based processing pipeline for MRI modalities commonly collected at our site (BIC + CI-AIC).
These are compatible with the Brain Imaging Data Structure (BIDS) specification and are designed for deployment to high-performance computing clusters.
This pipeline uses internally and externally developed BIDS-Apps converted from Docker images to Singularity images or built directly as Singularity images (see :ref:`the installation guide<Install>`). 
The pipeline consists of an initial conversion and quality control metric generation step, followed by four steps run in parallel with the Slurm Workload Manager (SchedMD LLC, Lehi, Utah, USA).
*Note that these scripts can also be run on Linux systems not managed by Slurm.*


Inputs
******
The pipeline assumes data to be in a DICOM format, with some uniformity of organization based on the project/subject/session/series structure.

Outputs
*******

DICOMs are converted to BIDS-compatible NIFTIs and sidecar JSONs using HeuDiConv. These are used with BIDS-Apps to produce standard preprocessing derivatives,
along with resting-state functional connectivity analyses and structural connectivity analyses.

Preprocessing derivatives
=========================

desc here

Analyses derivatives
====================

desc here


Metrics:
========

Wherever possible, we combine quantifiable metrics from each modality to a common .csv with variable names that are more data science-friendly.


Network-based statistics
------------------------
CSD + SIFT2
Ends with SC = SIFT2 CSD Structural connectivity network-based measures

https://qsiprep.readthedocs.io/en/latest/reconstruction.html#mrtrix-multishell-msmt - docs on 	CSD reconstruction method + SIFT2 tractogram filtering
https://sites.google.com/site/bctnet/ - Matlab/python toolbox for nbs calculation
	
	These are more difficult to interpret in network science frameworks due to the weighting 	scheme and our acquisition sampling scheme for DWI, probably not something to use in main 	analyses yet.

Example:


GlobalEfficiencyAAL116SC
GlobalEfficiencyBrainnetome246SC
GlobalEfficiencyPower264SC


GQI
starts with atlas _ network based measure = GQI-based Structural connectivity network-based measures

https://qsiprep.readthedocs.io/en/latest/reconstruction.html#dsi-studio-gqi - docs on GQI 	reconstruction method 
https://sites.google.com/site/bctnet/ - Matlab/python toolbox for nbs calculation used by the DSI Studio code employed in QSIPrep
	
GQI is a model-free diffusion reconstruction method applicable for most DWI sampling schemes and better addresses the crossing fibres problem and other limitations of DTI. For more details, see Frank’s documentation: https://sites.google.com/a/labsolver.org/dsi-studio/Manual/diffusion-mri-indices


Example:

aal116_count_end_clustering_coeff_average_weighted
aal116_count_end_density
aal116_count_end_global_efficiency_weighted


RSFC

No underscores, starts with network-based measure, then atlas, ends with confound regression method = resting-state functional connectivity network-based measures	
https://xcpengine.readthedocs.io/overview.html#step-2-choose-configure-a-pipeline-design - 	info on confound regression methods used (36P, 36P + despike, 36P + Power Scrub [this fails for a number of participants due to high motion], ICA-AROMA)
https://xcpengine.readthedocs.io/config/streams/fc.html

https://sites.google.com/site/bctnet/ - Matlab/python toolbox for nbs calculation


Example:
	
GlobalEfficiencyaal116aroma
GlobalEfficiencyaal116despike
GlobalEfficiencyaal116fc36p
GlobalEfficiencyaal116scrub


Quality Control Metrics
-----------------------

fMRI + M2PRAGE
https://mriqc.readthedocs.io/en/latest/measures.html
	
names appended with _t1w for MP2RAGE, _rest should be in most of these resting-state fMRI metric names in csv

DWI
https://qsiprep.readthedocs.io/en/latest/preprocessing.html#quality-control-data

RSFC confound regression method + overall resting-state processing pipeline metrics
https://xcpengine.readthedocs.io/qualitycontrol.html


Preparing your dataset for sharing
==================================

An optional script is included in this repository for running pydeface on your BIDS dataset.
This facilitates sharing data on databanks by removing identifying facial features from each image.
You must specify which image modalities (e.g. T1w, T2w, FLAIR, etc.) to deface when running the script:

.. code-block:: bash

    ./singularity_deface_bids.sh -p <Project ID> -m <"T1w T2w FLAIR ..."> -b <base directory for pipeline> -t <version of pipeline>