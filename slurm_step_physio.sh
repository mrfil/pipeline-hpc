#!/bin/bash
#slurm_physio_step.sh

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

pilotdir=${based}/testing
IMAGEDIR=${based}/singularity_images
tmpdir=${based}/${version}/testing
scripts=${based}/${version}/scripts
bids_out=${based}/${version}/bids_only
conn_out=${based}/${version}/conn_out
dataqc=${based}/${version}/data_qc
stmpdir=${based}/${version}/scratch/stmp
scachedir=${based}/${version}/scratch/scache

cd $pilotdir

DIR=${CLEANPROJECT}/${CLEANSUBJECT}/${CLEANSESSION}


## setup our variables and change to the session directory

echo ${CLEANPROJECT}
echo ${CLEANSUBJECT}
echo ${CLEANSESSION}
pwd

subject="sub-"${CLEANSUBJECT}
sesname="ses-"${CLEANSESSION}
project=${CLEANPROJECT}

	projDir=${based}/${version}/testing/${project}
	scripts=${based}/${version}/scripts

	cd $projDir

	IMAGEDIR=${based}/singularity_images
	CACHESING=${scachedir}/${project}_${subject}_${sesname}_dcm2rsfc
	TMPSING=${stmpdir}/${project}_${subject}_${sesname}_dcm2rsfc
	mkdir $CACHESING
	mkdir $TMPSING

	ses=${sesname:4}
	sub=${subject:4}
	
#	set_physio="$( echo "${projDir}/${sub}/${ses}/dir/SCANS/10/DICOM/*dcm")"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/sourcedata/${subject}/${sesname}/func:/datadir,${projDir}/${sub}/${ses}/dir/SCANS/10/DICOM/SET_physio.dcm:/datain/${subject}_${sesname}_task-SET_dir-PA_run-1_physio.dcm ${IMAGEDIR}/bidsphysio.sif physio2bidsphysio --infile /datain/${subject}_${sesname}_task-SET_dir-PA_run-1_physio.dcm --bidsprefix /datadir/${subject}_${sesname}_task-SET_dir-PA_run-1 
	mv ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-SET_dir-PA_run-1_recording-external_trigger_physio.json ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-SET_dir-PA_run-1_recording-externaltrigger_physio.json
        mv ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-SET_dir-PA_run-1_recording-external_trigger_physio.tsv.gz ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-SET_dir-PA_run-1_recording-externaltrigger_physio.tsv.gz
	
#	rest_physio="$( echo "${projDir}/${sub}/${ses}/dir/SCANS/13/DICOM/*dcm")"
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/sourcedata/${subject}/${sesname}/func:/datadir,${projDir}/${sub}/${ses}/dir/SCANS/13/DICOM/REST_physio.dcm:/datain/${subject}_${sesname}_task-rest_dir-PA_run-1_physio.dcm ${IMAGEDIR}/bidsphysio.sif physio2bidsphysio --infile /datain/${subject}_${sesname}_task-rest_dir-PA_run-1_physio.dcm --bidsprefix /datadir/${subject}_${sesname}_task-rest_dir-PA_run-1
        mv ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_recording-external_trigger_physio.json ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_recording-externaltrigger_physio.json
        mv ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_recording-external_trigger_physio.tsv.gz ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_recording-externaltrigger_physio.tsv.gz

#	egng_physio="$( echo "${projDir}/${sub}/${ses}/dir/SCANS/16/DICOM/*dcm")"
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/sourcedata/${subject}/${sesname}/func:/datadir,${projDir}/${sub}/${ses}/dir/SCANS/16/DICOM/EGNG_physio.dcm:/datain/${subject}_${sesname}_task-EGNG_dir-PA_run-1_physio.dcm ${IMAGEDIR}/bidsphysio.sif physio2bidsphysio --infile /datain/${subject}_${sesname}_task-EGNG_dir-PA_run-1_physio.dcm --bidsprefix /datadir/${subject}_${sesname}_task-EGNG_dir-PA_run-1
        mv ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-EGNG_dir-PA_run-1_recording-external_trigger_physio.json ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-EGNG_dir-PA_run-1_recording-externaltrigger_physio.json
        mv ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-EGNG_dir-PA_run-1_recording-external_trigger_physio.tsv.gz ${projDir}/bids/sourcedata/${subject}/${sesname}/func/${subject}_${sesname}_task-EGNG_dir-PA_run-1_recording-externaltrigger_physio.tsv.gz

        cd ${projDir}/bids/${subject}/${sesname}/func/ && echo "*_physio.*" > ${projDir}/bids/.bidsignore


