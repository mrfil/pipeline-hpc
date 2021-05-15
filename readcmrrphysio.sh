#!/bin/bash
#
# sample script for running matlab routines in container
#
# bind directories for data and toolboxes on run, then specify their paths in this script
# bind working directory for functions
#
# singularity run --bind /local/path/to/MB:/MB,/local/path/to/data:/datain matlabr2019a.sif readcmrrphysio.sh arg1


#cd /work

arg1=$1

matlab -nodisplay -nosplash -nodesktop -r "addpath('/home/matlab');addpath('/MB');addpath('/datain');readCMRRPhysio('$arg');exit;" | tail -n +11
