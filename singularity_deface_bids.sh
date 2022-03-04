#!/bin/bash
#
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
# usage: Takes project, image modality to denoise, base directory, and version of pipeline as inputs
#       singularity_deface_bids.sh -p <Project ID> -m <"T1w T2w FLAIR ..."> -b <base directory for pipeline> -t <version of pipeline>

echo 'usage: Takes project, image modality to denoise, base directory, and version of pipeline as inputs'
echo 'singularity_deface_bids.sh -p <Project ID> -m <"T1w T2w FLAIR ..."> -b <base directory for pipeline> -t <version of pipeline>'

while getopts :p:m:b:t: option; do
    case ${option} in
    p) export PROJECT=$OPTARG ;;
    m) export MODALITY=$OPTARG ;;
    b) export BASED=$OPTARG ;;
    t) export VERSION=$OPTARG ;;
    esac
done

export projDir="${BASED}/${VERSION}/testing/${PROJECT}"
export IMAGEDIR="${BASED}/singularity_images"

CACHESING="${BASED}/${VERSION}/scratch/scache/${PROJECT}_deface"
TMPSING="${BASED}/${VERSION}/scratch/stmp/${PROJECT}_deface"

echo "$projDir"
echo "$IMAGEDIR"
echo "$MODALITY"

mkdir "${CACHESING}"
mkdir "${TMPSING}"

NOW=$(date +"%m-%d-%Y-%T")
LOGFILE="${PROJECT}_pydeface_log_${NOW}.txt"
echo "Project: ${PROJECT}" >> ${projDir}/$LOGFILE
echo "Project: ${PROJECT}"

export dataDir="${projDir}/bids"

#cd /projects/BICpipeline/beta/testing/PTEtest/bids

cd "${dataDir}"
echo "${dataDir}"

#loop through image types requested 
for imt in `echo "${MODALITY}"`; do

echo "Defacing ${imt} with pydeface version 2.0.0"
echo "Defacing ${imt[@]} with pydeface version 2.0.0" >> ${projDir}/$LOGFILE
# deface images with Singularity image of pydeface
find . -type f -name "*_${imt[@]}.nii.gz" -exec sh -c 'echo "$1"' - {} \; -and -exec bash -c 'singularity run -B ${dataDir}:/data --pwd /data ${IMAGEDIR}/pydeface-v2.0.0.sif pydeface "$1"' - {} \; -and -print
#devnote: old end of prev_line "{}" \; instead of {} \;"

# rename output -- note that find does not support string substitution and 
# it is expensive to start a subshell for a simple move command. Hence this.
#  find . -type f -name "*_${imt}_defaced.nii.gz" -print0 | while IFS= read -d '' -r file; do mv "$file" "${file/_defaced.nii.gz/.nii.gz}"; done
while IFS= read -d '' -r file; do
mv "$file" "${file/_defaced.nii.gz/.nii.gz}"
done < <(find . -type f -name "*_${imt[@]}_defaced.nii.gz" -print0)

done
