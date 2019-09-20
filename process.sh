#!/bin/bash

set -e

echo "process started"
echo "Start: vfb-pipeline-validatekb"
echo "VFBTIME:"
date

echo 'START' >> ${WORKSPACE}/tick.out
## tail -f ${WORKSPACE}/tick.out >&1 &>&1

cd ${WORKSPACE}/VFB_neo4j
git pull origin master
git checkout ${GITBRANCH}
git pull
cd ..

SCRIPTS=${WORKSPACE}/VFB_neo4j/src/uk/ac/ebi/vfb/neo4j/

echo '** Transform old KB according to new schema **'
#export BUILD_OUTPUT=${WORKSPACE}/KBValidate.out
python3 ${SCRIPTS}neo4j_kb_validateschema.py ${KBserver} ${KBuser} ${KBpassword}
#cp $BUILD_OUTPUT /logs/
#egrep 'Exception|Error|error|exception|warning' $BUILD_OUTPUT


echo "End: vfb-pipeline-validatekb"
echo "VFBTIME:"
date
echo "process complete"