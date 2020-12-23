#!/bin/bash
#
#
# file_structure_gen.sh {base directory} {version}

based=$1
version=$2
mkdir ${based}/${version}

#Create directories for the following: 
# 1. During processing data housing
mkdir ${based}/${version}/testing

# 2. Whole dataset and outputs housing
mkdir ${based}/${version}/output

# 3. BIDS outputs & derivatives housing
mkdir ${based}/${version}/bids_only

# 4. Connectivity matrices and node-level network-based statistics housing
mkdir ${based}/${version}/conn_out

# 5. Visual quality control reports and one-liner csv reports
mkdir ${based}/${version}/data_qc

# 6. Scripts directory for current version
mkdir ${based}/${version}/scripts
cp -R ../* ${based}/${version}/scripts

# 7. Scratch directory for tmp and cache
mkdir ${based}/${version}/scratch
mkdir ${based}/${version}/scratch/stmp
mkdir ${based}/${version}/scratch/scache

# 8. Singularity image housing
mkdir ${based}/singularity_images

# change file permissions
chmod 777 -R mkdir ${based}/${version}
