CREATE DATABASE IF NOT EXISTS cmp;

USE cmp;

CREATE TABLE IF NOT EXISTS audit_logs
(
    id UUID DEFAULT generateUUIDv4(),
    service_name LowCardinality(String) CODEC(ZSTD(1)),
    user_type Nullable(String), 
    user_id Nullable(String),
    event LowCardinality(String) CODEC(ZSTD(1)),
    event_time DateTime64(9) CODEC(ZSTD(1)),
    auditable_type Nullable(String), 
    auditable_id Nullable(String),
    old_values Map(String, String),
    new_values Map(String, String),
    url String,
    ip_address String,
    user_agent String,
    correlation_id Nullable(String) CODEC(ZSTD(1)),
    tags Array(LowCardinality(String)),
    created_at DateTime64(9) DEFAULT now64(9)
)
ENGINE = MergeTree()
PARTITION BY toDate(created_at)
ORDER BY (id)
PRIMARY KEY (id)
SETTINGS index_granularity = 8192;


