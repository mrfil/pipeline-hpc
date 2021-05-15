#!/bin/bash
#
# procd copies the outputs of a batch processing run to the project's ${procdir}/${project} directory
# when available, the pipeline txt file containing the stdout from the associated processing pipeline is also copied for sbatch runs
# 
#	SHOULD also copy the project xml file produced by project_doc.sh as applicable, along with pipeline xml files describing the steps of the pipelines
#	
# when the pipeline has been previously run on the dataset, procd will create a new version of the folder with the date appended to distinguish between runs
#
# usage: procd.sh {project} {step} {batch? (yes/no=default)} {subject}
#
# example procd.sh MBB fmriprep yes sub-MBB001


#copying xcpengine fails due to session

project=$1
step=$2
batch=$3
subject=$4
based=$5
session=$6
now=$(date +"%m-%d-%Y-%T")

#switch to version
forkdir=${based}/beta/testing
procdir=${based}/beta/output

if [ -d "$procdir" ];
then
	echo "Sending data to $procdir"
else
	mkdir $procdir
	chmod 777 -R $procdir
fi

if [ "${batch}" == yes ];
then

if [ -d ${procdir}/${project} ];
then
	if [ -d ${procdir}/${project}/bids ];
	then
		if [ -d ${procdir}/${project}/bids/derivatives/${step} ];
		then
			cp -R ${forkdir}/${project}/bids/derivatives/${step} ${procdir}/${project}/bids/derivatives/${step}_${now}
		else
			cp -R ${forkdir}/${project}/bids/derivatives/${step} ${procdir}/${project}/bids/derivatives/
		fi
	else
		cp -R ${forkdir}/${project}/bids ${procdir}/${project}/
	fi

else
	mkdir ${procdir}/${project}
	cp -R ${forkdir}/${project}/bids ${procdir}/${project}/
fi

echo ${now} > ${procdir}/${project}/${project}_${step}_doc.txt

else

if [ -d ${procdir}/${project} ];
then
        if [ -d ${procdir}/${project}/bids ];
        then
                cp -R ${forkdir}/${project}/bids/derivatives/${step}/${subject} ${procdir}/${project}/bids/derivatives/${step}/${subject}
        else
                cp -R ${forkdir}/${project}/bids ${procdir}/${project}/
        fi

else
        mkdir ${procdir}/${project}
        cp -R ${forkdir}/${project}/bids ${procdir}/${project}/
fi

echo ${now} > ${procdir}/${project}/${project}_${step}_doc.txt

fi
