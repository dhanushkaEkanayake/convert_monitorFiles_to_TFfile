#!/bin/bash

INPUT_DIR_PATH="/root/test"
OUTPUT_DIR_PATH="/root/output"
filenames=()

main() {

	getMonitorFilenames
	for (( c=0; c<${#filenames[@]}; c++ ))
		do
			getMonitorFileBody
			readNametag
			newFilenameFromTag
			createTerraformFile
		done
}


getMonitorFilenames() {

	find $INPUT_DIR_PATH -name "monitor*" -exec basename {} \; > filenames.txt
	readarray -t filenames < filenames.txt
}


readNametag() {

        file_path=$INPUT_DIR_PATH/${filenames[c]}
        jq '. |.name' $file_path > nametag.txt
}


getMonitorFileBody(){

        file_path=$INPUT_DIR_PATH/${filenames[c]}
        awk '{print "\t", $0}' < $file_path > dump.txt
}

newFilenameFromTag() {
	
	newfilename=$(cat nametag.txt | cut -f1 -d"-" | sed 's/[ \t]*$//' | tr '.' ' '| tr -dc '[:alnum:]\ \n\r' | tr '[:upper:]' '[:lower:]'| tr -s ' ' | tr ' ' '_')
	rm -f nametag.txt
}

createTerraformFile() {

	echo -e "resource "datadog_monitor_json" ${newfilename} {\n\tmonitor = <<-EOF\n$(cat dump.txt)\nEOF\n}" > $OUTPUT_DIR_PATH/${newfilename}.tf
	rm -f dump.txt
}

deleteFilenameFextFile() {

	rm -f filenames.txt	
}

main
