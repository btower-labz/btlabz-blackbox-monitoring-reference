# MTR TraceRoute to Prometheus Converter

# See: https://ss64.com/bash/mtr.html
# See: https://github.com/prometheus/pushgateway

# Input: a hop
# Ouput: formed metrics array (no labels)
def metrics(t): t as $t | . |

# Hop common variables
(.host | gsub("^[\\?]+$"; "*")) as $tr_host |
(.count) as $tr_hop |
"traceroute_probe" as $tr_metric_prefix |
[
    { 
        # TODO: Check variable placement. It might be better to set this on the command line.
        metric: "\($tr_metric_prefix)_now", hop: $tr_hop, host: $tr_host, 
        value: $t, type: "counter",
        help: "The parse time, in seconds since the Unix epoch. Results freshness." 
    },
    { 
        metric: "\($tr_metric_prefix)_loss", hop: $tr_hop, host: $tr_host, 
        value: .["Loss%"], type: "gauge",
        help: "The percentage of packets for which an ICMP reply was not received." 
    },
    { 
        metric: "\($tr_metric_prefix)_snt", hop: $tr_hop, host: $tr_host,
        value: .["Snt"], type: "gauge",
        help: "The number of packets sent to each hop." 
    },
    { 
        metric: "\($tr_metric_prefix)_last", hop: $tr_hop, host: $tr_host,
        value: .["Last"], type: "gauge",
        help: "The round trip time of the last traceroute probe (ms)." 
    },
    { 
        metric: "\($tr_metric_prefix)_avg", hop: $tr_hop, host: $tr_host,
        value: .["Avg"], type: "gauge",
        help: "The average round-trip time of all traceroute probes (ms)." 
    },
    { 
        metric: "\($tr_metric_prefix)_best", hop: $tr_hop, host: $tr_host,
        value: .["Best"], type: "gauge",
        help: "The shortest round-trip time of all traceroute probes (ms)." 
    },
    { 
        metric: "\($tr_metric_prefix)_wrst", hop: $tr_hop, host: $tr_host,
        value: .["Wrst"], type: "gauge",
        help: "The longest round-trip time of all traceroute probes (ms)." 
    },
    { 
        metric: "\($tr_metric_prefix)_st_dev", hop: $tr_hop, host: $tr_host,
        value: .["StDev"], type: "gauge",
        help: "The standard deviation probe results to each hop" 
    }
]
;

# Make type header from metric name and type spec
def type_header(n;t):
  n as $tr_name |
  t as $tr_type |
  "# TYPE \($tr_name) \($tr_type)"
;

# Make help header from metric name and help spec
def help_header(n;h):
  n as $tr_name |
  h as $tr_help |
  "# HELP \($tr_name) \($tr_help)"
;

# Make TYPE and HELP headers
# hops - linux timestamp
# time - linux timestamp
# Output: distinct metrics headers
def headers(hops;time):
time as $time |
[
hops[] |
# Our metrics as per shop
metrics($time)[] |
    # Headers object
    {
        name: .metric,
        help: (help_header(.metric; .help)),
        type: (type_header(.metric; .type))
    }
 ] |
 unique_by(.name) | map("\(.type)\n\(.help)") |
join("\n")
;

# Buld labels based on mtr and metrics array
def labels(mtr;hop):
mtr as $mtr |
hop as $hop |
(.host | gsub("^[\\?]+$"; "*")) as $host |
[
    "source=\"\($mtr.src)\"",
    "target=\"\($mtr.dst)\"",
    "hop=\"\($hop.count)\"",
    "host=\"\($host)\"",
    "tests=\"\($mtr.tests)\"",
    "psize=\"\($mtr.psize)\"",
    "tos=\"\($mtr.tos)\"",
    "bitpattern=\"\($mtr.bitpattern)\""
] | join(",")
;

# Build up values array
# Input: none expected
# r - report object
# t - unix timestamp
# Output: array of prom metrics
def values(mtr;hops;time):
time as $time |
mtr as $mtr |
[
    hops[] |
    . as $hop | 
    metrics($time)[] | . |
    labels($mtr; $hop) as $labels |
    "\(.metric){\($labels)} \(.value)" 
] |
join("\n")
;

# Main filter
now as $time |
.report.mtr as $mtr |
.report.hubs as $hops |
headers($hops; $time) as $headers |
values($mtr; $hops; $time) as $values |
"\($headers)\n\n\($values)\n"

# Data sample

# {
#   "report": {
#     "mtr": {
#       "src": "192.168.0.1",
#       "dst": "8.8.8.8",
#       "tos": "0x0",
#       "psize": "16",
#       "bitpattern": "0x00",
#       "tests": "1"
#     },
#     "hubs": [{
#       "count": "1",
#       "host": "172.17.0.1",
#       "Loss%": 0.00,
#       "Snt": 1,
#       "Last": 0.08,
#       "Avg": 0.08,
#       "Best": 0.08,
#       "Wrst": 0.08,
#       "StDev": 0.00
#     },
#     {
#       "count": "2",
#       "host": "???",
#       "Loss%": 100.00,
#       "Snt": 1,
#       "Last": 0.00,
#       "Avg": 0.00,
#       "Best": 0.00,
#       "Wrst": 0.00,
#       "StDev": 0.00
#     }]
#   }
# }