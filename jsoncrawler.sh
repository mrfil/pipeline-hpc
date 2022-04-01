#!/bin/bash
#
#single-sub single-session script for adding intended for statements to fmap jsons before running BIDS apps
# requires JQ
#usage: jsoncrawler.sh {bids directory} {session} {subject}
#
#pbc
#example: jsoncrawler.sh {projectFolder}/{projectBIDSoutputFromHeuDiConv} ses-01

sesname=$2
seslen=${#sesname}
sub=$3

seshs=($1/${sub}/${sesname})
for sesh in ${seshs[@]}; do
cd $sesh
restfuncmaps=(./fmap/*rest*json)
restfuncs=(./func/*rest*bold*nii.gz)

	for restfuncmap in ${restfuncmaps[@]}; do
	img=${restfuncs:1}
	jq '.IntendedFor' $restfuncmap > tmpj
	if [[ $(cat tmpj) == "${sesname}${img}" ]];
	then
		echo "IntendedFor found as "${sesname}$img""
		exit 0
	else
		# replace the following with jq or jo 
		cat $restfuncmap | jq '.IntendedFor |= "${sesname}$img"' > tmp
		mv tmp $restfuncmap
	fi
done

taskfuncmaps=`find ./fmap -maxdepth 2 -type f \( -iname "*nback*json" -a -not -iname "*rest*" \)`
taskfuncs=`find ./func -maxdepth 2 -type f \( -iname "*nback*bold*nii.gz" -a -not -iname "*rest*" \)`

    for taskfuncmap in ${taskfuncmaps[@]}; do
    img=${taskfuncs:1}
#	taskprefix=${taskfuncmap#*task-*}
#	taskname="${taskprefix%%_*}"
	task="*nback*"
	if [[ "$img" == "$task" ]];
	then
		cat $taskfuncmap | jq '.IntendedFor |= "${sesname}$img"' > tmp
		mv tmp $taskfuncmap
	fi
done

dwimaps=(./fmap/*dwi*json)
dwis=(./dwi/*dwi*nii.gz)

	for dwimap in ${dwimaps[@]}; do
	img=${dwis:1}
		jq '.IntendedFor' $dwimap > tmpj
		if [[ $(cat tmpj) == "${sesname}$img" ]];
		then
			echo "IntendedFor found as "${sesname}$img""
			exit 0
		else
			cat $dwimap | jq '.IntendedFor |= "${sesname}$img"' > tmp
            mv tmp $dwimap
		fi
done
done

rm -f tmpj
