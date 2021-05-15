#!/bin/bash
#
# sample script for running matlab routines in container
#
# bind directories for data and toolboxes on run, then specify their paths in this script
# bind working directory for functions
#
# singularity run --bind /local/path/to/MB:/MB,/local/path/to/data:/datain matlabr2019a.sif readcmrrphysio.sh

#cd /work


physdcm=$(ls /datain/*physio*dcm)

echo $physdcm
matlab -nodisplay -nosplash -nodesktop -r "addpath('/home/matlab');addpath('/MB');addpath('/datain');extractCMRRPhysio('$physdcm');exit;" | tail -n +11
