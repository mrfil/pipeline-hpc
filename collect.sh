#!/bin/bash

version=$1
project=$2
based=$3
scripts=`pwd`
NOW=$(date +"%m-%d-%Y")
cd ${based}/${version}/output/${project}
mkdir ./collect
cp ./sub-*/ses*/*pipeline_results.csv ./collect/
singularity exec -B ./collect:/datain,${scripts}/pyscripts:/scripts ${based}/singularity_images/python3-dev.sif python3 /scripts/df_maker.py
cd ./collect
mv outputs.csv pipeline_outputs_${project}_${NOW}.csv
