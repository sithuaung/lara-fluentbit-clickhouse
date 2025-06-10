CREATE TABLE cmp.audits
(
    -- Auto-increment ID - most efficient for limited resources
    `id` UInt64,
    
    -- Keep optimized string columns
    `service_name` LowCardinality(String) CODEC(LZ4),
    `user_type` LowCardinality(String) DEFAULT '' CODEC(LZ4),
    `user_id` String DEFAULT '' CODEC(LZ4),
    `event` LowCardinality(String) CODEC(LZ4),
    `occurred_at` DateTime CODEC(DoubleDelta, LZ4),
    
    -- Simplify nullable columns to reduce overhead
    `auditable_type` LowCardinality(String) DEFAULT '' CODEC(LZ4),
    `auditable_id` String DEFAULT '' CODEC(LZ4),
    
    -- Store JSON as String for better performance on writes
    `old_values` String DEFAULT '' CODEC(ZSTD(1)),
    `new_values` String DEFAULT '' CODEC(ZSTD(1)),
    
    -- Keep essential fields
    `url` String CODEC(LZ4),
    `ip_address` String CODEC(LZ4),  -- Changed from IPv6 to String for faster writes
    `user_agent` String DEFAULT '' CODEC(LZ4),
    `correlation_id` String DEFAULT '' CODEC(LZ4),
    `tags` String DEFAULT '' CODEC(LZ4),
    
    -- Reduce precision for faster writes
    `created_at` DateTime DEFAULT now() CODEC(DoubleDelta, LZ4)
)
ENGINE = MergeTree
PARTITION BY (toYYYYMM(created_at))
PRIMARY KEY (service_name, created_at)
ORDER BY (service_name, created_at, id)  -- Keep id in ORDER BY for uniqueness
SETTINGS 
    -- Optimized for write performance on limited resources
    index_granularity = 16384,                    -- Larger granularity = fewer index entries
    index_granularity_bytes = 20971520,           -- 20MB chunks for better batching
    enable_mixed_granularity_parts = 1,
    
    -- Critical for write performance on low-resource systems
    max_parts_in_total = 10000,                   -- Prevent too many small parts
    parts_to_delay_insert = 3000,                 -- Start slowing down inserts
    parts_to_throw_insert = 5000,                 -- Block inserts if too many parts
    inactive_parts_to_delay_insert = 1000,
    inactive_parts_to_throw_insert = 2000,
    
    -- Merge optimization for your 4 vCPU setup
    max_bytes_to_merge_at_max_space_in_pool = 1073741824,  -- 1GB max merge size
    merge_max_block_size = 4096,                  -- Smaller blocks = less memory per merge
    
    -- Write optimization
    min_bytes_for_wide_part = 104857600,          -- 100MB threshold for wide parts
    min_rows_for_wide_part = 1000000              -- 1M rows threshold