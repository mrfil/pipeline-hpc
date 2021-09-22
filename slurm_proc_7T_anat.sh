#!/bin/bash
# perform fMRIPrep anat-only routine & ASHS

while getopts :p:s:z:m:f:l:b:t: option; do
	case ${option} in
    	p) export CLEANPROJECT=$OPTARG ;;
    	s) export CLEANSESSION=$OPTARG ;;
    	z) export CLEANSUBJECT=$OPTARG ;;
	m) export MINQC=$OPTARG ;;
	f) export fieldmaps=$OPTARG ;;
	l) export longitudinal=$OPTARG ;;
	b) export based=$OPTARG ;;
	t) export version=$OPTARG ;;
	esac
done
## takes project, subject, and session as inputs

IMAGEDIR=${based}/singularity_images
tmpdir=${based}/${version}/testing
scripts=${based}/${version}/scripts
bids_out=${based}/${version}/bids_only
conn_out=${based}/${version}/conn_out
dataqc=${based}/${version}/data_qc
stmpdir=${based}/${version}/scratch/stmp
scachedir=${based}/${version}/scratch/scache

DIR=${CLEANPROJECT}/${CLEANSUBJECT}/${CLEANSESSION}


## setup our variables and change to the session directory

echo ${CLEANPROJECT}
echo ${CLEANSUBJECT}
echo ${CLEANSESSION}
pwd

#translating naming conventions
echo "${CLEANSESSION: -1}"
session="${CLEANSESSION: -1}"
echo ${session}
project=${CLEANPROJECT}
mkdir -p ${tmpdir}/${project}/${CLEANSUBJECT}/${session}

subject="sub-"${CLEANSUBJECT}
sesname="ses-"${session}

#check for heuristic
if [ -f "${tmpdir}/${project}/${project}_heuristic.py" ];
then
	echo "trusting project heuristic"
else
	cp ${scripts}/main_heuristic.py ${tmpdir}/${project}/${project}_heuristic.py
fi

	projDir=${tmpdir}/${project}
	scripts=${based}/${version}/scripts

	cd $projDir

	IMAGEDIR=${based}/singularity_images
	CACHESING=${scachedir}/${project}_${subject}_${sesname}_dcm2rsfc
	TMPSING=${stmpdir}/${project}_${subject}_${sesname}_dcm2rsfc
	mkdir $CACHESING
	mkdir $TMPSING


	ses=${sesname:4}
	sub=${subject:4}
	chmod 2777 -R ${projDir}/bids

	mkdir ${based}/${version}/output/${project}

	mkdir ${projDir}/bids/derivatives

	cd ${projDir}

	mkdir ${projDir}/bids/derivatives/mriqc
	chmod 777 -R ${projDir}/bids/derivatives/mriqc


	${scripts}/project_doc.sh ${project} ${subject} ${sesname} "mriqc" "no"
	NOW=$(date +"%m-%d-%Y-%T")
	echo "MRIQC started $NOW" >> ${scripts}/fulltimer.txt
	echo "Denoising MP2RAGE with LAYNII"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/sub-${sub}/ses-${ses}/anat:/datain $IMAGEDIR/laynii-2.0.0.sif /opt/laynii2/laynii/LN_MP2RAGE_DNOISE -INV1 /datain/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-1_T1w.nii.gz -INV2 /datain/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-2_T1w.nii.gz -UNI /datain/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w.nii.gz -beta 0.2
	mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/*inv* ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/*uni_run-*_T1w.nii.gz ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/*uni_run-*_T1w.json ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w*border*.nii.gz ${projDir}/bids/derivatives/
        mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w_denoised.nii.gz ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageunidenoised_T1w.nii.gz 
	echo "Running mriqc"
	TEMPLATEFLOW_HOST_HOME=$IMAGEDIR/templateflow
        export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},${projDir}/bids:/data,${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-0.16.1.sif /data /out participant --participant-label ${sub} --session-id ${ses} --no-sub
	chmod 2777 -R ${projDir}/bids/derivatives/mriqc

	NOW=$(date +"%m-%d-%Y-%T")
	echo "MRIQC finished $NOW" >> ${scripts}/fulltimer.txt

	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} mriqc ${based}

	rm -rf ${TMPSING}/*
	rm -rf ${CACHESING}/*
	
	mkdir ${dataqc}/${project}
	cp -R ${projDir}/bids/derivatives/mriqc ${dataqc}/${project}/

	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep started $NOW" >> ${scripts}/fulltimer.txt

	#fmriprep
	echo "Running fmriprep on $subject $sesname"

	${scripts}/project_doc.sh ${project} ${subject} ${sesname} "fmriprep" "no"
	if [ "${longitudinal}" == "yes" ];
	then 
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-20.2.1.sif fmriprep /datain/bids /datain/bids/derivatives participant --participant-label ${subject} --longitudinal --use-aroma --output-spaces {MNI152NLin2009cAsym:res-2,T1w,fsnative:res-2} -w /paulscratch --fs-license-file /opt/freesurfer/license.txt
	elif [ "${longitudinal}" == "no" ];
	then
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-20.2.1.sif fmriprep /datain/bids /datain/bids/derivatives participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym:res-2,T1w,fsnative:res-2} -w /paulscratch --anat-only --fs-license-file /opt/freesurfer/license.txt
	fi


	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep finished $NOW" >> ${scripts}/fulltimer.txt

	rm -rf ${TMPSING}/*
	rm -rf ${CACHESING}/*
	chmod 2777 -R ${projDir}/bids/derivatives/fmriprep
	
	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} fmriprep ${based}
	echo "Performing automated hippocampal subfield segmentation with ASHS v1.0.0"
        export SINGULARITYENV_ASHS_ROOT=/opt/ashs/ashs-1.0.0
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}:/datain $IMAGEDIR/ashs-1.0.0.sif $SINGULARITYENV_ASHS_ROOT/bin/ashs_main.sh -a /opt/ashs/ashs_atlas_umcutrecht_7t_20170810 -g /datain/bids/${subject}/${sesname}/anat/${subject}_${sesname}_acq-mp2rageunidenoised_T1w.nii.gz -f /datain/bids/${subject}/${sesname}/anat/${subject}_${sesname}_acq-highreshippocampus_run-1_T2w.nii.gz -w /datain/bids/derivatives/ashs/${subject}/${sesname} 

