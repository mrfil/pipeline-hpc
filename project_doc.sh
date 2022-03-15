#!/bin/bash
#
#script for generating a project xml file
#
#	usage project_doc.sh {project} {subject} {session} {process called (heudiconv, mriqc, fmriprep, xcpengine, mridti, scfsl)} {is this a new file? (yes/no)}
#
#	to be called as part of a pipeline for documentation of processing tool calls
#
#	maybe set up to run on batches with reading in the txt files from batchprocd.sh to the project xml

project=$1
subject=$2
session=$3
proc=$4
newFile=$5

#Get date and time
NOW=$(date +"%m-%d-%Y-%T")

xmlfile="${project}_${subject}_${session}.xml"

if [ "${newFile}" == "yes" ];
then 
	echo '<?xml version="1.0" encoding="utf-8"?>' > "$xmlfile"
	echo '<proc_log id="${project}">' >> "$xmlfile"
	
fi

#if statements for each process (heudiconv, mriqc, fmriprep, xcpengine, mridti, scfsl)
if [ "${proc}" == "heudiconv" ];
then 
	echo '<proc id="HeuDiConv">' >> "$xmlfile"
	echo '<source>nipy/heudiconv</source>' >> "$xmlfile"
	echo '<title>HeuDiConv</title>' >> "$xmlfile"
	echo '<version>0.9.0</version>' >> "$xmlfile"
	echo "<exec_date>${NOW}</exec_date>" >> "$xmlfile"
	echo '<description> Heuristic conversion from DICOMs to BIDS-compatible nii.gz images with JSON sidecars.</description>' >> "$xmlfile"
	echo '<conversion_tool>Chris Rordens dcm2niix</conversion_tool>' >> "$xmlfile"
	echo '</proc>' >> "$xmlfile"
elif [ "${proc}" == "mriqc" ];
then
	head -n -1 "$xmlfile" > temp.txt ; mv temp.txt "$xmlfile"
	echo '<proc id="MRIQC">' >> "$xmlfile"
	echo '<source>poldracklab/mriqc</source>' >> "$xmlfile"
	echo '<title>MRIQC</title>' >> "$xmlfile"
	echo '<version>0.16.1</version>' >> "$xmlfile"
	echo "<exec_date>${NOW}</exec_date>" >> "$xmlfile"
	echo '<description> MRIQC extracts no-reference IQMs (image quality metrics) from structural (T1w and T2w) and functional MRI (magnetic resonance imaging) data </description>' >> "$xmlfile"
	echo '</proc>' >> "$xmlfile"
elif [ "${proc}" == "fmriprep" ];
then
	head -n -1 "$xmlfile" > temp.txt ; mv temp.txt "$xmlfile"
	echo '<proc id="fMRIPrep">' >> "$xmlfile"
	echo '<source>niprep/fmriprep</source>' >> "$xmlfile"
	echo '<title>fMRIPrep</title>' >> "$xmlfile"
	echo '<version>21.0.1</version>' >> "$xmlfile"
	echo "<exec_date>${NOW}</exec_date>" >> "$xmlfile"
	echo '<description>fMRIPrep is a functional magnetic resonance imaging (fMRI) data preprocessing pipeline that is designed to provide an easily accessible, state-of-the-art interface that is robust to variations in scan acquisition protocols and that requires minimal user input, while providing easily interpretable and comprehensive error and output reporting. It performs basic processing steps (coregistration, normalization, unwarping, noise component extraction, segmentation, skullstripping etc.) providing outputs that can be easily submitted to a variety of group level analyses, including task-based or resting-state fMRI, graph theory measures, surface or volume-based statistics, etc.</description>' >> "$xmlfile"
	echo '</proc>' >> "$xmlfile"
