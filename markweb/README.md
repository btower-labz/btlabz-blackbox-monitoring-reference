# Black Box Monitoring POC

## System Components

| Component | Interface | Metrics | Notes |
| --- | --- | --- | --- |
| Envoy Proxy | [admin](/envoy) | [metrics](/envoy/metrics) | Management and search interface access |
| Prometheus | [admin](/prometheus)<br>[debug](/prometheus/debug/pprof/) | [metrics](/prometheus/metrics)<br>[targets](/prometheus/targets) | Management and search interface access |
| Grafana Dashboards | [admin](/grafana) | [metrics](/grafana/metrics) | Service Aviability Dashboards |
| Alert Manager | [admin](/alertmanager) | [metrics](/alertmanager/metrics) | Service Aviability Alerts |
| Push Gateway | [admin](/pushgateway) | [metrics](/pushgateway/metrics) | "Push" metrics collector |
| BlackBox Probe | [admin](/blackbox) | [metrics](/blackbox/metrics) | BlackBox icmp and http probe |
| DKRON Scheduler | [admin](/dkron) | [metrics](/dkron/metrics) | TraceRT and other tasks which are not supported by prom directly |
| Container Advisor | [admin](/cadvisor) | [metrics](/cadvisor/metrics) | Docker Stats |
| Node Exporter | [admin](/node) | [metrics](/node/metrics) | Black Box Node Statictics Exporter |
