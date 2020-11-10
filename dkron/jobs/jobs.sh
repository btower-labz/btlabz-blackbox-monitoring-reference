#!/bin/sh

# nounset
set -u

# Curl Options

# --max-time 10     (how long each retry will wait)
# --retry 5         (it will retry 5 times)
# --retry-delay 0   (an exponential backoff algorithm)
# --retry-max-time 120  (total time before it's considered failed)
# --location (follow all the redirects)

DKRON_API=http://dkron:8080/v1/jobs
echo "DKRON API: ${DKRON_API}"
# Curl Command
CMD="curl --fail --retry 5 --retry-delay 0 --retry-max-time 120 --silent --show-error --location -XPOST ${DKRON_API}"
echo "CURL Command: ${CMD}"

# Update DKRON function
update_dkron_job()
{
  local FILE=${1}
  local RUNONCREATE=${2:-false}
  local retVal=0

  if [ ! -f "${FILE}" ]; then
    echo "File does not exists: ${FILE}"
    exit 1
  else
    echo "Processing file: ${FILE}"
  fi

  ${CMD}?runoncreate=${RUNONCREATE} --data-binary "@${FILE}"
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "Error updating DKRON job: ${retVal}"
    exit $retVal
  else
    echo "File posted: ${FILE}"    
  fi
}

update_dkron_job /jobs/sample-001.json
update_dkron_job /jobs/sample-002.json
update_dkron_job /jobs/sample-003.json
update_dkron_job /jobs/sample-004.json
update_dkron_job /jobs/sample-005.json
update_dkron_job /jobs/sample-006.json true
update_dkron_job /jobs/sample-007.json

echo "Sleep ..."
sleep 10s

echo "Finished ..."

exit 0
