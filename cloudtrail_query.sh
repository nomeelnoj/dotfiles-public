#!/bin/bash

set -x

EVENT_ID=${1}
if [[ "${EVENT_ID}" == "https://"* ]]; then
  EVENT_ID=$(echo "${EVENT_ID}" | sed 's:.*=::')
fi

mkdir -p examples

DATA=$(aws cloudtrail \
  lookup-events \
  --lookup-attributes \
    AttributeKey=EventId,AttributeValue=${EVENT_ID})


echo "${DATA}" |\
   jq '.[][0]["CloudTrailEvent"] | { "Records": [ fromjson ] }' > examples/temp.json

cat examples/temp.json
echo 'Your file has been stored at examples/temp.json'

