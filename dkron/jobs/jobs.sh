#!/bin/env bash

CMD="curl --silent --show-error --location -XPOST http://dkron:8080/v1/jobs"

${CMD} --data-binary "@/jobs/sample-001.json" 
${CMD} --data-binary "@/jobs/sample-002.json" 
${CMD} --data-binary "@/jobs/sample-003.json" 
${CMD} --data-binary "@/jobs/sample-004.json" 
${CMD} --data-binary "@/jobs/sample-005.json" 
${CMD} --data-binary "@/jobs/sample-006.json" 
${CMD} --data-binary "@/jobs/sample-007.json" 
