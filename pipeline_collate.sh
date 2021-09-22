#!/bin/bash
#
#   Single-subject pipeline output collating to labeled csv
#
#   pipeline_collate.sh -p {project} -z {bidsname of subject} -s {bidsname of session} {base directory} {version}
#
#   Paul Camacho

while getopts :p:s:z:b:t:e: option; do
	case ${option} in
    	p) export project=$OPTARG ;;
    	s) export session=$OPTARG ;;
    	z) export subject=$OPTARG ;;
        b) export based=$OPTARG ;;
	t) export version=$OPTARG ;;
	e) export address=$OPTARG ;;
	esac
done

projDir=${based}/${version}/testing/${project}
mriqcDir=${projDir}/bids/derivatives/mriqc/${subject}/${session}
fmriprepDir=${projDir}/bids/derivatives/fmriprep/${subject}/${session}
xcpDir=${projDir}/bids/derivatives/xcp/${session}
qsiprepDir=${projDir}/bids/derivatives/qsiprep/${subject}/${session}/dwi
qsireconDir=${projDir}/bids/derivatives/qsirecon/${subject}/${session}/dwi
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

SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_func_quality_orig.csv /data/xcp_func_quality.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_despike_quality_orig.csv /data/xcp_despike_quality.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_scrub_quality_orig.csv /data/xcp_scrub_quality.csv
SINGULARITY_CACHEDIR=$SINGCACHE SINGULARITY_TMPDIR=$SINGTMP singularity run --cleanenv -B ${outputDir}:/data,${scriptsDir}/pyscripts:/work ${IMAGEDIR}/python3.sif /work/dsn_tag.py /data/xcp_aroma_quality_orig.csv /data/xcp_aroma_quality.csv

#nbs files
mkdir ${outputDir}/fc36p
mkdir ${outputDir}/despike
mkdir ${outputDir}/scrub
mkdir ${outputDir}/aroma
chmod 777 -R ${outputDir}

if [[ `cat ${xcpDir}/xcp_minimal_func/${subject}/${subject}_logs/${subject}_audit.csv | grep "1,1,1,1,1,1,1,1,1,1"` ]];
then
echo ""
else
echo "XCPengine failure detected in ${subject}_audit.csv" > ${outputDir}/pipeline_error_log.txt
echo "Pipeline processing error detected in XCPengine for ${subject}. Check attached audit files for module failure point" | mail -a ${xcpDir}/xcp_minimal_func/${subject}/${subject}_logs/${subject}_audit.csv -s "Pipeline error detected in XCPengine audit for ${subject}" ${address}
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
echo "Pipeline processing error detected in XCPengine for ${subject}. Check attached audit files for module failure point" | mail -a ${xcpDir}/xcp_despike/${subject}/${subject}_logs/${subject}_audit.csv -s "Pipeline error detected in XCPengine audit for ${subject}" ${address}
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
echo "Pipeline processing error detected in XCPengine for ${subject}. Check attached audit files for module failure point" | mail -a ${xcpDir}/xcp_scrub/${subject}/${subject}_logs/${subject}_audit.csv -s "Pipeline error detected in XCPengine audit for ${subject}" ${address}
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
echo "Pipeline processing error detected in XCPengine for ${subject}. Check attached audit files for module failure point" | mail -a ${xcpDir}/xcp_minimal_aroma/${subject}/${subject}_logs/${subject}_audit.csv -s "Pipeline error detected in XCPengine audit for ${subject}" ${address}
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
if [[ -f "${outputDir}/xcp_func_quality.csv" ]];
then
paste -d, tmp1.csv xcp_func_quality.csv > tmpfc36p.csv
paste -d, tmpfc36p.csv xcp_despike_quality.csv > tmpds.csv
	if [[ -f "${outputDir}/xcp_scrub_quality.csv" ]];
	then
	paste -d, tmpds.csv xcp_scrub_quality.csv > tmp2.csv
	paste -d, tmp2.csv xcp_aroma_quality.csv > tmp3.csv
	else
	paste -d, tmpds.csv xcp_aroma_quality.csv > tmp3.csv
	fi
fi

if [[ -f "${outputDir}/${subject}_${session}_desikanKillianynbs_table_fc36p.csv" ]];
then
paste -d, tmp3.csv ${subject}_${session}_desikanKillianynbs_table_fc36p.csv > tmpnbs1.csv
paste -d, tmpnbs1.csv ${subject}_${session}_power264nbs_table_fc36p.csv > tmpnbs2.csv
paste -d, tmpnbs2.csv ${subject}_${session}_aal116nbs_table_fc36p.csv  > tmpnbs3.csv
	if [[ -f "${outputDir}/${subject}_${session}_desikanKillianynbs_table_despike.csv" ]];
	then
	paste -d, tmpnbs3.csv ${subject}_${session}_desikanKillianynbs_table_despike.csv > tmpnbs4.csv
	paste -d, tmpnbs4.csv ${subject}_${session}_power264nbs_table_despike.csv > tmpnbs5.csv
	paste -d, tmpnbs5.csv ${subject}_${session}_aal116nbs_table_despike.csv  > tmpnbs6.csv
		if [[ -f "${outputDir}/${subject}_${session}_desikanKillianynbs_table_scrub.csv" ]];
		then
		paste -d, tmpnbs6.csv ${subject}_${session}_desikanKillianynbs_table_scrub.csv > tmpnbs7.csv
		paste -d, tmpnbs7.csv ${subject}_${session}_power264nbs_table_scrub.csv > tmpnbs8.csv
		paste -d, tmpnbs8.csv ${subject}_${session}_aal116nbs_table_scrub.csv > tmpnbs9.csv
		paste -d, tmpnbs9.csv ${subject}_${session}_desikanKillianynbs_table_aroma.csv > tmpnbs10.csv
		paste -d, tmpnbs10.csv ${subject}_${session}_power264nbs_table_aroma.csv > tmpnbs11.csv
		paste -d, tmpnbs11.csv ${subject}_${session}_aal116nbs_table_aroma.csv > tmpnbs12.csv
		else
                paste -d, tmpnbs6.csv ${subject}_${session}_desikanKillianynbs_table_aroma.csv > tmpnbs10.csv
                paste -d, tmpnbs10.csv ${subject}_${session}_power264nbs_table_aroma.csv > tmpnbs11.csv
                paste -d, tmpnbs11.csv ${subject}_${session}_aal116nbs_table_aroma.csv > tmpnbs12.csv
		fi
	else
        paste -d, tmpnbs3.csv ${subject}_${session}_desikanKillianynbs_table_aroma.csv > tmpnbs10.csv
        paste -d, tmpnbs10.csv ${subject}_${session}_power264nbs_table_aroma.csv > tmpnbs11.csv
        paste -d, tmpnbs11.csv ${subject}_${session}_aal116nbs_table_aroma.csv > tmpnbs12.csv
	fi
else
mv tmp3.csv tmpnbs12.csv
fi
 
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

mv tmpfinal.csv ${subject}_${session}_pipeline_results.csv
rm tmp*.csv
rm -R $SINGCACHE
rm -R $SINGTMP

echo "Finished collating"
echo "See ${outputDir} for results csv"
echo "See ${based}/${version}/data_qc for visual quality control reports"

