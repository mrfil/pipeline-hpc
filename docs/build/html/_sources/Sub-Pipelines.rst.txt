.. _Sub-Pipelines :

-------------
Sub-Pipelines
-------------

The main pipeline consists of five sub-pipelines:

* Conversion to BIDS with HeuDiConv + basic quality control with MRIQC
* Functional preprocessing with fMRIPrep + resting-state analyses with XCPEngine
* Diffusion-weighted image preprocessing + reconstruction with QSIPrep
* Automated segmentation of hippocampal subfields with ASHS
* Quantitative susceptibility mapping


BIDS-App containers
###################

Examples of how to run each containerized BIDS-App used in our pipeline


MRIQC
=====

.. code-block:: bash
    docker run -v ${IMAGEDIR}:/imgdir -v ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME} -v ${stmpdir}:/paulscratch -v ${projDir}/bids:/data -v ${projDir}/bids/derivatives/mriqc:/out ${IMAGEDIR}/mriqc-0.16.1.sif /data /out participant --participant-label ${CLEANSUBJECT} --session-id ${CLEANSESSION} -v --no-sub -w /paulscratch

.. code-block:: bash

    singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},${stmpdir}:/paulscratch,${projDir}/bids:/data,${projDir}/bids/derivatives/mriqc:/out ${IMAGEDIR}/mriqc-0.16.1.sif /data /out participant --participant-label ${CLEANSUBJECT} --session-id ${CLEANSESSION} -v --no-sub

fMRIPrep
========

Anatomical and functional image preprocessing

.. code-block:: bash

    docker exec -v ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME} -v $IMAGEDIR/license.txt:/opt/freesurfer/license.txt -v $TMPSING:/paulscratch -v ${projDir}:/datain $IMAGEDIR/fmriprep-v21.0.0.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} -w /paulscratch --fs-license-file /opt/freesurfer/license.txt

.. code-block:: bash

    singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-v21.0.0.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} -w /paulscratch --fs-license-file /opt/freesurfer/license.txt

*If you do not have fMRI data, use the --anat-only argument*

.. code-block:: bash

    docker exec -v ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME} -v $IMAGEDIR/license.txt:/opt/freesurfer/license.txt -v $TMPSING:/paulscratch -v ${projDir}:/datain $IMAGEDIR/fmriprep-v21.0.0.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} --anat-only -w /paulscratch --fs-license-file /opt/freesurfer/license.txt

.. code-block:: bash

    singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-v21.0.0.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} --anat-only -w /paulscratch --fs-license-file /opt/freesurfer/license.txt


XCPEngine
=========

Correlation-based resting-state functional connectivity analysis in multiple atlases.
Amplitude of Low Frequency Fluctuations (ALFF) and regional homogeneity (REHO) also quantified for each parcellation

QSIPrep
=======

Using the structural images and fieldmaps, we perform diffusion-weighted-image preprocessing and structural connectivity analysis in multiple atlases

Preprocessing

.. code-block:: bash

    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives /data/bids/ --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

.. code-block:: bash

    singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

Reconstruction

Constrained Spherical Deconvolution-based multi-shell multi-tissue w/ SIFT2 via MRtrix3 reconstruction workflow

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec mrtrix_multishell_msmt --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}
    
    #calculate network-based statistics and save NxN matrices from .net
    docker run -v ${scripts}/matlab:/work -v ${scripts}/2019_03_03_BCT:/bctoolbox -v ${projDir}/bids/derivatives/qsirecon:/data ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec mrtrix_multishell_msmt --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}
    
    #calculate network-based statistics and save NxN matrices from .net
    singularity run --cleanenv --bind ${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/qsirecon:/data ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

Generalized q-Sampling imaging via DSI Studio

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec dsi_studio_gqi --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

    #get network-based statistics to a csv from .mat
    docker run -v ${scripts}:/scripts -v ${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datain -W /datain ${IMAGEDIR}/pylearn.sif /scripts/gqimetrics.py


.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec dsi_studio_gqi --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

    #get network-based statistics to a csv from .mat
    singularity run --cleanenv --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datain -W /datain ${IMAGEDIR}/pylearn.sif /scripts/gqimetrics.py

NODDI via AMICO python implementation

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec amico_noddi --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

    #ROI-wise stats       
    docker run -v ${scripts}:/scripts -v ${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datanoddi ${IMAGEDIR}/neurodoc.sif /scripts/noddi_stats.sh "$subject" "$sesname"

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec amico_noddi --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

    #ROI-wise stats       
    singularity run --cleanenv --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datanoddi ${IMAGEDIR}/neurodoc.sif /scripts/noddi_stats.sh "$subject" "$sesname"


