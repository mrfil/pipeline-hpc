#!/bin/bash
#
# script for running scfsl nbs calc single subject in container
#
# bind directories for data and toolboxes on run, then specify their paths in this script
# bind working directory for functions
#
# singularity run --bind /local/path/to/workingDirectory:/work,/local/path/to/bctoolbox:/bctoolbox,/shared/mrfil-data/pcamach2/MBB/bids/derivatives/qsirecon:/data matlab-R2019a.sif qsinbs.sh 'sub-MBB001' 'ses-01' 


#cd /work

arg1=$1
arg2=$2

cd /data/$arg1/$arg2/dwi

matlab -nodisplay -nosplash -nodesktop -r "addpath('/home/matlab');addpath('/bctoolbox');addpath('/data');addpath('/work');mrtrix_nbs('$arg1','$arg2');exit;" | tail -n +11
