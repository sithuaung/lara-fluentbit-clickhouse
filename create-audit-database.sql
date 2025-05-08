-- ClickHouse CREATE TABLE statement for the audits table

CREATE TABLE audits
(
    -- The 'id' column, using UUID for globally unique identification of the audit entry.
    -- A default value is provided to generate a UUID if one is not supplied during insert.
    id UUID DEFAULT generateUUIDv4(),

    -- User type, e.g., 'Admin', 'User'
    user_type Nullable(String),

    -- ID of the user performing the action
    user_id Nullable(Int64),

    -- Type of event, e.g., 'create', 'update', 'delete'
    -- This was NOT NULL in PostgreSQL, so it's a non-nullable String here.
    event String,

    -- Type of the auditable entity, e.g., 'Article', 'User'
    -- This was NOT NULL in PostgreSQL.
    auditable_type String,

    -- ID of the auditable entity. Changed to UUID to match example log data.
    -- This was previously Int64.
    auditable_id Nullable(UUID), -- Changed from Int64 to Nullable(UUID)

    -- JSON or text representation of the old values of the audited entity
    old_values Nullable(String),

    -- JSON or text representation of the new values of the audited entity
    new_values Nullable(String),

    -- URL associated with the event, if any
    url Nullable(String),

    -- IP address of the user
    -- Stored as String for flexibility (can hold IPv4 or IPv6).
    -- Consider ClickHouse's IPv4 or IPv6 types if the format is fixed and known.
    ip_address Nullable(String),

    -- User agent string of the client
    user_agent Nullable(String),

    -- Tags associated with the audit entry
    -- If you store multiple tags, consider using Array(String) for better querying.
    tags Nullable(String),

    -- Timestamp of when the audit event was created
    -- Made non-nullable with a default value, common for audit logs.
    created_at DateTime DEFAULT now(),

    -- Timestamp of when the audit entry was last updated (if applicable)
    updated_at Nullable(DateTime)
)
ENGINE = MergeTree()
-- Partitioning by month is a common and effective strategy for time-series data like audit logs.
-- This helps in managing data and improving query performance.
PARTITION BY toYYYYMM(created_at)
-- The ORDER BY clause defines how data is sorted within each part.
-- This is crucial for MergeTree performance and acts as the primary index.
-- Choose columns frequently used in WHERE clauses and for range scans.
-- auditable_id is now UUID, which can be part of the sorting key.
ORDER BY (created_at, auditable_type, auditable_id, event)
-- Optional: The PRIMARY KEY in ClickHouse is defined by the ORDER BY clause by default.
-- You can explicitly define it, but it must be a prefix of the ORDER BY key.
-- PRIMARY KEY (created_at, auditable_type, auditable_id)
SETTINGS
    index_granularity = 8192, -- Default setting, can be tuned based on use case.
    allow_nullable_key = 1;   -- Added to allow Nullable(UUID) for auditable_id in the ORDER BY key

/*
Key differences and considerations from the PostgreSQL schema:

1.  **ID Column (`id`):**
    * Remains `UUID DEFAULT generateUUIDv4()` for the audit entry's unique ID.

2.  **Auditable ID Column (`auditable_id`):**
    * Changed from `Int64` to `Nullable(UUID)` to accommodate UUIDs from log sources.
    * Made Nullable as the original PostgreSQL schema did not specify NOT NULL for it,
      and it's safer if some events might not have it (though the example log does).

3.  **Data Types:**
    * `int8` maps to `Int64`.
    * `varchar` and `text` map to `String`.
    * `timestamp` maps to `DateTime` (or `DateTime64` for sub-second precision if needed).
    * `inet` is mapped to `Nullable(String)`.

4.  **`NOT NULL` constraints:**
    * Columns marked `NOT NULL` in PostgreSQL are made non-nullable in ClickHouse (e.g., `event String`).
    * Other columns are `Nullable(Type)` unless a `DEFAULT` is provided.

5.  **Table Engine (`ENGINE = MergeTree()`):**
    * `PARTITION BY`: `toYYYYMM(created_at)`.
    * `ORDER BY`: `(created_at, auditable_type, auditable_id, event)`.
    * `SETTINGS allow_nullable_key = 1`: This is added to resolve the error.

6.  **`tags` column**: Consider `Array(String)` if storing multiple tags.
*/
