.. _About :

-----
About
-----

The BIDS format and BIDS-App pipelines
--------------------------------------
This pipeline and its sub-pipelines are designed to convert DICOM data to the Brain Imaging Data Structure (BIDS)
and leverage BIDS-Apps to perform quality control, preprocessing, and automated analyses on high-performance computing clusters.
The main Pipeline takes 3T brain MRI DICOMs and outputs BIDS sourcedata, preprocessed derivatives, resting-state functional connectivity and structural connectivity matrices, basic network-based statistics, and hippocampal subfield segmentation via BIDS App Singularity containers. 
While developed for Slurm control systems, the shell scripts here should be compatible with CentOS-derived Linux clusters.

Our :ref:`Installation Guide <Install>`_ provides details on installing the following requirements:

.. hlist::
    * Singularity BIDS apps (HeuDiConv, MRIQC, fMRIPrep, xcpEngine, QSIprep) 
    * Singularity image of Matlab R2019a (how to: https://github.com/mathworks-ref-arch/matlab-dockerfile) 
    * Singularity image of Ubuntu with JQ installed Singularity image of Python3 (Based on Docker python/3.9.0) 
    * Singularity image of Docker HTML to PDF (https://github.com/pinkeen/docker-html-to-pdf) 
    * Brain Connectivity Toolbox for Matlab (https://sites.google.com/site/bctnet/Home/functions/BCT.zip?attredirects=0) 
    * xcpEngine dsn files (https://github.com/PennBBL/xcpEngine/tree/master/designs) 
    * ASHS (https://sites.google.com/site/hipposubfields/) 
    * bidsphysio (https://github.com/cbinyu/bidsphysio)
