#!/bin/bash
# performs extended processing pipeline with ASHS, multiple reconstructions in QSIprep, nback task processing as example for XCPengine task-based workflow

while getopts :p:s:z:m:f:l:b:t:e: option; do
	case ${option} in
    p) export CLEANPROJECT=$OPTARG ;;
    s) export CLEANSESSION=$OPTARG ;;
    z) export CLEANSUBJECT=$OPTARG ;;
	m) export MINQC=$OPTARG ;;
	f) export fieldmaps=$OPTARG ;;
	l) export longitudinal=$OPTARG ;;
	b) export based=$OPTARG ;;
	t) export version=$OPTARG ;;
	e) export address=$OPTARG ;;
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

#check for heuristic
if [ -f "${tmpdir}/${project}/${project}_heuristic.py" ];
then
	echo "trusting project heuristic"
else
	cp ${scripts}/main_heuristic.py ${tmpdir}/${project}/${project}_heuristic.py
fi

if [ "${MINQC}" == "yes" ];
then

	projDir=${tmpdir}/${project}
	scripts=${based}/${version}/scripts

	cd $projDir

	IMAGEDIR=${based}/singularity_images
	CACHESING=${scachedir}/${project}_${subject}_${sesname}_minqc
	TMPSING=${stmpdir}/${project}_${subject}_${sesname}_minqc

	mkdir $CACHESING
	mkdir $TMPSING
	chmod 777 -R $CACHESING
	chmod 777 -R $TMPSING

	NOW=$(date +"%m-%d-%Y-%T")
	#heudiconv
	echo "Running heudiconv"
	echo "$NOW" > ${scripts}/timer.txt

	ses=${sesname:4}
	sub=${subject:4}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/datain $IMAGEDIR/heudiconv-0.9.0.sif heudiconv -d /datain/{subject}/{session}/scans/*/DICOM/*dcm -f /datain/${project}_heuristic.py -o /datain/bids -s ${sub} -ss ${ses} -c dcm2niix -b
	chmod 777 -R ${projDir}/bids
	rm -rf __pycache__

	mkdir ${based}/dataqc/${project}

	mkdir ${projDir}/bids/derivatives

	cd ${projDir}

	rm ${projDir}/bids/derivatives/mriqc
	mkdir ${projDir}/bids/derivatives/mriqc
	chmod 2777 -R ${projDir}/bids/derivatives/mriqc

	cd $projDir
	echo "Running mriqc"

	NOW=$(date +"%m-%d-%Y-%T")
	echo "$NOW" >> ${scripts}/timer.txt

	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${projDir}/bids:/data --bind ${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-0.16.0.sif /data /out participant --participant-label ${sub} --session-id ${ses} --fft-spikes-detector --despike --no-sub
	chmod 2777 -R ${projDir}/bids/derivatives/mriqc

	NOW=$(date +"%m-%d-%Y-%T")
	echo "$NOW" >> ${scripts}/timer.txt

	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} mriqc ${based}

	rm -rf $CACHESING
	rm -rf $TMPSING
	mv ${projDir}/bids/derivatives/mriqc ${based}/dataqc/${project}/mriqc
	chmod 777 -R ${based}/dataqc/${project}

else
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
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jqjo.sif /scripts/project_doc.sh ${project} ${subject} ${sesname} "heudiconv" "yes" "0.9.0"
	ses=${sesname:4}
	sub=${subject:4}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}:/datain ${IMAGEDIR}/heudiconv-0.9.0.sif heudiconv -d /datain/{subject}/{session}/dir/SCANS/*/DICOM/*dcm -f /datain/${project}_heuristic.py -o /datain/bids -s ${sub} -ss ${ses} -c dcm2niix -b --overwrite --minmeta
	chmod 2777 -R ${projDir}/bids
	#rm -rf __pycache__
	#rm -rf $CACHESING/*
	#rm -rf $TMPSING/*

	NOW=$(date +"%m-%d-%Y-%T")
	echo "HeuDiConv finished $NOW" >> ${scripts}/fulltimer.txt

	#jsoncrawler.sh runs once, for all sessions
	if [ "${fieldmaps}" == "yes" ];
	then
	    SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jqjo.sif /scripts/jsoncrawler.sh /data/bids ${sesname} ${subject}
	fi
	
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/tmp
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/test.txt	

	
	dirs=$(ls ${projDir}/${sub}/${ses}/*/SCANS/*/*/*secondary*xml)
	dirp=${dirs%/DICOM/*secondary*xml}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${scripts}:/scripts,${dirp}:/datain ${IMAGEDIR}/bidscoin.sif python /scripts/detectphysiolog.py
	physdir=$(ls ${projDir}/${sub}/${ses}/*/SCANS/*/*/*physio*dcm)
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/${subject}/${sesname}/func:/datadir,${physdir}:/datain/${subject}_${sesname}_task-rest_dir-PA_run-1_physio.dcm ${IMAGEDIR}/bidsphysio.sif physio2bidsphysio --infile /datain/${subject}_${sesname}_task-rest_dir-PA_run-1_physio.dcm --bidsprefix /datadir/${subject}_${sesname}_task-rest_dir-PA_run-1 
		
	chmod 777 -R ${projDir}/bids/${subject}/${sesname}
	mv ${projDir}/bids/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_recording-external_trigger_physio.json ${projDir}/bids/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_recording-externaltrigger_physio.json
	mv ${projDir}/bids/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_recording-external_trigger_physio.tsv.gz ${projDir}/bids/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_recording-externaltrigger_physio.tsv.gz
	echo "*_physio.*" > ${projDir}/bids/.bidsignore
	mkdir ${based}/${version}/output/${project}

	mkdir ${projDir}/bids/derivatives

	cd ${projDir}

	mkdir ${projDir}/bids/derivatives/mriqc
	chmod 777 -R ${projDir}/bids/derivatives/mriqc

	cd $projDir
	echo "Running mriqc"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jqjo.sif /scripts/project_doc.sh ${project} ${subject} ${sesname} "mriqc" "no" "0.16.1"
	NOW=$(date +"%m-%d-%Y-%T")
	echo "MRIQC started $NOW" >> ${scripts}/fulltimer.txt
	TEMPLATEFLOW_HOST_HOME=$IMAGEDIR/templateflow
	export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},${projDir}/bids:/data,${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-0.16.1.sif /data /out participant --participant-label ${sub} --session-id ${ses} -v --no-sub
	chmod 2777 -R ${projDir}/bids/derivatives/mriqc

	NOW=$(date +"%m-%d-%Y-%T")
	echo "MRIQC finished $NOW" >> ${scripts}/fulltimer.txt

	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} mriqc ${based}

	#rm -rf ${TMPSING}/*
	#rm -rf ${CACHESING}/*
	
	mkdir ${dataqc}/${project}

	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep started $NOW" >> ${scripts}/fulltimer.txt

	#fmriprep
	echo "Running fmriprep on $subject $sesname"
	#add more details of fMRIPrep arguments if necessary

	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jqjo.sif /scripts/project_doc.sh ${project} ${subject} ${sesname} "fmriprep" "no" "21.0.1"
	if [ "${longitudinal}" == "yes" ];
	then 
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-21.0.1.sif fmriprep /datain/bids /datain/bids/derivatives participant --participant-label ${subject} --longitudinal --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} --use-aroma -w /paulscratch --fs-license-file /opt/freesurfer/license.txt
	elif [ "${longitudinal}" == "no" ];
	then
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-21.0.1.sif fmriprep /datain/bids /datain/bids/derivatives participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} --use-aroma -w /paulscratch --fs-license-file /opt/freesurfer/license.txt
	fi


	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep finished $NOW" >> ${scripts}/fulltimer.txt

	#rm -rf ${TMPSING}/*
	#rm -rf ${CACHESING}/*
	chmod 2777 -R ${projDir}/bids/derivatives/fmriprep
	
	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} fmriprep ${based}

	#ASHS
	export SINGULARITYENV_ASHS_ROOT=/opt/ashs/ashs-1.0.0
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}:/datain $IMAGEDIR/ashs3T-v1.0.0.sif $SINGULARITYENV_ASHS_ROOT/bin/ashs_main.sh -a /opt/ashs/ashs_atlas_upennpmc_20170810 -g /datain/bids/${subject}/${sesname}/anat/${subject}_${sesname}_T1w.nii.gz -f /datain/bids/${subject}/${sesname}/anat/${subject}_${sesname}_acq-highreshippocampus_run-1_T2w.nii.gz -w /datain/bids/derivatives/ashs/${subject}/${sesname}

	if [ -d "${projDir}/bids/${subject}/${sesname}/func" ];
        then
		
		#copy freesurfer to fmriprep so xcpEngine can find it
		cd ${projDir}/bids/derivatives
		mkdir ./fmriprep/freesurfer
		cp -R ./freesurfer/fsaverage ./fmriprep/freesurfer/fsaverage
		cp -R ./freesurfer/${subject} ./fmriprep/freesurfer/${subject}	
	
		chmod 2777 -R ${projDir}/bids/derivatives/fmriprep
		cd ${projDir}

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-36p started $NOW" >>	${scripts}/fulltimer.txt
		
		#generate xcpEngine cohorts for a new subject
		${scripts}/func_cohort_maker.sh ${subject} ${sesname} yes


		#xcpEngine 36p
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jqjo.sif /scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no" "1.2.4"
		cp ${scripts}/xcpEngineDesigns/*_gh.dsn ${projDir}/
		cd ${projDir}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.4.sif -d /data/fc-36p_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_minimal_func -r /data/bids -i /tmpdir
		chmod 2777 -R ${projDir}/bids/derivatives/xcp*
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/${subject}_${sesname}_quality_fc36p.csv
		${scripts}/procd.sh ${project} xcp no ${subject} ${based}

		#make different project_doc conditions for different xcpEngine dsns

		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} xcp36p ${based}

		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_minimal_func" "${subject}"
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/fc36p
		chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/fc36p
		cp ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/fc36p/
		

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-36p finished $NOW" >> ${scripts}/fulltimer.txt
		

        NOW=$(date +"%m-%d-%Y-%T")
        echo "xcpEngine fc-36p despike started $NOW" >> ${scripts}/fulltimer.txt

        #xcpEngine 36p despike
        cd ${projDir}
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.4.sif -d /data/fc-36p_despike_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_despike -r /data/bids -i /tmpdir
        chmod 2777 -R ${projDir}/bids/derivatives/xcp*
        mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_despike/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/${subject}_${sesname}_quality_despike.csv


        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_despike" "${subject}"
        mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike
        chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike
        cp ${projDir}/bids/derivatives/xcp/${sesname}/xcp_despike/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike/


        NOW=$(date +"%m-%d-%Y-%T")
        echo "xcpEngine fc-36p despike finished $NOW" >> ${scripts}/fulltimer.txt


		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-36p_scrub started $NOW" >> ${scripts}/fulltimer.txt

		#xcpEngine 36p_scrub
		cd ${projDir}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.4.sif -d /data/fc-36p_scrub_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_scrub -r /data/bids -i /tmpdir
		chmod 2777 -R /projects/BICpipeline/Pipeline_Pilot/TestingFork/${project}/bids/derivatives/xcp*
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_scrub/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/${subject}_${sesname}_quality_scrub.csv

		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} xcp36pscrub ${based}

		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_scrub" "${subject}" 
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/scrub
		chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/scrub
		cp ${projDir}/bids/derivatives/xcp/${sesname}/xcp_scrub/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/scrub/
#		rm ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/*txt

		NOW=$(date +"%m-%d-%Y-%T")
	
		echo "xcpEngine fc-36p_scrub finished $NOW" >> ${scripts}/fulltimer.txt

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-aroma started $NOW" >> ${scripts}/fulltimer.txt

		#xcpEngine aroma
		cd ${projDir}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.4.sif -d /data/fc-aroma_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma -r /data/bids -i /tmpdir
		chmod 2777 -R ${projDir}/bids/derivatives/xcp*
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/${subject}_${sesname}_quality_aroma.csv 

		${scripts}/procd.sh $project xcp no ${subject} ${based}
		cp ${scripts}/projdoc.css ${based}/batchproc/${project}/${project}_sample.css

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-aroma finished $NOW" >> ${scripts}/fulltimer.txt

		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_minimal_aroma" "${subject}" 
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs
		chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs/

		#rm -rf ${CACHESING}/*
		#rm -rf ${TMPSING}/*

		#generate xcpEngine cohorts for a new subject
        ${scripts}/func_task_cohort_maker.sh ${subject} ${sesname} yes nback $based ${project} beta
        #xcpEngine 36p
        cp ${scripts}/xcpEngineDesigns/task.dsn ${projDir}/
        cp -R ${scripts}/task.feat ${projDir}/bids/derivatives/
        num=$(echo "$subject" | cut -d- -f2)
        #sed -i 's+old-text+new-text+g' input.txt
        cd ${projDir}/bids/derivatives/task.feat/
        sed -i 's+/software/fsl-5.0.10-x86_64+/opt/fsl-5.0.10+g' design.fsf
        sed -i 's+/shared/mrfil-data/pcamach2/SAY/bids/derivatives/fmriprep/sub-SAY244/ses-A/func/nback1onset.txt+/data/bids/derivatives/task.feat/custom_timing_files/ev1.txt+g' design.fsf
        sed -i 's+/shared/mrfil-data/pcamach2/SAY/bids/derivatives/fmriprep/sub-SAY244/ses-A/func/nback2onset.txt+/data/bids/derivatives/task.feat/custom_timing_files/ev2.txt+g' design.fsf
        sed -i 's+/shared/mrfil-data/pcamach2/SAY+/data+g' design.fsf
        sed -i "s+SAY244+${num}+g" design.fsf
        cd ${projDir}
        mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_36p_nback
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.3.sif -d /data/task.dsn -c /data/cohort_func_task-nback_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_36p_nback -r /data/bids -i /tmpdir
        chmod 2777 -R ${projDir}/bids/derivatives/xcp*
	
	if [ -d "${projDir}/bids/${subject}/${sesname}/dwi" ];
        then

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
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jqjo.sif /scripts/project_doc.sh ${project} ${subject} ${sesname} "qsiprep" "no" "0.15.1"
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep started $NOW" >> ${scripts}/fulltimer.txt


		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${IMAGEDIR}/license.txt:/opt/freesurfer/license.txt,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.15.1.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject}

		chmod 777 -R ${projDir}/bids/derivatives/qsiprep
		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} QSIprep ${based}
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep finished $NOW" >> ${scripts}/fulltimer.txt

		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jqjo.sif /scripts/project_doc.sh ${project} ${subject} ${sesname} "qsirecon" "no" "0.15.1"
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep CSD Recon started $NOW" >> ${scripts}/fulltimer.txt

		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${IMAGEDIR}/license.txt:/opt/freesurfer/license.txt,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.15.1.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec mrtrix_multishell_msmt_ACT-hsvs --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject}

		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep CSD Recon finished $NOW" >> ${scripts}/fulltimer.txt
		chmod 777 -R ${projDir}/bids/derivatives/qsirecon

		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/qsirecon:/data ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

		${scripts}/pdf_printer.sh ${projID} ${subject} ${sesname} QSIprepRecon ${based}
		mv ${projDir}/bids/derivatives/qsirecon/${subject}* ${projDir}/bids/derivatives/qsicsd
 
    NOW=$(date +"%m-%d-%Y-%T")
    echo "QSIprep GQI Recon started $NOW" >> ${scripts}/fulltimer.txt
    SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${IMAGEDIR}/license.txt:/opt/freesurfer/license.txt,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.15.1.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec dsi_studio_gqi --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject}
    NOW=$(date +"%m-%d-%Y-%T")
    echo "QSIprep GQI Recon finished $NOW" >> ${scripts}/fulltimer.txt
    chmod 777 -R ${projDir}/bids/derivatives/qsirecon


    ${scripts}/pdf_printer.sh ${projID} ${subject} ${sesname} QSIprepRecon ${based}
		mv ${projDir}/bids/derivatives/qsirecon/${subject}* ${projDir}/bids/derivatives/qsigqi

    NOW=$(date +"%m-%d-%Y-%T")
    echo "QSIprep NODDI AMICO Recon started $NOW" >> ${scripts}/fulltimer.txt
    SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${IMAGEDIR}/license.txt:/opt/freesurfer/license.txt,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.15.1.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec amico_noddi --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --fs-license-file /opt/freesurfer/license.txt --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject} 
    NOW=$(date +"%m-%d-%Y-%T")
    echo "QSIprep NODDI Recon finished $NOW" >> ${scripts}/fulltimer.txt
    chmod 777 -R ${projDir}/bids/derivatives/qsirecon

    ${scripts}/pdf_printer.sh ${projID} ${subject} ${sesname} QSIprepRecon ${based}
		mv ${projDir}/bids/derivatives/qsirecon/${subject}* ${projDir}/bids/derivatives/qsiamiconoddi

		mkdir $projDir/bids/derivatives/fsl
		mkdir $projDir/bids/derivatives/fsl/${subject}
		mkdir $projDir/bids/derivatives/fsl/${subject}/${sesname}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${projDir}/bids/derivatives/fsl/${subject}/${sesname}:/fslin --bind ${projDir}/bids/derivatives/qsiprep/${subject}/${sesname}/dwi:/datain $IMAGEDIR/fsl_601.sif dtifit -k /datain/${subject}_${sesname}_run-1_space-T1w_desc-preproc_dwi.nii.gz -o /fslin/sub-SAY244_ses-A_run-1_space-T1w_desc-DTIFIT -m /datain/${subject}_${sesname}_run-1_space-T1w_desc-brain_mask.nii.gz -r /datain/${subject}_${sesname}_run-1_space-T1w_desc-preproc_dwi.bvec -b /datain/${subject}_${sesname}_run-1_space-T1w_desc-preproc_dwi.bval --kurt --save_tensor
		
		NOW=$(date +"%m-%d-%Y-%T")
    echo "QSIprep reorient_fslstd Recon started $NOW" >> ${scripts}/fulltimer.txt
    SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${IMAGEDIR}/license.txt:/opt/freesurfer/license.txt,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.15.1.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec reorient_fslstd --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 2.5 -w /paulscratch participant --participant-label ${subject} 
    NOW=$(date +"%m-%d-%Y-%T")
   	echo "QSIprep reorient_fslstd Recon finished $NOW" >> ${scripts}/fulltimer.txt
    echo "See docs for details on running SCFSL DTI probabilistic tractography (CUDA 10.2 GPU required)"
	fi
fi
${scripts}/pipeline_collate_ext.sh -p ${project} -z ${subject} -s ${sesname} -b ${based} -t beta -e ${address}

fi

