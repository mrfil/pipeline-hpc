#!/bin/bash
#
#script for generating a project json file
#
#	usage project_doc.sh {project} {subject} {session} {process called (heudiconv, mriqc, fmriprep, xcpengine, mridti, scfsl)} {is this a new file? (yes/no)} {app version}
#
#	to be called as part of a pipeline for documentation of processing tool calls

project=$1
subject=$2
session=$3
proc=$4
newFile=$5
version=$6

#pull in versions from sif names var in script?

#Get date and time
NOW=$(date +"%m-%d-%Y-%T")

jsonfile="${project}_${subject}_${session}.json"

if [ "${newFile}" == "yes" ];
then 
	jo log="pipeline processing" project="${project}" > $jsonfile
fi

#if statements for each process (heudiconv, mriqc, fmriprep, xcpengine, mridti, scfsl)
if [ "${proc}" == "heudiconv" ];
then 
	cat $jsonfile | jq '.step1["process"] |= "HeuDiConv"' | jq '.step1["Docker"] |= "nipy/heudiconv:'${version}'"' | jq '.step1["date"] |= '"${NOW}"'' | jq '.step1["description"] |= "Heuristic-based conversion from DICOMs to BIDS-compatible nii.gz images with JSON sidecars with dcm2niix"' > tmp
    mv tmp $jsonfile
elif [ "${proc}" == "mriqc" ];
then
	cat $jsonfile | jq '.step2["process"] |= "MRIQC"' | jq '.step2["Docker"] |= "poldracklab/mriqc:'${version}'"' | jq '.step2["date"] |= '"${NOW}"'' | jq '.step2["description"] |= "MRIQC extracts no-reference IQMs (image quality metrics) from structural (T1w and T2w) and functional MRI (magnetic resonance imaging) data"' > tmp
	mv tmp "$jsonfile"
elif [ "${proc}" == "fmriprep" ];
then
	cat $jsonfile | jq '.step3["process"] |= "fMRIPrep"' | jq '.step3["Docker"] |= "nipreps/fmriprep:'${version}'"' | jq '.step3["date"] |= '"${NOW}"'' | jq '.step3["description"] |= "fMRIPrep is a functional magnetic resonance imaging (fMRI) data preprocessing pipeline that is designed to provide an easily accessible, state-of-the-art interface that is robust to variations in scan acquisition protocols and that requires minimal user input, while providing easily interpretable and comprehensive error and output reporting. It performs basic processing steps (coregistration, normalization, unwarping, noise component extraction, segmentation, skullstripping etc.) providing outputs that can be easily submitted to a variety of group level analyses, including task-based or resting-state fMRI, graph theory measures, surface or volume-based statistics, etc."' > tmp
	mv tmp "$jsonfile"
elif [ "${proc}" == "xcpengine" ];
then
	cat $jsonfile | jq '.step4["process"] |= "xcpEngine"' | jq '.step4["Docker"] |= "pennbbl/xcpengine:'${version}'"' | jq '.step4["date"] |= '"${NOW}"'' | jq '.step4["description"] |= "The XCP imaging pipeline (XCP system) is a free, open-source software package for processing of multimodal neuroimages. The XCP system uses a modular design to deploy analytic routines from leading MRI analysis platforms, including FSL, AFNI, and ANTs"' > tmp
	mv tmp "$jsonfile"
elif [ "${proc}" == "mridti" ];
then
	cat $jsonfile | jq '.step5["process"] |= "MRIDTI FSL"' | jq '.step5["Docker"] |= "mrfilbi/neurodoc:'${version}'"' | jq '.step5["date"] |= '"${NOW}"'' | jq '.step5["description"] |= "Diffusion tensor processing pipeline with FSL "' > tmp
	mv tmp "$jsonfile"
elif [ "${proc}" == "qsiprep" ];
then
	#QSIPrep is preferred over mridti due to more complete preprocessing
	cat $jsonfile | jq '.step5["process"] |= "QSIPrep preprocessing"' | jq '.step5["Docker"] |= "pennbbl/qsiprep:'${version}'"' | jq '.step5["date"] |= '"${NOW}"'' | jq '.step5["description"] |= "The preprocessing pipelines are built based on the available BIDS inputs, ensuring that fieldmaps are handled correctly. The preprocessing workflow performs head motion correction, susceptibility distortion correction, MP-PCA denoising, coregistration to T1w images, spatial normalization using ANTs_ and tissue segmentation. This requires step 6 to include the reorient_fslstd reconstruction method to use outputs in FSL space!"' > tmp
	mv tmp "$jsonfile"
elif [ "${proc}" == "qsirecon" ];
then
	cat $jsonfile | jq '.step6["process"] |= "QSIPrep reconstruction"' | jq '.step6["Docker"] |= "pennbbl/qsiprep:'${version}'"' | jq '.step6["date"] |= '"${NOW}"'' | jq '.step6["description"] |= "QSIPrep reconstructions performed include: mrtrix_multishell_msmt_ACT-hsvs, dsi_studio_gqi, amico_noddi, and reorient_fslstd. More details at https://qsiprep.readthedocs.io/en/latest/reconstruction.html#"' > tmp
	mv tmp "$jsonfile"
elif [ "${proc}" == "scfsl" ];
then
	cat $jsonfile | jq '.step7["process"] |= "SCFSL GPU"' | jq '.step7["Docker"] |= "mrfilbi/scfsl_gpu:'${version}'"' | jq '.step7["date"] |= '"${NOW}"'' | jq '.step7["description"] |= "CUDA-accelerated FSL-based structural connectivity analysis with fibre-tracking between 68 cortical regions, 14 subcortical regions, and the left and right cerebellar cortices defined by the Freesurfer recon-all parcellation using the Desikan-Killiany Atlas"' > tmp
	mv tmp "$jsonfile"
fi

