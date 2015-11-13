#!/bin/bash

if [ "$1" = "" ]; then
   echo 'USAGE: bash stnnbr-to-callnumber.sh ISSN_LIST_FILE'
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
echo 'Standard_Number,CALL_NO,TITLE' > $CSV_FILE
cat $1 | while read ISSN; do
    # now generate the owi version of the file...
    echo "Checking $ISSN"
    DATA_FILE="data/$ISSN.xml"
    curl -s --output $DATA_FILE http://classify.oclc.org/classify2/Classify?stdnbr=$ISSN
    # Check first for physical Journal Call No.
    OWI=$(xpath data/$ISSN.xml '//work[@itemtype="itemtype-jrnl"]/@owi' | cut -d \" -f 2)
    if [ "$OWI" = "" ]; then
        # then check for digital Journal Call No.
        OWI=$(xpath data/$ISSN.xml '//work[@itemtype="itemtype-jrnl-digital"]/@owi' | cut -d \" -f 2)
    fi
    # We've check both types of journals and should have either the hard copy or digital copy.
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
