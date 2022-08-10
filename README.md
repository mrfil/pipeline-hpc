# pipeline-hpc: Pipeline for processing DICOMs to resting-state functional connectivity and structural connectivity matrices and basic network-based statistics via BIDS App Singularity containers on Bright 9 HPCs. Pre-release beta version.

[![Read the Docs (version)](https://img.shields.io/readthedocs/pipeline-hpc/latest)](https://pipeline-hpc.readthedocs.io/en/latest)

## Requirements: 

Singularity BIDS apps (HeuDiConv, MRIQC, fMRIPrep, xcpEngine, QSIprep) 

Singularity image of Matlab R2019a (how to: https://github.com/mathworks-ref-arch/matlab-dockerfile) 

Singularity image of Ubuntu with JQ installed Singularity image of Python3 (Based on Docker python/3.9.0) 

Singularity image of Docker HTML to PDF (https://github.com/pinkeen/docker-html-to-pdf) 

Brain Connectivity Toolbox for Matlab (https://sites.google.com/site/bctnet/Home/functions/BCT.zip?attredirects=0) 

xcpEngine dsn files (https://github.com/PennBBL/xcpEngine/tree/master/designs)

## Documentation

Visit our readthedocs site for more details https://pipeline-hpc.readthedocs.io/en/latest/About.html


### HTML Report Tools

Python-based Quality Control report generator developed by Nishant Bhamidipati and Paul Camacho (https://github.com/mrfil/html-qc-reports):

```
git clone https://github.com/mrfil/html-qc-reports.git
```
