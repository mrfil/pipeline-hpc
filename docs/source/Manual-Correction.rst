.. _Manual-Correction :

-----------------
Manual-Correction
-----------------

If you want to re-run the pipeline with manually corrected FreeSurfer output,
please make a copy of the original data and then replace the FreeSurfer directory
in the bids/derivatives folder of your project.

You can then re-run a portion of the pipeline with the relevant arguments supplying
your manually corrected FreeSurfer reconstructions:

`QSIPrep <https://qsiprep.readthedocs.io/en/latest/usage.html#Options%20for%20reconstructing%20qsiprep%20outputs>`_ : --freesurfer-input /path/to/bids/derivatives/freesurfer
`fMRIPrep <https://fmriprep.org/en/stable/usage.html#Specific%20options%20for%20FreeSurfer%20preprocessing>`_ : --fs-subjects-dir /path/to/bids/derivatives/freesurfer