elif [ "${proc}" == "xcpengine" ];
then
	head -n -1 "$xmlfile" > temp.txt ; mv temp.txt "$xmlfile"
	echo '<proc id="xcpEngine">' >> "$xmlfile"
	echo '<source>PennBBL/xcpEngine</source>' >> "$xmlfile"
	echo '<title>xcpEngine fc-36p, fc-36p_scrub, fc-aroma</title>' >> "$xmlfile"
	echo '<version>1.2.4</version>' >> "$xmlfile"
	echo "<exec_date>${NOW}</exec_date>" >> "$xmlfile"
	echo '<description> The XCP imaging pipeline (XCP system) is a free, open-source software package for processing of multimodal neuroimages. The XCP system uses a modular design to deploy analytic routines from leading MRI analysis platforms, including FSL, AFNI, and ANTs.</description>' >> "$xmlfile"
	echo '</proc>' >> "$xmlfile"
elif [ "${proc}" == "mridti" ];
then
	head -n -1 "$xmlfile" > temp.txt ; mv temp.txt "$xmlfile"
	echo '<proc id="mridti">' >> "$xmlfile"
	echo '<source>mrfil/mridti</source>' >> "$xmlfile"
	echo '<title>MRI DTI with FSL</title>' >> "$xmlfile"
	echo '<version>1.0.0</version>' >> "$xmlfile"
	echo "<exec_date>${NOW}</exec_date>" >> "$xmlfile"
	echo '<description>Diffusion tensor processing pipeline with FSL bedpostx, probtrackx2.0</description>' >> "$xmlfile"
	echo '</proc>' >> "$xmlfile"
elif [ "${proc}" == "scfsl" ];
then
	head -n -1 "$xmlfile" > temp.txt ; mv temp.txt "$xmlfile"
	echo '<proc id="scfsl">' >> "$xmlfile"
	echo '<source>mrfil/scfsl</source>' >> "$xmlfile"
	echo '<title>Structural Connectivity with FSL </title>' >> "$xmlfile"
	echo '<version>1.0.0</version>' >> "$xmlfile"
	echo "<exec_date>${NOW}</exec_date>" >> "$xmlfile"
	echo '<description> FSL-based structural connectivity analysis with fibre-tracking between 68 cortical regions, 14 subcortical regions, and the left and right cerebellar cortices defined by the Freesurfer recon-all parcellation using the Desikan-Killiany Atlas</description>' >> "$xmlfile"
	echo '</proc>' >> "$xmlfile"
elif [ "${proc}" == "qsiprep" ];
then
	head -n -1 "$xmlfile" > temp.txt ; mv temp.txt "$xmlfile"
	echo '<proc id="qsiprep">' >> "$xmlfile"
	echo '<source>pennbbl/qsiprep</source>' >> "$xmlfile"
	echo '<title>Diffusion Preprocessing with QSIprep</title>' >> "$xmlfile"
	echo '<version>0.15.1</version>' >> "$xmlfile"
	echo "<exec_date>${NOW}</exec_date>" >> "$xmlfile"
	echo '<description>The preprocessing pipelines are built based on the available BIDS inputs, ensuring that fieldmaps are handled correctly. The preprocessing workflow performs head motion correction, susceptibility distortion correction, MP-PCA denoising, coregistration to T1w images, spatial normalization using ANTs_ and tissue segmentation.</description>' >> "$xmlfile"
	echo '</proc>' >> "$xmlfile"
elif [ "${proc}" == "qsirecon" ];
then
	head -n -1 "$xmlfile" > temp.txt ; mv temp.txt "$xmlfile"
	echo '<proc id="qsirecon">' >> "$xmlfile"
	echo '<source>pennbbl/qsiprep</source>' >> "$xmlfile"
	echo '<title>Tractography with Anatomical Constrains using QSIprep MRtrix implementation </title>' >> "$xmlfile"
	echo '<version>0.15.1</version>' >> "$xmlfile"
	echo "<exec_date>${NOW}</exec_date>" >> "$xmlfile"
	echo '<description> This workflow uses the msmt_csd algorithm [Jeurissen2014] to estimate FODs for white matter, gray matter and cerebrospinal fluid using multi-shell acquisitions. The white matter FODs are used for tractography and the T1w segmentation is used for anatomical constraints [Smith2012]. </description>' >> "$xmlfile"
	echo '</proc>' >> "$xmlfile"
fi
echo "</proc_log>" >> "$xmlfile"

