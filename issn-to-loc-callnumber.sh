#!/bin/bash

if [ "$1" = "" ]; then
   echo 'USAGE: bash issn-to-loc-callnumber.sh ISSN_LIST_FILE'
   exit 1
fi

mkdir -p data
if [ -f "data.csv" ]; then
    rm data.csv
fi

# Get all the documents by ISSN
CSV_FILE="data.csv"
ISSN=""
TITLE=""
CALL_NO=""
echo 'ISSN,CALL_NO,TITLE' > $CSV_FILE
cat $1 | while read ISSN; do
    # now generate the owi version of the file...
    echo "Checking $ISSN"
    DATA_FILE="data/$ISSN.xml"
    curl -s --output $DATA_FILE http://classify.oclc.org/classify2/Classify?issn=$ISSN
    OWI=$(xpath data/$ISSN.xml "//work[1]/@owi" | cut -d \" -f 2)
    if [ "$OWI" != "" ]; then
        echo "Found OWI: $OWI"
        DATA_FILE="data/owi-$ISSN.xml"
        echo " Looking up Call number for $ISSN in $DATA_FILE"
        curl -s --output $DATA_FILE http://classify.oclc.org/classify2/Classify?owi=$OWI
        TITLE=$(xpath $DATA_FILE '//editions/edition[1]/@title' | cut -d \" -f 2)
        CALL_NO=$(xpath $DATA_FILE '//lcc/mostPopular/@sfa' | cut -d \" -f 2)
        echo "Title: $TITLE, Call No: $CALL_NO"
        echo "$ISSN,$CALL_NO,$TITLE" >> $CSV_FILE
    fi
done
