#!/bin/bash
#
# script for running ndi qsm
#
# bind directories for data and toolboxes on run, then specify their paths in this script
# bind working directory for functions
#
# singularity run --bind /local/path/to/ndi:/ndi,/path/to/IMAs:/datain,scripts/matlab:/scripts matlab-R2019a.sif /scripts/ndi_qsm.sh {intensity}


matlab -nodisplay -nosplash -nodesktop -r "addpath('/home/matlab');addpath(genpath('/ndi'));addpath('/datain');ndi_from_dicom_v1('/datain','/datain/ndi_out/',${intensity});exit;" | tail -n +11
