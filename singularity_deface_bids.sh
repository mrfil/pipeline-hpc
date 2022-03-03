#!/bin/bash
# script for defacing nifti images
#
# requires Python module pydeface
# written by Megan Finnegan
# 
# adapted by Paul B Camacho for HPC-deployment: uses Singularity image of pydeface
# 	see github.com/pcamach2/pydeface for Dockerfile and build steps
#
# designed for use with BIDS v1.7.0 (https://bids-specification.readthedocs.io/)
# 
# usage: Takes project, image type to denoise, base directory, and version of pipeline as inputs
#       singularity_deface_bids.sh -p <Project ID> -i <"T1w T2w FLAIR ..."> -b <base directory for pipeline> -t <version of pipeline>

while getopts :p:i:b:t: option; do
        case ${option} in
        p) export project=$OPTARG ;;
        i) export imtype=$OPTARG ;;
        b) export based=$OPTARG ;;
        t) export version=$OPTARG ;;
        esac
done

export projDir=${based}/${version}/testing/${project}
export IMAGEDIR=${based}/singularity_images
export scripts=${based}/${version}/scripts

export CACHESING=${based/scratch/scache/${project}_deface
export TMPSING=${based}/scratch/stmp/${project}_deface

mkdir "${CACHESING}"
mkdir "${TMPSING}"

NOW=$(date +"%m-%d-%Y-%T")
LOGFILE="${project}_pydeface_log_${NOW}.txt"
echo "Project: ${project}" >> ${projDir}/$LOGFILE

export dataDir=${projDir}/bids

cd ${dataDir}
echo ${dataDir}

#loop through image types requested 
for imt in "${imtype[@]}"; do

echo "Defacing ${imt} with pydeface version 2.0.0"
echo "Defacing ${imt} with pydeface version 2.0.0" >> ${projDir}/$LOGFILE
# deface images with Singularity image of pydeface
find . -type f -name "*${imt}.nii.gz" -execdir bash -c 'echo "$0" && SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projDir}/bids:/data,${scripts}:/scripts ${IMAGEDIR}/pydeface-v2.0.0.sif "$0"' {};
#devnote: old end of prev_line "{}" \; instead of {} \;"

# rename output -- note that find does not support string substitution and 
# it is expensive to start a subshell for a simple move command. Hence this.
# find . -type f -name "*${imt}_defaced.nii.gz" -print0 | while IFS= read -d '' -r file; do mv "$file" "${file/_defaced.nii.gz/.nii.gz}"; done
while IFS= read -d '' -r file; do
mv "$file" "${file/_defaced.nii.gz/.nii.gz}"
done 3< <(find . -type f -name "*${imt}_defaced.nii.gz" -print0)

done
