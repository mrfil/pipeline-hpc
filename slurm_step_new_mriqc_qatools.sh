#!/bin/bash
#slurm_process_pipeline.sh

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

#translating naming conventions
echo "${CLEANSESSION: -1}"
session="${CLEANSESSION: -1}"
echo ${session}
project=${CLEANPROJECT}
#mkdir -p ${tmpdir}/${project}/${CLEANSUBJECT}/${session}
#cp -R ${tmpdir}/${DIR} ${tmpdir}/${project}/${CLEANSUBJECT}/${session}

subject="sub-"${CLEANSUBJECT}
sesname="ses-"${session}

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

        ses=${sesname:4}
        sub=${subject:4}
	
	chmod 777 -R ${projDir}/bids/sourcedata/${subject}/${sesname}
	mkdir ${based}/${version}/output/${project}

	mkdir ${projDir}/bids/derivatives

	cd ${projDir}

	TEMPLATEFLOW_HOST_HOME=$IMAGEDIR/templateflow
	export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"
	echo "Running mriqc"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},${projDir}/bids/sourcedata:/data,${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-v22.0.6.sif /data /out participant --participant-label ${CLEANSUBJECT} --session-id ${CLEANSESSION} -v --no-sub
	chmod 2777 -R ${projDir}/bids/derivatives/mriqc

${scripts}/pipeline_collate_STEP.sh -p ${project} -z ${subject} -s ${sesname} -b ${based} -t beta




