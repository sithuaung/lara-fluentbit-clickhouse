function extract_audit_log(tag, timestamp, record)
    print("Extract Audit Log")

    -- Skip non-audit records
    if not record.context and not (record.message == "ClickHouseAuditLogger") then
        return -1, timestamp, record
    end

    -- Get the audit data from either format
    local audit_data = record.context or {}
    if not record.context and record.log then
        local json_str = record.log:match('ClickHouseAuditLogger%s+({.+})')
        if json_str then
            local ok, parsed = pcall(json.decode, json_str)
            if ok and parsed.context then
                audit_data = parsed.context
            end
        end
    end

    -- Create your exact desired output structure
    local result = {
        old_values = audit_data.old_values or {},
        new_values = audit_data.new_values or {},
        event = audit_data.event,
        auditable_id = audit_data.auditable_id,
        auditable_type = audit_data.auditable_type,
        user_id = audit_data.user_id,
        user_type = audit_data.user_type,
        tags = audit_data.tags,
        ip_address = audit_data.ip_address,
        user_agent = audit_data.user_agent,
        url = audit_data.url,
        service_name = audit_data.service_name,
        version = audit_data.version,
        source = audit_data.source,
        event_time = audit_data.event_time
    }

    -- Ensure metadata remains as string if it exists
    if result.new_values and result.new_values.metadata and type(result.new_values.metadata) == "table" then
        result.new_values.metadata = json.encode(result.new_values.metadata)
    end

    return 1, timestamp, result
end

function format_for_clickhouse(tag, timestamp, record)
    -- Log the incoming record
    -- print("--- INCOMING RECORD ---")
    -- for k, v in pairs(record) do
    --     print(string.format("%s: %s", k, type(v) == "table" and "table" or tostring(v)))
    -- end

    -- Skip if no audit data (but log why)
    if not record.context and not record.audit_data then
        -- print("SKIPPING: No context or audit_data found")
        return -1, timestamp, record
    end

    -- Determine the audit data source
    local audit_data = record.context or {}
    if not record.context and record.audit_data then
        local ok, parsed = pcall(json.decode, record.audit_data)
        if ok then
            audit_data = parsed
        else
            -- print("FAILED to parse audit_data: " .. tostring(record.audit_data))
            return -1, timestamp, record
        end
    end

    -- Log the extracted audit data
    -- print("--- AUDIT DATA ---")
    -- for k, v in pairs(audit_data) do
    --     print(string.format("%s: %s", k, type(v) == "table" and "table" or tostring(v)))
    -- end

    -- Create output (your exact desired format)
    local result = {
        -- old_values = audit_data.old_values or {},
        old_values = audit_data.old_values and (type(audit_data.old_values) == "table" and
            (next(audit_data.old_values) == nil and "[]" or json.encode(audit_data.old_values)) or audit_data.old_values) or
            "[]",
        new_values = audit_data.new_values or {},
        event = audit_data.event,
        auditable_id = audit_data.auditable_id,
        auditable_type = audit_data.auditable_type,
        ip_address = audit_data.ip_address,
        user_agent = audit_data.user_agent,
        url = audit_data.url,
        service_name = audit_data.service_name,
        version = audit_data.version,
        source = audit_data.source,
        event_time = audit_data.event_time
    }

    -- Log the final output
    -- print("--- FINAL OUTPUT ---")
    -- for k, v in pairs(result) do
    --     print(string.format("%s: %s", k, type(v) == "table" and "table" or tostring(v)))
    -- end

    return 1, timestamp, result
end
