#!/bin/bash
#
#   Single-subject pipeline output collating to labeled csv
#
#   pipeline_collate.sh -p {project} -z {bidsname of subject} -s {bidsname of session} {base directory} {version}
#
#   Paul Camacho

while getopts :p:s:z:b:t: option; do
	case ${option} in
    	p) export project=$OPTARG ;;
    	s) export session=$OPTARG ;;
    	z) export subject=$OPTARG ;;
        b) export based=$OPTARG ;;
	t) export version=$OPTARG ;;
	esac
done

projDir=${based}/${version}/testing/${project}
mriqcDir=${projDir}/bids/derivatives/mriqc/${subject}/${session}
fmriprepDir=${projDir}/bids/derivatives/fmriprep/${subject}/${session}
xcpDir=${projDir}/bids/derivatives/xcp/${session}
qsiprepDir=${projDir}/bids/derivatives/qsiprep/${subject}/${session}/dwi
qsireconDir=${projDir}/bids/derivatives/qsicsd/${subject}/${session}/dwi
qsianDir=${projDir}/bids/derivatives/qsiamiconoddi/${subject}/${session}/dwi
qsigqiDir=${projDir}/bids/derivatives/qsigqi/${subject}/${session}/dwi
#dtiDir=${projDir}/bids/derivatives/dtipipeline/${subject}/${session}/Analyze/Tracking
#strucconDir=${projDir}/bids/derivatives/structconpipeline/ResStructConn/${subject}/${session}/Conn84
scriptsDir=${based}/${version}/scripts


outputDir=${based}/${version}/output/${project}/${subject}/${session}
NOW=`date +%d-%b-%Y`

if [ -d "$outputDir" ];
then
    echo $outputDir
else
    mkdir ${based}/${version}/output/${project}
    mkdir ${based}/${version}/output/${project}/${subject}   
    mkdir $outputDir
    chmod 777 -R ${based}/${version}/output/${project}
fi

#get all output files with metrics 

echo "Gathering Outputs"

cd $outputDir

SINGCACHE=${based}/${version}/scratch/scache/${project}_${subject}_${session}
mkdir $SINGCACHE
SINGTMP=${based}/${version}/scratch/stmp/${project}_${subject}_${session}
mkdir $SINGTMP

IMAGEDIR=${based}/singularity_images

