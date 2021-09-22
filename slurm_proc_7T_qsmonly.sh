#!/bin/bash
# perform quantitative susceptibility mapping with a custom combination of code from Cornell and Berkeley - courtesy of Berkin Bilgic
# specify fractional intensity threshold for fsl bet with -i argument
# 
# 	please cite the relevant sources: 
# 		http://pre.weill.cornell.edu/mri/pages/qsm.html
# 		https://people.eecs.berkeley.edu/~chunlei.liu/software.html
# outputs are pseudo-BIDSified

while getopts :p:s:z:m:f:l:b:t:i: option; do
	case ${option} in
    	p) export CLEANPROJECT=$OPTARG ;;
    	s) export CLEANSESSION=$OPTARG ;;
    	z) export CLEANSUBJECT=$OPTARG ;;
	m) export MINQC=$OPTARG ;;
	f) export fieldmaps=$OPTARG ;;
	l) export longitudinal=$OPTARG ;;
	b) export based=$OPTARG ;;
	t) export version=$OPTARG ;;
	i) export intensity=$OPTARG ;;
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


	cd ${projDir}

	mkdir ${projDir}/bids/derivatives/swi 
        mkdir ${projDir}/bids/derivatives/swi/${subject}
        mkdir ${projDir}/bids/derivatives/swi/${subject}/${sesname}
	mkdir ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out
	mv ${projDir}/${sub}/${ses}/*/swi/* ${projDir}/bids/derivatives/swi/${subject}/${sesname}/
  	mv ${projDir}/${sub}/${ses}/*/swi/* ${projDir}/bids/derivatives/swi/${subject}/${sesname}/
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to $intensity (see scripts/matlab/ndi_qsm.sh)"
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-R2019a.sif /scripts/ndi_qsm.sh ${intensity}
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./${subject}_${sesname}_ndi_mag.nii
	mv ./ndi_out/phs.nii ./${subject}_${sesname}_ndi_phs.nii
	mv ./ndi_out/qsm.nii ./${subject}_${sesname}_ndi_qsm.nii
	

