.. _Main-Pipeline :

-------------
Main Pipeline
-------------

To facilitate reproducible analyses, we developed a Singularity container-based processing pipeline for MRI modalities commonly collected at our site (BIC + CI-AIC).
These are compatible with the Brain Imaging Data Structure (BIDS) specification and are designed for deployment to high-performance computing clusters.
This pipeline uses internally and externally developed BIDS-Apps converted from Docker images to Singularity images or built directly as Singularity images (see :ref:`the installation guide <Install>`_). 
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


FSL DTI probabilistic tractography from QSIPrep Preprocessing (Optional)
========================================================================

.. note::
    Requires pre-existing FreeSurfer parcellation and FreeSurfer license.txt
    
    This workflow is intended to run on machines with CUDA 9.1 or CUDA 10.2 compatible GPUs.

*Outputs*

In addition to the fdt_network_matrix produced by probtrackx2 for the masks 
derived from Freesurfer parcellation (generated in sMRIPrep/fMRIPrep),
this sub-pipeline also outputs node-labeled csv files of the NxN streamline-weighted 
and ROI volume-weighted structural connectome.

*Performance*

From testing 30 datasets from 3T 2.0mm isotropic CMRR DWI):

.. list-table:: Benchmark with 3T DWI data
   :widths: 20 20 30 50 20 20 
   :header-rows: 1

   * - Host OS
     - CUDA Version
     - GPU
     - CPU
     - RAM
     - Run time
   * - CentOS
     - 9.1
     - Nvidia Tesla V100 16GB
     - Intel Xeon Gold 6138 2.00GHz (80 threads)
     - 192GB
     - 25-30 minutes
   * - CentOS
     - 10.2
     - Nvidia Tesla V100 16GB
     - Intel Xeon Gold 6138 2.00GHz (80 threads)
     - 192GB
     - 25-30 minutes


Peak GPU memory usage: 13999MiB / 16160MiB

Usage: 

*Docker*

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data ${IMAGEDIR}/qsiprep-v0.15.1.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec reorient_fslstd --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}


.. code-block:: bash
    # Running SCFSL GPU tractography
    docker exec --gpus all -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.2/lib64 \
    -v /path/to/freesurfer/license.txt:/opt/freesurfer/license.txt \
    -v /path/project/bids:/data mrfilbi/scfsl_gpu:0.3.2 /bin/bash /scripts/proc_fsl_connectome_fsonly.sh ${subject} ${session}

*Singularity*

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.15.1.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec reorient_fslstd --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

.. code-block:: bash
    # Running SCFSL GPU tractography
    SINGULARITY_ENVLD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.2/lib64 \
    singularity exec --nv -B /path/to/freesurfer/license.txt:/opt/freesurfer/license.txt,/path/project/bids:/data \
    /path/to/scfsl_gpu-v0.3.2.sif /bin/bash /scripts/proc_fsl_connectome_fsonly.sh ${subject} ${session}
