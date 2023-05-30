#!/bin/bash
#
# Generates Singularity images used in pipeline
# Run on a machine which has sufficient permissions for Singularity and Docker building!
# Install git prior to running
# Please cite the images used and retrieve all relevant licenses
# You will need your own Freesurfer license for some containers
#

mkdir ./singularity_images
chmod 777 -R ./singularity_images
cd ./singularity_images

singularity build mriqc-0.16.1.sif docker://poldracklab/mriqc:0.16.1
singularity build heudiconv-0.9.0.sif docker://nipy/heudiconv:0.9.0
singularity build fmriprep-22.0.1.sif docker://nipreps/fmriprep:22.0.1
singularity build xcpengine-1.2.4.sif docker://pennbbl/xcpengine:1.2.4
singularity build bidsphysio.sif docker://cbinyu/bidsphysio
#for reorient_fslstd to prepare for SCFSL_GPU
singularity build qsiprep-v0.16.1.sif docker://pennbbl/qsiprep:0.16.1


# See README.md for more information on 
#provide def files for ubuntu-jq, python3
sudo SINGULARITY_NOHTTPS=1 singularity build ubuntu-jqjo.sif jqjo.def
sudo SINGULARITY_NOHTTPS=1 singularity build python3.sif defpy3
sudo SINGULARITY_NOHTTPS=1 singularity build bidscoin.sif bidscoindef
sudo SINGULARITY_NOHTTPS=1 singularity build laynii-2.0.0.sif layniidef
sudo SINGULARITY_NOHTTPS=1 singularity build ashs-1.0.0.sif ashsdef
sudo SINGULARITY_NOHTTPS=1 singularity build pylearn.sif pylearn.def

#Start Docker registry for localhost
docker run -d -p 5000:5000 --restart=always --name registry registry:2

#build jq and jo image for new project_doc.sh
cd ./ubuntu-jqjo
docker build -t localhost:5000/ubuntu-jqjo:0.2 .
docker push localhost:5000/ubuntu-jqjo:0.2
cd ../
SINGULARITY_NOHTTPS=1 singularity build ubuntu-jqjo-v0.2.sif docker://localhost:5000/ubuntu-jqjo:0.2

# Follow directions to build Docker images for the following:
# https://github.com/pinkeen/docker-html-to-pdf
git clone https://github.com/pinkeen/docker-html-to-pdf.git
#cd?
# You will want to set the port used in html2pdf to an unused port on the HPC 
cd ./docker-html-to-pdf
docker build -t html2pdf:79.1 -t localhost:5000/html2pdf:79.1 .
docker push localhost:5000/html2pdf:79.1
cd ../
SINGULARITY_NOHTTPS=1 singularity build html2pdf.sif docker://localhost:5000/html2pdf:79.1

## Prerequisites
#The following examples use the CUDA 10.2 toolkit and runtime (loaded via module or native install)
git clone https://github.com/mrfil/scfsl.git
cd ./scfsl
docker build -t scfsl_gpu:0.3.2 -t localhost:5000/scfsl_gpu:0.3.2 .
cd ../
docker push localhost:5000/scfsl_gpu:0.3.2
SINGULARITY_NOHTTPS=1 singularity build scfsl_gpu-v0.3.2.sif docker://localhost:5000/scfsl_gpu:0.3.2
     
# https://github.com/mathworks-ref-arch/matlab-dockerfile
git clone https://github.com/mathworks-ref-arch/matlab-dockerfile.git
mkdir ./matlab-dockerfile/matlab-install
# place install files and modified license in correct directories per guide in repo
cd ./matlab-dockerfile
docker build -f Dockerfile.R2019a -t matlab:r2019a -t localhost:5000/matlab:r2019a --build-arg MATLAB_RELEASE=R2019a .
cd ../
docker push localhost:5000/matlab:r2019b
SINGULARITY_NOHTTPS=1 singularity build matlab-R2019a.sif docker://localhost:5000/matlab:r2019a

chmod 777 -R ./singularity_images
