#!/bin/bash
#
#single-sub single-session script for adding intended for statements to fmap jsons before running BIDS apps
#
#usage: jsoncrawler.sh {bids directory} {session} {subject}
#
#pbc
#example: jsoncrawler.sh {projectFolder}/{projectBIDSoutputFromHeuDiConv} ses-01

sesname=$2
seslen=${#sesname}
sub=$3
intend='"IntendedFor": '

seshs=($1/${sub}/${sesname})
for sesh in ${seshs[@]}; do
cd $sesh
taskfuncmaps=(./fmap/*fieldMap*json)
taskfuncs=(./func/*task*bold*nii.gz)

	for taskfuncmap in ${taskfuncmaps[@]}; do
		for funcs in ${taskfuncs[@]}; do
		img=${funcs:1}
		jq .IntendedFor $taskfuncmap > tmpj
		if [[ $(cat tmpj) == "${sesname}${img}" ]];
		then
			echo "IntendedFor found as "${sesname}$img""
		else
			printf "  " > test.txt
			printf $intend >> test.txt
			printf " " >> test.txt
			printf '"' >> test.txt
			printf "${sesname}""$img"  >> test.txt
			printf '",' >> test.txt
			echo "" >> test.txt
			echo "" > tmp
			awk 'NR==1{a=$0}NR==FNR{next}FNR==32{print a}1' test.txt $taskfuncmap >> tmp && mv tmp $taskfuncmap
		fi
		done
	done

done

rm -f test.txt
rm -f tmp
rm -f tmpj
