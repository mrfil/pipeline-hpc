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
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/datain $IMAGEDIR/heudiconv0.6.simg heudiconv -d /datain/{subject}/{session}/scans/*/DICOM/*dcm -f /datain/${project}_heuristic.py -o /datain/bids/sourcedata -s ${sub} -ss ${ses} -c dcm2niix -b
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

	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${projDir}/bids/sourcedata:/data --bind ${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-0.16.0.sif /data /out participant --participant-label ${sub} --session-id ${ses} --fft-spikes-detector --despike --no-sub
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

	cd ${projDir}

	mkdir ${projDir}/bids/derivatives/mriqc
	chmod 777 -R ${projDir}/bids/derivatives/mriqc

	TEMPLATEFLOW_HOST_HOME=$IMAGEDIR/templateflow
	export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"
	
	mkdir ${projDir}/bids/sourcedata
	cp ${projDir}/bids/*json ${projDir}/bids/sourcedata/
	cp -R ${projDir}/bids/${subject} ${projDir}/bids/sourcedata/

	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep started $NOW" >> ${scripts}/fulltimer.txt

	#fmriprep
	echo "Running fmriprep on $subject $sesname"
	#add more details of fMRIPrep arguments if necessary

	${scripts}/project_doc.sh ${project} ${subject} ${sesname} "fmriprep" "no"
	if [ "${longitudinal}" == "yes" ];
	then 
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-v22.0.1.sif fmriprep /datain/bids /datain/bids/derivatives participant --participant-label ${subject} --longitudinal --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} --use-aroma -w /paulscratch --fs-license-file /opt/freesurfer/license.txt
	elif [ "${longitudinal}" == "no" ];
	then
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-v22.0.1.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} --use-aroma -w /paulscratch --fs-license-file /opt/freesurfer/license.txt
	fi


	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep finished $NOW" >> ${scripts}/fulltimer.txt

	#rm -rf ${TMPSING}/*
	#rm -rf ${CACHESING}/*
	chmod 2777 -R ${projDir}/bids/derivatives/fmriprep
	
	cd ${projDir}/bids/derivatives
        mkdir ./fmriprep/freesurfer
	cp -R ./sourcedata/freesurfer/fsaverage ./fmriprep/freesurfer/fsaverage
	cp -R ./sourcedata/freesurfer/${subject} ./fmriprep/freesurfer/${subject}	
	
	chmod 2777 -R ${projDir}/bids/derivatives/fmriprep
	cd ${projDir}

	NOW=$(date +"%m-%d-%Y-%T")
	echo "xcpEngine fc-36p started $NOW" >>	${scripts}/fulltimer.txt
	#generate xcpEngine cohorts for a new subject
	${scripts}/func_cohort_maker.sh ${subject} ${sesname} yes

	#xcpEngine 36p
	$scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no"
	cp ${scripts}/xcpEngineDesigns/*_gh.dsn ${projDir}/
	cd ${projDir}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-v1.2.4.sif -d /data/fc-36p_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_minimal_func -r /data/bids -i /tmpdir
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
        $scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no"
        cd ${projDir}
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-v1.2.4.sif -d /data/fc-36p_despike_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_despike -r /data/bids -i /tmpdir
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
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-v1.2.4.sif -d /data/fc-36p_scrub_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_scrub -r /data/bids -i /tmpdir
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
	$scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no"
	cd ${projDir}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-v1.2.4.sif -d /data/fc-aroma_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma -r /data/bids -i /tmpdir
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

        #generate xcpEngine cohorts for a new subject
        ${scripts}/func_task_cohort_maker.sh ${subject} ${sesname} yes nback $based ${project} beta


        #xcpEngine 36p
#       $scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no"
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
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-v1.2.4.sif -d /data/task.dsn -c /data/cohort_func_task-nback_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_36p_nback -r /data/bids -i /tmpdir
        chmod 2777 -R ${projDir}/bids/derivatives/xcp*

fi
echo "collecting info from DICOM headers"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/${sub}/${ses}/dir/SCANS:/datain,${scripts}:/scripts ${IMAGEDIR}/bidscoin.sif python /scripts/dicominfo.py
mv ${projDir}/${sub}/${ses}/dir/SCANS/stats.csv ${projDir}/bids/derivatives/${subject}_${sesname}_stats.csv

${scripts}/pipeline_collate_SAY.sh -p ${project} -z ${subject} -s ${sesname} -b ${based} -t beta

fi


