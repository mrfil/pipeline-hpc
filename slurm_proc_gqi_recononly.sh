#!/bin/bash
# perform only the GQI reconstruction in QSIprep following desired dwi preprocessing

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

		IMAGEDIR=${based}/singularity_images
		scripts=${based}/${version}/scripts
		projDir=${based}/${version}/testing/${project}
		scachedir=${based}/${version}/scratch/scache/${project}/${subject}/${sesname}
		stmpdir=${based}/${version}/scratch/stmp/${project}/${subject}/${sesname}

		mkdir ${based}/${version}/scratch/scache/${project}
		mkdir ${based}/${version}/scratch/stmp/${project}
		mkdir ${based}/${version}/scratch/scache/${project}/${subject}
		mkdir ${based}/${version}/scratch/stmp/${project}/${subject}
		mkdir ${scachedir}
		mkdir ${stmpdir}
		chmod 777 -R ${stmpdir}
		chmod 777 -R ${scachedir}
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep Recon started $NOW" >> ${scripts}/fulltimer.txt
		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.14.3.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec dsi_studio_gqi --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject}
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep Recon finished $NOW" >> ${scripts}/fulltimer.txt
		chmod 777 -R ${projDir}/bids/derivatives/qsirecon

	
		${scripts}/pdf_printer.sh ${projID} ${subject} ${sesname} QSIprepRecon ${based}
