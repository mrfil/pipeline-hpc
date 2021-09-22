#!/bin/bash
# perform only DICOM to BIDS-compatible NIFTI conversion with HeuDiConv

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

	NOW=$(date +"%m-%d-%Y-%T")
	echo "HeuDiConv started $NOW" > ${scripts}/fulltimer.txt

	#heudiconv
	echo "Running heudiconv"
	${scripts}/project_doc.sh ${project} ${subject} ${sesname} "heudiconv" "yes"
	ses=${sesname:4}
	sub=${subject:4}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}:/datain ${IMAGEDIR}/heudiconv0.6.simg heudiconv -d /datain/{subject}/{session}/*/*/* -f /datain/${project}_heuristic.py -o /datain/bids --minmeta -s ${sub} -ss ${ses} -c dcm2niix -b --overwrite 
	chmod 2777 -R ${projDir}/bids

	NOW=$(date +"%m-%d-%Y-%T")
	echo "HeuDiConv finished $NOW" >> ${scripts}/fulltimer.txt

	if [ "${fieldmaps}" == "yes" ];
	then
	    SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jq-0.1.sif /scripts/jsoncrawler.sh /data/bids ${sesname} ${subject}
	fi
	
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/tmp
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/test.txt	

	mkdir ${projDir}/bids/derivatives
