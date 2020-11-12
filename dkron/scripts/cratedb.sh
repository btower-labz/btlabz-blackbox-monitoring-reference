#!/bin/sh

# nounset
set -u

# CRATE API
CRATE_API=http://crate-01:4200/_sql
echo "CRATE API: ${CRATE_API}"

# CURL COMMAND
CURL_RETRY="--retry 5 --retry-delay 0 --retry-max-time 120"
CURL_EXEC="--fail --verbose --show-error"
CURL_API="--location -H 'Content-Type: application/json' -XPOST ${CRATE_API}"
CURL_OPT="${CURL_EXEC} ${CURL_RETRY} ${CURL_API}"
echo "CURL Command: ${CURL_OPT}"

SQL_FILE=${1}
if [ ! -f "${SQL_FILE}" ]; then
  echo "File does not exists: ${SQL_FILE}"
  exit 1
else
  echo "Processing file: ${SQL_FILE}"
fi

JQ_FILE=${2:-/scripts/cratedb.jq}
if [ ! -f "${JQ_FILE}" ]; then
  echo "Filter does not exists: ${JQ_FILE}"
  exit 1
else
  echo "Processing filter: ${JQ_FILE}"
fi


TIMESTAMP_YYYYMMDD_HHMMSS=$(date +"%Y%m%d-%H%M%S")

JQ_FILTER="--arg timestamp ${TIMESTAMP_YYYYMMDD_HHMMSS} --null-input --compact-output --rawfile sql ${SQL_FILE} -f ${JQ_FILE}"
echo "JQ Filter: ${JQ_FILTER}"

set -x

sh -c "jq ${JQ_FILTER} | curl ${CURL_OPT} --data-binary '@-'"

retVal=$?
if [ $retVal -ne 0 ]; then
  echo "Error executing SQL: ${retVal}"
  exit $retVal
else
  echo "File posted: ${SQL_FILE}"    
fi

echo "Sleep ..."
sleep 10s

echo "Finished ..."
exit 0