#mriqc
cp ${mriqcDir}/anat/*T1w.json ${outputDir}/mriqc_T1w.json
cp ${mriqcDir}/anat/*run-1*T2w.json ${outputDir}/mriqc_T2w.json
cp ${mriqcDir}/func/*rest*json ${outputDir}/mriqc_rest_bold.json

SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}:/scripts ${IMAGEDIR}/ubuntu-jq-0.1.sif /scripts/mriqciqms.sh 
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/mriqc_iqms_func_rest.csv /data/${subject}_mriqc_iqms_func_rest.csv
mv ${outputDir}/${subject}_mriqc_iqms_func_rest.csv ${outputDir}/mriqc_iqms_func_rest.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/mriqc_iqms_t1w.csv /data/${subject}_mriqc_iqms_t1w.csv
mv ${outputDir}/${subject}_mriqc_iqms_t1w.csv ${outputDir}/mriqc_iqms_t1w.csv
if [[ -f "${mriqcDir}/anat/*run-1*T2w.json" ]];
then
	SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/mriqc_iqms_t2w.csv /data/${subject}_mriqc_iqms_t2w.csv
	mv ${outputDir}/${subject}_mriqc_iqms_t2w.csv ${outputDir}/mriqc_iqms_t2w.csv
fi

#get quality reports
#cp ${xcpDir}/xcp_minimal_func/${subject}/*quality.csv ${outputDir}/xcp_func_quality_orig.csv
cp ${xcpDir}/xcp_minimal_func/${subject}/*_quality_fc36p.csv ${outputDir}/xcp_func_quality_orig.csv
cp ${xcpDir}/xcp_minimal_func/${subject}/*_quality_despike.csv ${outputDir}/xcp_despike_quality_orig.csv
cp ${xcpDir}/xcp_minimal_func/${subject}/*_quality_scrub.csv ${outputDir}/xcp_scrub_quality_orig.csv
cp ${xcpDir}/xcp_minimal_aroma/${subject}/*quality_aroma.csv ${outputDir}/xcp_aroma_quality_orig.csv
cp ${xcpDir}/xcp_36p_nback/${subject}/*quality.csv ${outputDir}/xcp_fc36p_nback_quality_orig.csv

SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_func_quality_orig.csv /data/xcp_func_quality.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_despike_quality_orig.csv /data/xcp_despike_quality.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_scrub_quality_orig.csv /data/xcp_scrub_quality.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_aroma_quality_orig.csv /data/xcp_aroma_quality.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_fc36p_nback_quality_orig.csv /data/xcp_fc36p_nback_quality.csv

#nbs files
mkdir ${outputDir}/fc36p
mkdir ${outputDir}/despike
mkdir ${outputDir}/scrub
mkdir ${outputDir}/aroma

cp ${xcpDir}/xcp_36p_nback/${subject}/roiquant/aal116/${subject}_aal116_mean_zstat1_2back1back.csv ${outputDir}/${subject}_aal116_mean_zstat1_2back1back.csv
cp ${xcpDir}/xcp_36p_nback/${subject}/roiquant/desikanKilliany/${subject}_desikanKilliany_mean_zstat1_2back1back.csv ${outputDir}/${subject}_desikanKilliany_mean_zstat1_2back1back.csv
cp ${xcpDir}/xcp_36p_nback/${subject}/roiquant/power264/${subject}_power264_mean_zstat1_2back1back.csv ${outputDir}/${subject}_power264_mean_zstat1_2back1back.csv
chmod 777 -R ${outputDir}

if [[ `cat ${xcpDir}/xcp_minimal_func/${subject}/${subject}_logs/${subject}_audit.csv | grep "1,1,1,1,1,1,1,1,1,1"` ]];
then
echo ""
else
echo "XCPengine failure detected in ${subject}_audit.csv" > ${outputDir}/pipeline_error_log.txt
echo "Pipeline processing error detected in XCPengine for ${subject}. Check attached audit files for module failure point" | mail -a ${xcpDir}/xcp_minimal_func/${subject}/${subject}_logs/${subject}_audit.csv -s "Pipeline error detected in XCPengine audit for ${subject}" pcamach2@illinois.edu
fi

cp ${xcpDir}/xcp_minimal_func/${subject}/fcon/nbs/fc36p/*txt ${outputDir}/fc36p/
cp ${xcpDir}/xcp_minimal_func/${subject}/fcon/nbs/fc36p/${subject}_desikanKillianynbs_table.txt ${outputDir}/${subject}_desikanKillianynbs_table_fc36p.csv
cp ${xcpDir}/xcp_minimal_func/${subject}/fcon/nbs/fc36p/${subject}_power264nbs_table.txt ${outputDir}/${subject}_power264nbs_table_fc36p.csv
cp ${xcpDir}/xcp_minimal_func/${subject}/fcon/nbs/fc36p/${subject}_aal116nbs_table.txt ${outputDir}/${subject}_aal116nbs_table_fc36p.csv

SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_desikanKillianynbs_table_fc36p.csv /data/${subject}_${session}_desikanKillianynbs_table_fc36p.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_power264nbs_table_fc36p.csv /data/${subject}_${session}_power264nbs_table_fc36p.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_aal116nbs_table_fc36p.csv /data/${subject}_${session}_aal116nbs_table_fc36p.csv

if [[ `cat ${xcpDir}/xcp_despike/${subject}/${subject}_logs/${subject}_audit.csv | grep "1,1,1,1,1,1,1,1,1,1"` ]];
then
echo ""
else
echo "XCPengine failure detected in ${subject}_audit.csv" > ${outputDir}/pipeline_error_log.txt
echo "Pipeline processing error detected in XCPengine for ${subject}. Check attached audit files for module failure point" | mail -a ${xcpDir}/xcp_despike/${subject}/${subject}_logs/${subject}_audit.csv -s "Pipeline error detected in XCPengine audit for ${subject}" pcamach2@illinois.edu
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/despike/${subject}_desikanKillianynbs_table.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/despike/${subject}_power264nbs_table.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/despike/${subject}_aal116nbs_table.txt
fi

cp ${xcpDir}/xcp_minimal_func/${subject}/fcon/nbs/despike/*txt ${outputDir}/despike/
mv ${outputDir}/despike/${subject}_desikanKillianynbs_table.txt ${outputDir}/${subject}_desikanKillianynbs_table_despike.csv
mv ${outputDir}/despike/${subject}_power264nbs_table.txt ${outputDir}/${subject}_power264nbs_table_despike.csv
mv ${outputDir}/despike/${subject}_aal116nbs_table.txt ${outputDir}/${subject}_aal116nbs_table_despike.csv

SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_desikanKillianynbs_table_despike.csv /data/${subject}_${session}_desikanKillianynbs_table_despike.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_power264nbs_table_despike.csv /data/${subject}_${session}_power264nbs_table_despike.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_aal116nbs_table_despike.csv /data/${subject}_${session}_aal116nbs_table_despike.csv

if [[ `cat ${xcpDir}/*scrub/${subject}/${subject}_logs/*process | grep "total number of fixed regressors"` ]]; 
then 
echo "Too many fixed regressors identified in XCPengine Power Scrub method, functional connectivity for this design unusable for ${subject}. Pipeline outputs csv will contain NA for respective measures" > ${outputDir}/pipeline_error_log.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/scrub/${subject}_desikanKillianynbs_table.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/scrub/${subject}_power264nbs_table.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/scrub/${subject}_aal116nbs_table.txt
fi

if [[ `cat ${xcpDir}/xcp_scrub/${subject}/${subject}_logs/${subject}_audit.csv | grep "1,1,1,1,1,1,1,1,1,1"` ]];
then
echo ""
else
echo "XCPengine failure detected in ${subject}_audit.csv" > ${outputDir}/pipeline_error_log.txt
echo "Pipeline processing error detected in XCPengine for ${subject}. Check attached audit files for module failure point" | mail -a ${xcpDir}/xcp_scrub/${subject}/${subject}_logs/${subject}_audit.csv -s "Pipeline error detected in XCPengine audit for ${subject}" pcamach2@illinois.edu
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/scrub/${subject}_desikanKillianynbs_table.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/scrub/${subject}_power264nbs_table.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/scrub/${subject}_aal116nbs_table.txt
fi

cp ${xcpDir}/xcp_minimal_func/${subject}/fcon/nbs/scrub/*txt ${outputDir}/scrub/
mv ${outputDir}/scrub/${subject}_desikanKillianynbs_table.txt ${outputDir}/${subject}_desikanKillianynbs_table_scrub.csv
mv ${outputDir}/scrub/${subject}_power264nbs_table.txt ${outputDir}/${subject}_power264nbs_table_scrub.csv
mv ${outputDir}/scrub/${subject}_aal116nbs_table.txt ${outputDir}/${subject}_aal116nbs_table_scrub.csv

SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_desikanKillianynbs_table_scrub.csv /data/${subject}_${session}_desikanKillianynbs_table_scrub.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_power264nbs_table_scrub.csv /data/${subject}_${session}_power264nbs_table_scrub.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_aal116nbs_table_scrub.csv /data/${subject}_${session}_aal116nbs_table_scrub.csv

if [[ `cat ${xcpDir}/xcp_minimal_aroma/${subject}/${subject}_logs/${subject}_audit.csv | grep "1,1,1,1,1,1,1,1,1,1"` ]];
then
echo ""
else
echo "XCPengine failure detected in ${subject}_audit.csv" > ${outputDir}/pipeline_error_log.txt
echo "Pipeline processing error detected in XCPengine for ${subject}. Check attached audit files for module failure point" | mail -a ${xcpDir}/xcp_minimal_aroma/${subject}/${subject}_logs/${subject}_audit.csv -s "Pipeline error detected in XCPengine audit for ${subject}" pcamach2@illinois.edu
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/aroma/${subject}_desikanKillianynbs_table.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/aroma/${subject}_power264nbs_table.txt
cp ${scriptsDir}/null_files/null_rsfc_nbs_table.txt ${outputDir}/aroma/${subject}_aal116nbs_table.txt
fi

cp ${xcpDir}/xcp_minimal_aroma/${subject}/fcon/nbs/*txt ${outputDir}/aroma/
mv ${outputDir}/aroma/${subject}_desikanKillianynbs_table.txt ${outputDir}/${subject}_desikanKillianynbs_table_aroma.csv
mv ${outputDir}/aroma/${subject}_power264nbs_table.txt ${outputDir}/${subject}_power264nbs_table_aroma.csv
mv ${outputDir}/aroma/${subject}_aal116nbs_table.txt ${outputDir}/${subject}_aal116nbs_table_aroma.csv

SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_desikanKillianynbs_table_aroma.csv /data/${subject}_${session}_desikanKillianynbs_table_aroma.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_power264nbs_table_aroma.csv /data/${subject}_${session}_power264nbs_table_aroma.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/${subject}_aal116nbs_table_aroma.csv /data/${subject}_${session}_aal116nbs_table_aroma.csv

#if [ -d "${strucconDir}" ];
#then
#	cp ${dtiDir}/${subject}_mridti_results.txt ${outputDir}/${subject}_mridti_results.csv
#	cp ${strucconDir}/scfsl_nbs_${subject}.txt ${outputDir}/scfsl_nbs_${subject}.csv
#	cp ${strucconDir}/${subject}_scfsl_nbs_rois.txt ${outputDir}/${subject}_scfsl_nbs_rois.csv
#
#	SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/scfsl_nbs_${subject}.csv /data/scfsl_nbs_${subject}_${session}.csv
#else
#	echo "no scfsl detected"
#fi

#sub-MBB005_ses-A_run-1_desc-ImageQC_dwi.csv
cp ${qsiprepDir}/${subject}_${session}_run-1_desc-ImageQC_dwi.csv ${outputDir}/${subject}_${session}_run-1_desc-ImageQC_dwi.csv
cp ${qsireconDir}/qsi_nbs_${subject}_aal116.txt ${outputDir}/${subject}_${session}_nbs_qsi_aal116.csv
cp ${qsireconDir}/qsi_nbs_${subject}_brainnetome246.txt ${outputDir}/${subject}_${session}_nbs_qsi_brainnetome246.csv
cp ${qsireconDir}/qsi_nbs_${subject}_power264.txt ${outputDir}/${subject}_${session}_nbs_qsi_power264.csv

# create csv and rename existing version
if [ -f "$outputDir/${subject}_${session}_pipeline_results.csv" ];
then
    mv $outputDir/${subject}_${session}_pipeline_results.csv $outputDir/${subject}_${session}_pipeline_results_old.csv
else
    touch $outputDir/${subject}_${session}_pipeline_results.csv
    echo "date_processed" >> $outputDir/${subject}_${session}_pipeline_results.csv
    echo $NOW >> $outputDir/${subject}_${session}_pipeline_results.csv
fi

#collate csv 
echo "Collating single-subject csv"
cd $outputDir

if [ -f	"${outputDir}/mriqc_iqms_t2w.csv" ];
then 
    paste -d, mriqc_iqms_t2w.csv mriqc_iqms_t1w.csv > tmp_anat.csv
    paste -d, mriqc_iqms_func_rest.csv tmp_anat.csv > tmp1.csv
else
    paste -d, mriqc_iqms_func_rest.csv mriqc_iqms_t1w.csv > tmp1.csv
fi
paste -d, tmp1.csv xcp_func_quality.csv > tmpfc36p.csv
paste -d, tmpfc36p.csv xcp_despike_quality.csv > tmpds.csv
paste -d, tmpds.csv xcp_scrub_quality.csv > tmp2.csv
paste -d, tmp2.csv xcp_aroma_quality.csv > tmp22.csv
paste -d, tmp22.csv xcp_fc36p_nback_quality.csv > tmp23.csv
paste -d, tmp23.csv ${subject}_aal116_mean_zstat1_2back1back.csv > tmpn1.csv
paste -d, tmpn1.csv ${subject}_desikanKilliany_mean_zstat1_2back1back.csv > tmpn2.csv
paste -d, tmpn2.csv ${subject}_power264_mean_zstat1_2back1back.csv > tmp3.csv

paste -d, tmp3.csv ${subject}_${session}_desikanKillianynbs_table_fc36p.csv > tmpnbs1.csv
paste -d, tmpnbs1.csv ${subject}_${session}_power264nbs_table_fc36p.csv > tmpnbs2.csv
paste -d, tmpnbs2.csv ${subject}_${session}_aal116nbs_table_fc36p.csv  > tmpnbs3.csv

paste -d, tmpnbs3.csv ${subject}_${session}_desikanKillianynbs_table_despike.csv > tmpnbs4.csv
paste -d, tmpnbs4.csv ${subject}_${session}_power264nbs_table_despike.csv > tmpnbs5.csv
paste -d, tmpnbs5.csv ${subject}_${session}_aal116nbs_table_despike.csv  > tmpnbs6.csv

paste -d, tmpnbs6.csv ${subject}_${session}_desikanKillianynbs_table_scrub.csv > tmpnbs7.csv
paste -d, tmpnbs7.csv ${subject}_${session}_power264nbs_table_scrub.csv > tmpnbs8.csv
paste -d, tmpnbs8.csv ${subject}_${session}_aal116nbs_table_scrub.csv > tmpnbs9.csv

paste -d, tmpnbs9.csv ${subject}_${session}_desikanKillianynbs_table_aroma.csv > tmpnbs10.csv
paste -d, tmpnbs10.csv ${subject}_${session}_power264nbs_table_aroma.csv > tmpnbs11.csv
paste -d, tmpnbs11.csv ${subject}_${session}_aal116nbs_table_aroma.csv > tmpnbs12.csv

if [ -d "${strucconDir}" ];
then 
    paste -d, tmpnbs12.csv ${subject}_mridti_results.txt > tmp10.csv
    paste -d, tmp10.csv scfsl_nbs_${subject}_${session}.csv > tmpfinal.csv

elif [ -d "${qsiprepDir}" ];
then
    paste -d, tmpnbs12.csv ${subject}_${session}_run-1_desc-ImageQC_dwi.csv > tmpnbs13.csv
    paste -d, tmpnbs13.csv ${subject}_${session}_nbs_qsi_aal116.csv > tmpnbs14.csv
    paste -d, tmpnbs14.csv ${subject}_${session}_nbs_qsi_brainnetome246.csv > tmpnbs15.csv
    paste -d, tmpnbs15.csv ${subject}_${session}_nbs_qsi_power264.csv > tmpfinal.csv

else
    mv tmpnbs12.csv tmpfinal.csv
fi

cp ${qsigqiDir}/gqi_nbs.csv ${outputDir}/${subject}_${session}_run-1_desc-gqi_nbs.csv

if [ -f "${subject}_${session}_run-1_desc-gqi_nbs.csv" ];
then
    paste -d, tmpfinal.csv ${subject}_${session}_run-1_desc-gqi_nbs.csv > tmpfinal_gqinbs.csv
    mv tmpfinal_gqinbs.csv tmpfinal.csv
else
    echo "No GQI NBS found"
fi

#ses=${session:4}
#sub=${subject:4}
#echo "datetime" > tmp_date.csv
#echo `cat ${projDir}/${sub}/${ses}/*/*/99/DICOM/scan_99_catalog.xml | grep -m 1 -o 'Time=".*" d' | cut -c 7- | rev | cut -c 4- | rev | sed 's/:/./g' | sed 's/-/./g'` >> tmp_date.csv
#paste -d, tmpfinal.csv tmp_date.csv > tmpfinaldate.csv
#paste -d, ${projDir}/bids/derivatives/${subject}_${session}_dicominfo.csv tmpfinaldate.csv > tmpdcm.csv

#mv tmpdcm.csv ${subject}_${session}_pipeline_results.csv
rm tmp*.csv
rm -R $SINGCACHE
rm -R $SINGTMP

echo "Finished collating"
echo "See ${outputDir} for results csv"
echo "See ${based}/${version}/data_qc for visual quality control reports"

