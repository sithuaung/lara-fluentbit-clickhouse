CREATE DATABASE IF NOT EXISTS cmp_logs;

USE cmp_logs;

CREATE TABLE IF NOT EXISTS audit_logs
(
    id UUID DEFAULT generateUUIDv4(),
    service_name LowCardinality(String) CODEC(ZSTD(1)),
    event_type LowCardinality(String) CODEC(ZSTD(1)),
    event_time DateTime64(9) CODEC(ZSTD(1)),
    url String,
    ip_address String,
    user_agent String,
    actor_type Nullable(String), 
    actor_id Nullable(String),
    entity_type Nullable(String), 
    entity_id Nullable(String),
    old_data Map(String, String),
    new_data Map(String, String),
    metadata Nullable(String),
    version LowCardinality(String) CODEC(ZSTD(1)),
    source LowCardinality(String) CODEC(ZSTD(1)),
    description Nullable(String) CODEC(ZSTD(1)),
    correlation_id Nullable(String) CODEC(ZSTD(1)),
    tags Array(LowCardinality(String)),
    created_at DateTime64(9) DEFAULT now64(9)
)
ENGINE = MergeTree()
PARTITION BY toDate(created_at)
ORDER BY (id)
PRIMARY KEY (id)
SETTINGS index_granularity = 8192;


