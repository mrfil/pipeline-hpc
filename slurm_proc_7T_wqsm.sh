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

pilotdir=${based}/original_location_of_images_from_XNAT
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
cp -R ${pilotdir}/${DIR} ${tmpdir}/${project}/${CLEANSUBJECT}/${session}

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
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/datain $IMAGEDIR/heudiconv0.6.simg heudiconv -d /datain/{subject}/{session}/*/scans/*/DICOM/*dcm -f /datain/${project}_heuristic.py -o /datain/bids -s ${sub} -ss ${ses} -c dcm2niix -b
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
	${scripts}/project_doc.sh ${project} ${subject} ${sesname} "heudiconv" "yes"
	ses=${sesname:4}
	sub=${subject:4}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}:/datain ${IMAGEDIR}/heudiconv0.6.simg heudiconv -d /datain/{subject}/{session}/*/*/*/* -f /datain/${project}_heuristic_HCP.py -o /datain/bids --minmeta -s ${sub} -ss ${ses} -c dcm2niix -b --overwrite 
	chmod 2777 -R ${projDir}/bids
#        mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-1_T1w.nii.gz ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageinv_T1w.nii.gz
#        mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-1_T1w.json ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageinv1_T1w.json
#        mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-2_T1w.nii.gz ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageinv2_T1w.nii.gz
#        mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-2_T1w.json ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageinv2_T1w.json
#        mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w.nii.gz ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_T1w.nii.gz
#        mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w.json ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_T1w.json
	rm -rf __pycache__
	rm -rf $CACHESING/*
	rm -rf $TMPSING/*

	NOW=$(date +"%m-%d-%Y-%T")
	echo "HeuDiConv finished $NOW" >> ${scripts}/fulltimer.txt

	if [ "${fieldmaps}" == "yes" ];
	then
	    SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jq-0.1.sif /scripts/jsoncrawler.sh /data/bids ${sesname} ${subject}
	fi
	
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/tmp
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/test.txt	

	mkdir ${based}/${version}/output/${project}

	mkdir ${projDir}/bids/derivatives

	cd ${projDir}

	mkdir ${projDir}/bids/derivatives/mriqc
	chmod 777 -R ${projDir}/bids/derivatives/mriqc

	mkdir ${projDir}/bids/derivatives/swi 
        mkdir ${projDir}/bids/derivatives/swi/${subject}
        mkdir ${projDir}/bids/derivatives/swi/${subject}/${sesname}
	mkdir ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out
	cp ${projDir}/${sub}/${ses}/*/*/ASPIRE_P_KE_GRE_ASPIRERELEASE*/*IMA ${projDir}/bids/derivatives/swi/${subject}/${sesname}/
  	cp ${projDir}/${sub}/${ses}/*/*/ASPIRE_M_KE_GRE_ASPIRERELEASE*/*IMA ${projDir}/bids/derivatives/swi/${subject}/${sesname}/
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.1 (see scripts/matlab/ndi_qsm_fp1.sh)"
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp1.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./${subject}_${sesname}_ndi_mag.nii
	mv ./ndi_out/phs.nii ./${subject}_${sesname}_ndi_phs.nii
	mv ./ndi_out/qsm.nii ./${subject}_${sesname}_ndi_qsm.nii
	
	cd $projDir	

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
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},${projDir}/bids:/data,${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-0.16.1.sif /data /out participant --participant-label ${sub} --session-id ${ses} -v --fft-spikes-detector --despike --no-sub
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
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-20.2.1.sif fmriprep /datain/bids /datain/bids/derivatives participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym:res-2,T1w,fsnative:res-2} -w /paulscratch --use-aroma --fs-license-file /opt/freesurfer/license.txt
	fi


	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep finished $NOW" >> ${scripts}/fulltimer.txt

	rm -rf ${TMPSING}/*
	rm -rf ${CACHESING}/*
	chmod 2777 -R ${projDir}/bids/derivatives/fmriprep
	
	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} fmriprep ${based}

	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out
	roi_names=$scripts/aparc_cort_subcort_labels.txt
	acqtag="_acq-mp2rageunidenoised_"
	
	echo "afni deoblique and resample fmriprep anat outputs"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 0.6875 0.6875 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 0.6875 0.6875 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz
	
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_mag.nii
	#flirt transform routine
	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost mutualinfo -dof 6 -in /dataqsm/mag_restore.nii.gz -ref /dataqsm/resample_card_"$subject"_"$session""$acqtag"desc-preproc_T1w.nii.gz -omat /dataqsm/swi2rage.mat -out /dataqsm/mag_in_rage.nii.gz
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/rage2swi.mat -inverse /dataqsm/swi2rage.mat
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp nearestneighbour -in /dataqsm/resample_card_"$subject"_"$session""$acqtag"desc-aparcaseg_dseg.nii.gz -ref /dataqsm/mag_restore.nii.gz -applyxfm -init /dataqsm/rage2swi.mat -out /dataqsm/FS_to_SWI.nii.gz
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats.sh ${subject} ${sesname}


	export SINGULARITYENV_ASHS_ROOT=/opt/ashs/ashs-1.0.0
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}:/datain $IMAGEDIR/ashs-1.0.0.sif $SINGULARITYENV_ASHS_ROOT/bin/ashs_main.sh -a /opt/ashs/ashs_atlas_umcutrecht_7t_20170810 -g /datain/bids/${subject}/${sesname}/anat/${subject}_${sesname}_acq-mp2rageunidenoised_T1w.nii.gz -f /datain/bids/${subject}/${sesname}/anat/${subject}_${sesname}_acq-highreshippocampus_run-1_T2w.nii.gz -w /datain/bids/derivatives/ashs/${subject}/${sesname} 

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
		$scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no"
		cp ${scripts}/xcpEngineDesigns/*_gh.dsn ${projDir}/
		cd ${projDir}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.3.sif -d /data/fc-36p_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_minimal_func -r /data/bids -i /tmpdir
		chmod 2777 -R ${projDir}/bids/derivatives/xcp*
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/${subject}_${sesname}_quality_fc36p.csv
		${scripts}/procd.sh ${project} xcp no ${subject} ${based}

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
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.3.sif -d /data/fc-36p_despike_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_despike -r /data/bids -i /tmpdir
        chmod 2777 -R ${projDir}/bids/derivatives/xcp*
        mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_despike/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/${subject}_${sesname}_quality_despike.csv


        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_despike" "${subject}"
        mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike
        chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike
        cp ${projDir}/bids/derivatives/xcp/${sesname}/xcp_despike/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike/
${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} xcp36pdespike ${based}

        NOW=$(date +"%m-%d-%Y-%T")
        echo "xcpEngine fc-36p despike finished $NOW" >> ${scripts}/fulltimer.txt


		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-36p_scrub started $NOW" >> ${scripts}/fulltimer.txt

		#xcpEngine 36p_scrub
		cd ${projDir}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.3.sif -d /data/fc-36p_scrub_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_scrub -r /data/bids -i /tmpdir
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
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.3.sif -d /data/fc-aroma_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma -r /data/bids -i /tmpdir
		chmod 2777 -R ${projDir}/bids/derivatives/xcp*
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/${subject}_${sesname}_quality_aroma.csv 

		${scripts}/procd.sh $project xcp no ${subject} ${based}
		cp ${scripts}/projdoc.css ${based}/batchproc/${project}/${project}_sample.css
		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} xcpfcaroma ${based}

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-aroma finished $NOW" >> ${scripts}/fulltimer.txt

		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_minimal_aroma" "${subject}" 
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs
		chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs/

		rm -rf ${CACHESING}/*
		rm -rf ${TMPSING}/*
	
	
	if [ -d "${projDir}/bids/${subject}/${sesname}/dwi" ];
        then

		IMAGEDIR=${based}/singularity_images
		scripts=${based}/${version}/scripts
		projDir=${based}/${version}/testing/${project}
		scachedir=${based}/${version}/scratch/scache/${project}/${sesname}
		stmpdir=${based}/${version}/scratch/stmp/${project}/${sesname}

		mkdir ${based}/${version}/scratch/scache/${project}
		mkdir ${based}/${version}/scratch/stmp/${project}
		mkdir ${based}/${version}/scratch/scache/${project}/${sesname}
		mkdir ${based}/${version}/scratch/stmp/${project}/${sesname}
		chmod 777 -R ${stmpdir}
		chmod 777 -R ${scachedir}
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep started $NOW" >> ${scripts}/fulltimer.txt

		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.13.0RC2.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --output-resolution 2.0 -w /paulscratch participant --participant-label ${subject}

		chmod 777 -R ${projDir}/bids/derivatives/qsiprep
		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} QSIprep ${based}
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep finished $NOW" >> ${scripts}/fulltimer.txt
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep Recon started $NOW" >> ${scripts}/fulltimer.txt
		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.13.0RC2.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec mrtrix_multishell_msmt --output-resolution 2.0 -w /paulscratch participant --participant-label ${subject}
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep Recon finished $NOW" >> ${scripts}/fulltimer.txt
		chmod 777 -R ${projDir}/bids/derivatives/qsirecon

		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/qsirecon:/data ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

	
		${scripts}/pdf_printer.sh ${projID} ${subject} ${sesname} QSIprepRecon ${based}
	fi
fi
${scripts}/pipeline_collate.sh -p ${project} -z ${subject} -s ${sesname} -b ${based} -t terra
mkdir ${bids_out}/${project}
#mv ${tmpdir}/bids ${bids_out}/${project} 

fi

