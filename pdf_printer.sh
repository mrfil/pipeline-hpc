#!/bin/bash
#
#	usage: pdf_printer.sh {project} {subject} {session} {step (mriqc fmriprep xcp36p xcp36pscrub)}
#

project=$1
subject=$2
session=$3
step=$4
based=$5
NOW=$(date +"%m-%d-%Y-%T")

IMGDIR=${based}/singularity_images
projDir=${based}/beta/testing/${project}
projPrepDir=${projDir}/bids/derivatives/fmriprep
projXCPdir=${projDir}/bids/derivatives/xcp/${session}/xcp_minimal_func/${subject}
repDir=${based}/beta/data_qc
mkdir $repDir/${project}

chmod 777 -R ${projDir}/bids/derivatives

CACHESING=${based}/beta/scratch/scache
TMPSING=${based}/beta/scratch/stmp

if [ "$step" == "mriqc" ];
then
    echo "Rendering MRIQC report for ${subject} ${session}"
	sed '9,93d' ${projDir}/bids/derivatives/mriqc/${subject}_${session}_T1w.html > ${projDir}/bids/derivatives/mriqc/${subject}_${session}_T1w_forprint.html
    mv ${projDir}/bids/derivatives/mriqc/${subject}_${session}_task-rest_dir-PA*_bold.html ${projDir}/bids/derivatives/mriqc/${subject}_${session}_task-rest_dir-PA_run-1_bold.html
	sed '9,93d' ${projDir}/bids/derivatives/mriqc/${subject}_${session}_task-rest_dir-PA_run-1_bold.html > ${projDir}/bids/derivatives/mriqc/${subject}_${session}_task-rest_dir-PA_rec-uncorrected_run-1_bold_forprint.html
	sed '9,93d' ${projDir}/bids/derivatives/mriqc/${subject}_${session}_T2w.html > ${projDir}/bids/derivatives/mriqc/${subject}_${session}_T2w_forprint.html
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projDir}/bids/derivatives/mriqc:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/${subject}_${session}_T1w_forprint.html --pdf /workspace/mriqc_${subject}_${session}_T1w.pdf
    SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projDir}/bids/derivatives/mriqc:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/${subject}_${session}_task-rest_dir-PA_rec-uncorrected_run-1_bold_forprint.html --pdf /workspace/mriqc_${subject}_${session}_restingstatebold.pdf
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projDir}/bids/derivatives/mriqc:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/${subject}_${session}_T2w_forprint.html --pdf /workspace/mriqc_${subject}_${session}_T2w.pdf
	chmod 777 -R ${projDir}/bids/derivatives/mriqc
    cp ${projDir}/bids/derivatives/mriqc/mriqc_${subject}_${session}_T1w.pdf ${repDir}/${project}/mriqc_${subject}_${session}_T1w_${NOW}.pdf
	cp ${projDir}/bids/derivatives/mriqc/mriqc_${subject}_${session}_restingstatebold.pdf ${repDir}/${project}/mriqc_${subject}_${session}_restingstatebold_${NOW}.pdf
	cp ${projDir}/bids/derivatives/mriqc/mriqc_${subject}_${session}_T2w.pdf ${repDir}/${project}/mriqc_${subject}_${session}_T2w_${NOW}.pdf

elif [ "$step" == "fmriprep" ];
then
	echo "Rendering fMRIPrep report for ${subject} ${session}"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projPrepDir}:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/${subject}.html --pdf /workspace/fmriprep_${subject}_${session}.pdf
	chmod 777 ${projPrepDir}/*pdf
	cp ${projPrepDir}/fmriprep_${subject}_${session}.pdf ${repDir}/${project}/fmriprep_${subject}_${session}_${NOW}.pdf

elif [ "$step" == "xcp36p" ]; 
then
	echo "Rendering xcpEngine report for ${subject} ${session} from fc-36p.dsn"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projXCPdir}:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/${subject}_report.html --pdf /workspace/xcp_fc-36p_report_${subject}_${session}.pdf
	chmod 777 ${projXCPdir}/*pdf
	cp ${projXCPdir}/xcp_fc-36p_report_${subject}_${session}.pdf ${repDir}/${project}/xcp_fc-36p_report_${subject}_${session}_${NOW}.pdf

elif [ "$step" == "xcp36pscrub" ];
then
	echo "Rendering xcpEngine report for ${subject} ${session} from fc-36p_scrub.dsn"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projXCPdir}:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/${subject}_report.html --pdf /workspace/xcp_fc-36p_scrub_report_${subject}_${session}.pdf
	chmod 777 ${projXCPdir}/*pdf
	cp ${projXCPdir}/xcp_fc-36p_scrub_report_${subject}_${session}.pdf ${repDir}/${project}/xcp_fc-36p_scrub_report_${subject}_${session}_${NOW}.pdf
elif [ "$step" == "FIRSTnew" ];
then
    echo "Rendering FIRSTnew report for ${subject} ${session} from FSL"
    SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projDir}/bids/derivatives/dtipipeline/FIRSTnew/slicesdir:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/index.html --pdf /workspace/FIRSTnew_index_after_${subject}_${session}.pdf        
	chmod 777 ${projDir}/bids/derivatives/dtipipeline/FIRSTnew/slicesdir/*pdf
    cp ${projDir}/bids/derivatives/dtipipeline/FIRSTnew/slicesdir/FIRSTnew_index_after_${subject}_${session}.pdf ${repDir}/${project}/FIRSTnew_index_after_${subject}_${session}_${NOW}.pdf
elif [ "$step" == "QSIprep" ];
then
    echo "Rendering QSIprep report for ${subject} ${session}"
    SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projDir}/bids/derivatives/qsiprep:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/${subject}.html --pdf /workspace/qsiprep_${subject}_${session}.pdf        
	chmod 777 ${projDir}/bids/derivatives/qsiprep/*pdf
    cp ${projDir}/bids/derivatives/qsiprep/qsiprep_${subject}_${session}.pdf ${repDir}/${project}/qsiprep_${subject}_${session}_${NOW}.pdf
elif [ "$step" == "QSIprepRecon" ];
then
    echo "Rendering QSIprep Recon report for ${subject} ${session}"
    SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run -B ${projDir}/bids/derivatives/qsirecon:/workspace ${IMGDIR}/dev/html2pdf.sif --landscape --url http://127.0.0.1:8088/${subject}.html --pdf /workspace/qsirecon_${subject}_${session}.pdf        
	chmod 777 ${projDir}/bids/derivatives/qsirecon/*pdf
    cp ${projDir}/bids/derivatives/qsirecon/qsirecon_${subject}_${session}.pdf ${repDir}/${project}/qsirecon_${subject}_${session}_${NOW}.pdf
fi



