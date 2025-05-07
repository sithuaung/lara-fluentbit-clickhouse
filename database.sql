CREATE DATABASE IF NOT EXISTS cmp_logs;

USE cmp_logs;

CREATE TABLE IF NOT EXISTS audit_logs
(
    id UUID,
    service_name LowCardinality(String) CODEC(ZSTD(1)),
    event_type LowCardinality(String) CODEC(ZSTD(1)),
    event_time DateTime64(9) CODEC(ZSTD(1)),
    actor_type Nullable(LowCardinality(String)),
    actor_id Nullable(String),
    entity_type Nullable(LowCardinality(String)),
    entity_id Nullable(String),
    old_data String,
    new_data String,
    metadata Nullable(Nested(
        key String,
        value String
    )),
    version LowCardinality(String) CODEC(ZSTD(1)),
    source LowCardinality(String) CODEC(ZSTD(1)),
    description Nullable(String) CODEC(ZSTD(1)),
    correlation_id Nullable(String) CODEC(ZSTD(1)),
    tags Array(String) CODEC(ZSTD(1)),
    created_at DateTime64(9) CODEC(ZSTD(1)) DEFAULT now64(9)
)
ENGINE = MergeTree()
PARTITION BY toDate(created_at)
ORDER BY (created_at, id)
PRIMARY KEY (id)
SETTINGS {
    index_granularity = 8192 
};
