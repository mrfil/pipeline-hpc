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

projDir=${based}/${version}/testing/${project}
mkdir $CACHESING
mkdir $TMPSING

ses=${sesname:4}
sub=${subject:4}

IMAGEDIR=${based}/singularity_images
scripts=${based}/${version}/scripts
projDir=${based}/${version}/testing/${project}
scachedir=${based}/${version}/scratch/scache/${project}/${subject}/${sesname}
stmpdir=${based}/${version}/scratch/stmp/${project}/${subject}/${sesname}

mkdir -p ${based}/${version}/scratch/scache/${project}/${subject}
mkdir -p ${based}/${version}/scratch/stmp/${project}/${subject}
mkdir ${scachedir}
mkdir ${stmpdir}
chmod 777 -R ${stmpdir}
chmod 777 -R ${scachedir}
NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep started $NOW" >> ${scripts}/fulltimer.txt

# switching from v0.16.0RC3 to v0.16.1 !!!10/20/2022
SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives --freesurfer_input /data/bids/derivatives/sourcedata/freesurfer --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject}

chmod 777 -R ${projDir}/bids/derivatives/qsiprep/${subject}
NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep finished $NOW" >> ${scripts}/fulltimer.txt

NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep CSD Recon started $NOW" >> ${scripts}/fulltimer.txt
SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec mrtrix_multishell_msmt_ACT-hsvs --freesurfer_input /data/bids/derivatives/sourcedata/freesurfer --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject}
NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep CSD Recon finished $NOW" >> ${scripts}/fulltimer.txt
chmod 777 -R ${projDir}/bids/derivatives/qsirecon/${subject}

SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/qsirecon:/data ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

mv ${projDir}/bids/derivatives/qsirecon/${subject}* ${projDir}/bids/derivatives/qsicsd
NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep GQI Recon started $NOW" >> ${scripts}/fulltimer.txt

SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec dsi_studio_gqi --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject}
NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep GQI Recon finished $NOW" >> ${scripts}/fulltimer.txt
chmod 777 -R ${projDir}/bids/derivatives/qsirecon/${subject}

SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datain -W /datain ${IMAGEDIR}/pylearn.sif /scripts/gqimetrics.py
mv ${projDir}/bids/derivatives/qsirecon/${subject}* ${projDir}/bids/derivatives/qsigqi

NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep NODDI AMICO Recon started $NOW" >> ${scripts}/fulltimer.txt
SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec amico_noddi --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject} 
NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep NODDI Recon finished $NOW" >> ${scripts}/fulltimer.txt
chmod 777 -R ${projDir}/bids/derivatives/qsirecon/${subject}

NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep Reorient to FSL standard started $NOW" >> ${scripts}/fulltimer.txt
SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec reorient_fslstd --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject}
NOW=$(date +"%m-%d-%Y-%T")
echo "QSIprep Reorient to FSL standard finished $NOW" >> ${scripts}/fulltimer.txt
chmod 777 -R ${projDir}/bids/derivatives/qsirecon/${subject}

mv ${projDir}/bids/derivatives/qsirecon/${subject}* ${projDir}/bids/derivatives/qsiamiconoddi

mkdir -p $projDir/bids/derivatives/fsl/${subject}/${sesname}
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${projDir}/bids/derivatives/fsl/${subject}/${sesname}:/fslin --bind ${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datain $IMAGEDIR/fsl_601.sif dtifit -k /datain/${subject}_${sesname}_run-1_space-T1w_desc-preproc_dwi.nii.gz -o /fslin/sub-SAY244_ses-A_run-1_space-T1w_desc-DTIFIT -m /datain/${subject}_${sesname}_run-1_space-T1w_desc-brain_mask.nii.gz -r /datain/${subject}_${sesname}_run-1_space-T1w_desc-preproc_dwi.bvec -b /datain/${subject}_${sesname}_run-1_space-T1w_desc-preproc_dwi.bval --kurt --save_tensor

echo "collecting info from DICOM headers"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/${sub}/${ses}/dir/SCANS:/datain,${scripts}:/scripts ${IMAGEDIR}/bidscoin.sif python /scripts/dicominfo.py
mv ${projDir}/${sub}/${ses}/dir/SCANS/stats.csv ${projDir}/bids/derivatives/${subject}_${sesname}_stats.csv

${scripts}/pipeline_collate_SAY.sh -p ${project} -z ${subject} -s ${sesname} -b ${based} -t beta


