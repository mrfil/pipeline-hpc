#!/bin/bash
#rest bold
cd /data
funcs=`tr , "\n" < /scripts/mriqcfmri.txt`
for q in $funcs
do
    jq .$q /data/mriqc_rest_bold.json >> tmp.csv
    echo "," >> tmp.csv
done
echo -n $(tr -d "\n" < tmp.csv) > tmp.csv
rev tmp.csv | cut -c 2- | rev > tmp2.csv
cat /scripts/mriqcfmri.txt tmp2.csv > mriqc_iqms_func_rest.csv

rm tmp.csv

#anat T1w
t1ws=`tr , "\n" < /scripts/mriqcstruct.txt`
for q in $t1ws
do
    jq .$q /data/mriqc_T1w.json >> tmp.csv
    echo "," >> tmp.csv
done
echo -n $(tr -d "\n" < tmp.csv) > tmp.csv
rev tmp.csv | cut -c 2- | rev > tmp2.csv
cat /scripts/mriqcstruct.txt tmp2.csv > mriqc_iqms_t1w.csv

rm tmp.csv

t2ws=`tr , "\n" < /scripts/mriqcstruct.txt`
for q in $t2ws
do
    jq .$q /data/mriqc_T2w.json >> tmp.csv
    echo "," >> tmp.csv
done
echo -n $(tr -d "\n" < tmp.csv) > tmp.csv
rev tmp.csv | cut -c 2- | rev > tmp2.csv
cat /scripts/mriqcstruct.txt tmp2.csv > mriqc_iqms_t2w.csv

