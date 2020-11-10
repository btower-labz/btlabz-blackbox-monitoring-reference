#!/bin/sh

set -u

PROM_API=http://pushgateway:9091/pushgateway/metrics
PROM_JOB=traceroute
PROM_INSTANCE=${1}
TARGET=${1}
echo "PROBE TARGET: ${1}"

# See: https://github.com/prometheus/pushgateway
PGW_URL="${PROM_API}/job/${PROM_JOB}/instance/${PROM_INSTANCE}"

TMPDIR=$(mktemp -d -t "tr2prom.XXXXXXXX")
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "Error creating temp dir: ${retVal}"
  exit $retVal
else
  echo "TMPDIR: ${TMPDIR}"
fi
trap "rm -rf ${TMPDIR}" EXIT

# See: https://linux.die.net/man/8/mtr
OPTIONS="--report-cycles 1 --interval 1 -4 --timeout 10 --psize 16 --tcp --gracetime 3 --mpls --json --no-dns --show-ips --mpls -n"
OFILE=${TMPDIR}/traceroute.json
FFILE=/scripts/tr2prom.jq
MFILE=${TMPDIR}/metrics.txt

mtr ${OPTIONS} ${TARGET} > ${OFILE}
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
