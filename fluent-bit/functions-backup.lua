function fix_quotes(tag, timestamp, record)
    local new_record = {}
    
    -- Copy all fields without the escaped quotes
    for k, v in pairs(record) do
        local clean_key = k:gsub('^\"\"', ''):gsub('\"\"$', '')
        new_record[clean_key] = v
    end
    
    -- Handle nested new_values if needed
    if new_record.new_values and type(new_record.new_values) == "table" then
        local clean_nested = {}
        for nk, nv in pairs(new_record.new_values) do
            local clean_nk = nk:gsub('^\"\"', ''):gsub('\"\"$', '')
            clean_nested[clean_nk] = nv
        end
        new_record.new_values = clean_nested
    end
    
    return 1, timestamp, new_record
end

-- function parse_metadata(tag, timestamp, record)
--     if record.new_values and record.new_values.metadata and type(record.new_values.metadata) == "string" then
--         local ok, json_data = pcall(function() 
--             return json.decode(record.new_values.metadata) 
--         end)
--         if ok then
--             record.new_values.metadata = json_data
--         end
--     end
--     return 1, timestamp, record
-- end

-- function parse_metadata(tag, timestamp, record)
--     if record.new_values and record.new_values.metadata and type(record.new_values.metadata) == "string" then
--         local ok, json_data = pcall(function() 
--             return json.decode(record.new_values.metadata) 
--         end)
--         if ok then
--             record.new_values.metadata = json_data
--         else
--             record.new_values.metadata = nil
--         end
--     end
--     return 1, timestamp, record
-- end

function extract_and_fix_json(tag, timestamp, record)
    -- First check if we have the log field
    if not record.log then
        return 1, timestamp, record
    end
    
    -- Extract the JSON content from the log field
    local json_str = record.log:match('ClickHouseAuditLogger%s+({.+})')
    if not json_str then 
        return 1, timestamp, record 
    end
    
    -- Fix escaped quotes in the JSON string
    json_str = json_str:gsub('\\"', '"')
    
    -- Parse the JSON
    local ok, json_data = pcall(function() 
        return json.decode(json_str) 
    end)
    if not ok then 
        return 1, timestamp, record 
    end
    
    -- Create new record with context fields promoted
    local new_record = {}
    if json_data.context then
        for k, v in pairs(json_data.context) do
            new_record[k] = v
        end
    end
    
    -- Parse metadata if exists
    if new_record.new_values and 
       new_record.new_values.metadata and 
       type(new_record.new_values.metadata) == "string" then
        local ok, meta = pcall(function() 
            return json.decode(new_record.new_values.metadata) 
        end)
        if ok then
            new_record.new_values.metadata = meta
        else
            new_record.new_values.metadata = nil
        end
    end
    
    return 1, timestamp, new_record
end


function extract_audit_data(tag, timestamp, record)
    -- Case 1: Direct context available
    if record.context then
        local new_record = record.context
        
        -- Parse metadata if exists
        if new_record.new_values and new_record.new_values.metadata then
            local ok, meta = pcall(function() 
                return json.decode(new_record.new_values.metadata) 
            end)
            if ok then new_record.new_values.metadata = meta end
        end
        
        return 1, timestamp, new_record
    end

    -- Case 2: ClickHouseAuditLogger format
    if record.log then
        local json_str = record.log:match('ClickHouseAuditLogger%s+({.+})')
        if json_str then
            local ok, json_data = pcall(function() 
                return json.decode(json_str:gsub('\\"', '"')) 
            end)
            if ok and json_data.context then
                -- Parse metadata
                if json_data.context.new_values and json_data.context.new_values.metadata then
                    local ok, meta = pcall(function() 
                        return json.decode(json_data.context.new_values.metadata) 
                    end)
                    if ok then json_data.context.new_values.metadata = meta end
                end
                return 1, timestamp, json_data.context
            end
        end
    end

    -- Fallthrough: return original if no match
    return 1, timestamp, record
end

function prepare_for_clickhouse(tag, timestamp, record)
    -- 1. Ensure required fields
    record.created_at = os.date("!%Y-%m-%d %H:%M:%S")
    
    -- 2. Convert old_values to proper JSON string
    if type(record.old_values) == "table" then
        record.old_values = json.encode(record.old_values)
    else
        record.old_values = "[]"  -- Default empty array
    end
    
    -- 3. Convert new_values to proper JSON string
    if type(record.new_values) == "table" then
        -- Handle metadata field separately
        if record.new_values.metadata and type(record.new_values.metadata) == "string" then
            local ok, meta = pcall(function() 
                return json.decode(record.new_values.metadata) 
            end)
            if ok then
                record.new_values.metadata = meta
            end
        end
        record.new_values = json.encode(record.new_values)
    else
        record.new_values = "{}"  -- Default empty object
    end
    
    -- 4. Escape backslashes in auditable_type
    if record.auditable_type then
        record.auditable_type = record.auditable_type:gsub("\\", "\\\\")
    end
    
    -- 5. Remove unnecessary fields
    record.source = nil
    
    return 1, timestamp, record
end

function format_for_clickhouse(tag, timestamp, record)
    -- Ensure required fields exist
    record.created_at = os.date("!%Y-%m-%d %H:%M:%S")
    
    -- Properly escape JSON strings
    local function escape_json(v)
        if type(v) == "string" then
            return v:gsub('"', '\\"')
        end
        return v
    end

    -- Convert values to properly escaped JSON strings
    record.old_values = type(record.old_values) == "table" and 
                       json.encode(record.old_values) or 
                       "[]"
    
    if type(record.new_values) == "table" then
        -- Handle metadata separately
        if record.new_values.metadata then
            if type(record.new_values.metadata) == "string" then
                -- Already stringified, just escape
                record.new_values.metadata = escape_json(record.new_values.metadata)
            else
                record.new_values.metadata = json.encode(record.new_values.metadata)
            end
        end
        record.new_values = json.encode(record.new_values)
    else
        record.new_values = "{}"
    end
    
    -- Remove problematic fields
    record.date = nil
    record.container_id = nil
    record.container_name = nil
    record.log = nil
    
    return 1, timestamp, record
end