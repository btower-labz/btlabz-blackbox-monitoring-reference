#!/bin/env bash

set -o nounset
set -o noclobber
set -o errexit
set -o pipefail

# --max-time 10     (how long each retry will wait)
# --retry 5         (it will retry 5 times)
# --retry-delay 0   (an exponential backoff algorithm)
# --retry-max-time 120  (total time before it's considered failed)
# --location (follow all the redirects)

CMD="curl --retry 5 --retry-delay 0 --retry-max-time 120 --silent --show-error --location -XPOST http://dkron:8080/v1/jobs"

${CMD} --data-binary "@/jobs/sample-001.json" 
${CMD} --data-binary "@/jobs/sample-002.json" 
${CMD} --data-binary "@/jobs/sample-003.json" 
${CMD} --data-binary "@/jobs/sample-004.json" 
${CMD} --data-binary "@/jobs/sample-005.json" 
${CMD}?runoncreate=true --data-binary "@/jobs/sample-006.json" 
${CMD} --data-binary "@/jobs/sample-007.json" 
