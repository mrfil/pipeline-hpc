#!/bin/bash
#
#SBATCH --job-name=dcm2all
#SBATCH --output=dcm2all_A_hdc0.6.txt
#SBATCH --ntasks-per-node=1
#SBATCH --time=99:00:00

proj=$2
based=$3
version=$4
scripts=${based}/${version}/scripts

NOW=$(date "+%D-%T")
if [ ${#SLURM_ARRAY_TASK_ID} == 1 ];
then
        inputNo="00${SLURM_ARRAY_TASK_ID}"
	echo "$1 started $NOW" > ${scripts}/dyno_$1_test_${inputNo}.txt

	${scripts}/$1 -p ${proj} -z ${proj}${inputNo} -s A -m no -f yes -l no -b ${based} -t terra

	NOW=$(date "+%D-%T")
	echo "$1 finished $NOW" >> ${scripts}/dyno_$1_test_${inputNo}.txt
	exit 0
elif [ ${#SLURM_ARRAY_TASK_ID} == 2 ];
then
        inputNo="0${SLURM_ARRAY_TASK_ID}"
        echo "$1 started $NOW" > ${scripts}/dyno_$1_test_${inputNo}.txt

        ${scripts}/$1 -p ${proj} -z ${proj}${inputNo} -s ${proj}${inputNo}A -m no -f yes -l no -b ${based} -t terra

        NOW=$(date "+%D-%T")
        echo "$1 finished $NOW" >> ${scripts}/dyno_$1_test_${inputNo}.txt
        exit 0
elif [ ${#SLURM_ARRAY_TASK_ID} == 3 ];
then
        inputNo="${SLURM_ARRAY_TASK_ID}"
        echo "$1 started $NOW" > ${scripts}/dyno_$1_test_${inputNo}.txt

        ${scripts}/$1 -p ${proj} -z ${proj}${inputNo} -s ${proj}${inputNo}A -m no -f yes -l no -b ${based} -t terra

        NOW=$(date "+%D-%T")
        echo "$1 finished $NOW" >> ${scripts}/dyno_$1_test_${inputNo}.txt
        exit 0
elif [ ${#SLURM_ARRAY_TASK_ID} == 4 ];
then
        inputNo="${SLURM_ARRAY_TASK_ID}"
        echo "$1 started $NOW" > ${scripts}/dyno_$1_test_${inputNo}.txt

        ${scripts}/$1 -p ${proj} -z ${proj}${inputNo} -s ${proj}${inputNo}A -m no -f yes -l no -b ${based} -t terra

        NOW=$(date "+%D-%T")
        echo "$1 finished $NOW" >> ${scripts}/dyno_$1_test_${inputNo}.txt
        exit 0
fi
