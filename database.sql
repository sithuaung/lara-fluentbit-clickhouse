CREATE DATABASE IF NOT EXISTS cmp;

USE cmp;

CREATE TABLE IF NOT EXISTS audits
(
    id UUID DEFAULT generateUUIDv4(),
    service_name LowCardinality(String) CODEC(ZSTD(1)),
    user_type Nullable(String) CODEC(ZSTD(1)), 
    user_id Nullable(String) CODEC(ZSTD(1)),
    event LowCardinality(String) CODEC(ZSTD(1)),
    occurred_at DateTime64(3) CODEC(DoubleDelta, ZSTD(1)),
    auditable_type Nullable(String) CODEC(ZSTD(1)), 
    auditable_id Nullable(String) CODEC(ZSTD(1)),
    old_values Nullable(String) CODEC(ZSTD(1)),
    new_values Nullable(String) CODEC(ZSTD(1)),
    url String CODEC(ZSTD(1)),
    ip_address IPv6 CODEC(ZSTD(1)),
    user_agent String CODEC(ZSTD(1)),
    correlation_id Nullable(String) CODEC(ZSTD(1)),
    tags Nullable(String) CODEC(ZSTD(1)),
    created_at DateTime64(3) DEFAULT now64(3) CODEC(DoubleDelta, ZSTD(1))
)
ENGINE = MergeTree()
PARTITION BY (toYYYYMM(created_at), service_name)
ORDER BY (service_name, created_at, id)
PRIMARY KEY (service_name, created_at)
SETTINGS index_granularity = 8192,
         index_granularity_bytes = 10485760,
         enable_mixed_granularity_parts = 1;



