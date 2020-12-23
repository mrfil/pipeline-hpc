#!/bin/bash
#
#generate xcpEngine cohorts for a new subject
#
#	func_cohort_maker.sh {subject} {session} {fresh file? yes/no}
#
subject=$1
sesname=$2
fresh=$3


#If you wish to run a dataset for a participant for the first time or multiple participants individually to benefit the cluster nodes, set the fresh argument to yes
if [ $fresh == "yes" ];
then
	echo "Generating new cohort_func file for xcpEngine"	
	echo "id0,img" > cohort_func_${subject}_${sesname}.csv
	echo "${subject},derivatives/fmriprep/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz" >> cohort_func_${subject}_${sesname}.csv

elif [ $fresh == "no" ];
then
	echo "Adding to cohort_func file for group processing in xcpEngine"
	echo "If you are not interested in generating group-level outputs, consider running each subject with a fresh cohort_func.csv"
	if [ -f "cohort_func.csv" ];
	then
		echo "${subject},derivatives/fmriprep/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz" >> cohort_func_${subject}_${sesname}.csv
	else
		echo "id0,img" > cohort_fun_c${subject}_${sesname}.csv
        	echo "${subject},derivatives/fmriprep/${subject}/${sesname}/func/${subject}_${sesname}_task-rest_dir-PA_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz" >> cohort_func_${subject}_${sesname}.csv
	fi
fi

chmod 777 cohort_func.csv
