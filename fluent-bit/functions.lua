function format_for_clickhouse(tag, timestamp, record)
    -- Discard the logs that are not StdErrLog
    if type(record.message) ~= "string" or record.message ~= "app.audit" then
        print("LUA_FILTER: Discarding record - 'message' is not 'app.audit'. Actual message: " .. tostring(record.message))
        return -1, timestamp, record
    end

    -- Skip if no audit data (but log why)
    if not record.context and not record.audit_data then
        print("LUA_FILTER: No context or audit_data found")
        return -1, timestamp, record
    end

    -- Determine the audit data source
    local audit_data = record.context or {}
    if not record.context and record.audit_data then
        local ok, parsed = pcall(json.decode, record.audit_data)
        if ok then
            audit_data = parsed
        else
            print("LUA_FILTER: FAILED to parse audit_data: " .. tostring(record.audit_data))
            return -1, timestamp, record
        end
    end

    -- Log the extracted audit data
    print("LUA_FILTER: AUDIT DATA")
    for k, v in pairs(audit_data) do
        print(string.format("%s: %s", k, type(v) == "table" and "table" or tostring(v)))
    end

    -- Helper function to clean datetime strings
    local function clean_datetime(dt_str)
        if type(dt_str) == "string" then
            -- Remove escaped quotes and clean up the string
            dt_str = dt_str:gsub('\\"', '"')  -- Replace escaped quotes
            dt_str = dt_str:gsub('^"', ''):gsub('"$', '')  -- Remove surrounding quotes
            -- Remove microseconds for ClickHouse DateTime compatibility
            dt_str = dt_str:gsub('%.%d+', '')  -- Remove .xxx part (microseconds)
            return dt_str
        end
        return dt_str
    end


    -- Helper function to properly encode JSON for ClickHouse
    local function encode_for_clickhouse(val)
        if type(val) == "table" then
            if next(val) == nil then
                return "[]"  -- Empty table becomes empty array
            else
                -- Build JSON manually with proper escaping
                local items = {}
                local is_array = true
                local count = 0
                
                -- Check if it's an array
                for k, v in pairs(val) do
                    count = count + 1
                    if type(k) ~= "number" or k ~= count then
                        is_array = false
                        break
                    end
                end
                
                if is_array then
                    -- Handle as array
                    for i, v in ipairs(val) do
                        if type(v) == "string" then
                            local escaped = tostring(v):gsub('\\', '\\\\\\\\'):gsub('"', '\\\\"')
                            table.insert(items, '"' .. escaped .. '"')
                        elseif type(v) == "number" or type(v) == "boolean" then
                            table.insert(items, tostring(v))
                        elseif v == nil then
                            table.insert(items, "null")
                        else
                            table.insert(items, '"' .. tostring(v) .. '"')
                        end
                    end
                    return "[" .. table.concat(items, ",") .. "]"
                else
                    -- Handle as object
                    for k, v in pairs(val) do
                        local key = '"' .. tostring(k):gsub('\\', '\\\\\\\\'):gsub('"', '\\\\"') .. '"'
                        local value
                        if type(v) == "string" then
                            local escaped = tostring(v):gsub('\\', '\\\\\\\\'):gsub('"', '\\\\"')
                            value = '"' .. escaped .. '"'
                        elseif type(v) == "number" or type(v) == "boolean" then
                            value = tostring(v)
                        elseif v == nil then
                            value = "null"
                        else
                            value = '"' .. tostring(v) .. '"'
                        end
                        table.insert(items, key .. ":" .. value)
                    end
                    return "{" .. table.concat(items, ",") .. "}"
                end
            end
        elseif type(val) == "string" then
            return val
        else
            return tostring(val or "")
        end
    end

    -- Create output (your exact desired format)  
    local result = {
        id = math.floor(timestamp * 1000) + math.random(1000, 9999), -- Generate unique ID based on timestamp
        service_name = audit_data.service_name or "",
        user_type = audit_data.user_type or "",
        user_id = audit_data.user_id or "",
        event = audit_data.event or "",
        occurred_at = clean_datetime(audit_data.occurred_at) or "",
        auditable_type = audit_data.auditable_type or "",
        auditable_id = audit_data.auditable_id or "",
        old_values = encode_for_clickhouse(audit_data.old_values),
        new_values = encode_for_clickhouse(audit_data.new_values),
        url = audit_data.url or "",
        ip_address = audit_data.ip_address or "",
        user_agent = audit_data.user_agent or "",
        correlation_id = audit_data.correlation_id or "",
        tags = audit_data.tags or "",
    }

    -- Log the final output
    print("LUA_FILTER: FINAL OUTPUT")
    for k, v in pairs(result) do
        print(string.format("%s: %s", k, tostring(v)))
    end
    
    -- Log that we're returning the result
    print("LUA_FILTER: Returning result to Fluent Bit")

    return 1, timestamp, result
end
