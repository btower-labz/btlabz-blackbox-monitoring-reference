#!/bin/sh

set -u

PROM_API=http://pushgateway:9091/pushgateway/metrics
PROM_JOB=traceroute
PROM_INSTANCE=dkron
TARGET=8.8.8.8

# See: https://github.com/prometheus/pushgateway
PGW_URL="${PROM_API}/job/${PROM_JOB}/instance/${PROM_INSTANCE}"

# See: https://linux.die.net/man/8/mtr
OPTIONS="--report-cycles 1 --interval 1 -4 --timeout 10 --psize 16 --tcp --gracetime 3 --mpls --json --no-dns --show-ips --mpls -n"
OFILE=/tmp/out.json
FFILE=/scripts/tr2prom.jq
MFILE=/tmp/metrics.txt

mtr ${OPTIONS}  ${TARGET} > ${OFILE}
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "Error running traceroute: ${retVal}"
  exit $retVal
fi

jq --exit-status --raw-output -f ${FFILE} ${OFILE} >${MFILE}
retVal=$?
if [ $retVal -ne 0 ]; then
  cat ${OFILE}
  echo "Error parsing traceroute: ${retVal}"
  exit $retVal
fi

curl --fail --location --show-error --silent --data-binary "@${MFILE}" ${PGW_URL}
retVal=$?
if [ $retVal -ne 0 ]; then
  cat ${MFILE}
  echo "Error pushing metrics: ${retVal}"
  exit $retVal
else
  echo "Metrics pushed ..."    
fi
