CREATE TABLE IF NOT EXISTS prometheus.metrics (
    "timestamp" TIMESTAMPTZ,
    "labels_hash" STRING,
    "labels" OBJECT(DYNAMIC),
    "value" DOUBLE,
    "valueRaw" LONG,
    "day__generated" TIMESTAMPTZ GENERATED ALWAYS AS date_trunc('day', "timestamp"),
    PRIMARY KEY ("timestamp", "labels_hash", "day__generated")
) PARTITIONED BY ("day__generated");
