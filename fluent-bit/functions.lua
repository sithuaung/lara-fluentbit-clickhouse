function transform_audit_log(tag, timestamp, record)
    -- Debug: Print the entire record structure
    print("DEBUG: Full record structure:")
    for k, v in pairs(record) do
        print("Key: " .. tostring(k) .. ", Type: " .. type(v))
    end

    -- Debug: Check if we have the expected structure
    if record["log"] then
        print("DEBUG: Found 'log' field, attempting to parse")
        local log_data = record["log"]
        if type(log_data) == "string" then
            print("DEBUG: Log data is string: " .. log_data)
            -- Try to parse the string as JSON
            local success, parsed = pcall(function() return json.decode(log_data) end)
            if success then
                print("DEBUG: Successfully parsed JSON from log string")
                record = parsed
            else
                print("DEBUG: Failed to parse JSON from log string")
            end
        end
    end

    -- Extract the audit log data from the record
    local audit_data = record["new_values"] or {}
    
    -- Create the transformed record
    local new_record = {
        -- Generate a new UUID for the record
        id = record["new_values"] and record["new_values"]["id"] and record["new_values"]["id"]["Ramsey\\Uuid\\Lazy\\LazyUuidFromString"] or nil,
        
        -- Service information
        service_name = record["service_name"] or "unknown",
        version = record["version"] or "1.0",
        source = record["source"] or "unknown",
        
        -- Event information
        event_type = record["event"] or "unknown",
        event_time = record["event_time"] or os.date("!%Y-%m-%d %H:%M:%S"),
        
        -- Actor information
        actor_type = record["user_type"],
        actor_id = record["user_id"],
        
        -- Entity information
        entity_type = record["auditable_type"],
        entity_id = record["auditable_id"] and record["auditable_id"]["Ramsey\\Uuid\\Lazy\\LazyUuidFromString"] or nil,
        
        -- Data changes
        old_data = json.encode(record["old_values"] or {}),
        new_data = json.encode(record["new_values"] or {}),
        
        -- Additional metadata
        metadata = record["metadata"],
        description = record["new_values"] and record["new_values"]["description"],
        
        -- Tags and correlation
        tags = record["tags"] or {},
        correlation_id = nil,  -- You can add correlation ID if available
        
        -- Timestamp
        created_at = os.date("!%Y-%m-%d %H:%M:%S")
    }
    
    return 2, timestamp, new_record
end 