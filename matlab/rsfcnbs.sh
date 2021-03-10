#!/bin/bash
#
# script for running rsfc nbs calc single subject in container
#
# bind directories for data and toolboxes on run, then specify their paths in this script
# bind working directory for functions
#
# singularity run --bind /local/path/to/spm12:/toolbox,/local/path/to/workingDirectory:/work,/local/path/to/bctoolbox:/bctoolbox,/shared/mrfil-data/pcamach2/fcon_dev:/datain matlab-R2019a.sif rsfcnbs.sh 'xcp_minimal_func_aroma' 'sub-CUGB108' 


#cd /work

arg1=$1
arg2=$2


rootpath="/datain/${arg1}/${arg2}/fcon"

cd $rootpath

matlab -nodisplay -nosplash -nodesktop -r "addpath('/home/matlab');addpath('/spmtoolbox');addpath('/bctoolbox');addpath('/datain');addpath('$rootpath');addpath('/work');netproc_single('$rootpath');exit;" | tail -n +11
