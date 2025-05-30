function format_for_clickhouse(tag, timestamp, record)
    -- Discard the logs that are not StdErrLog
    if type(record.message) ~= "string" or record.message ~= "ClickHouseAuditLogger" then
        print("LUA_FILTER: Discarding record - 'message' is not 'ClickHouseAuditLogger'. Actual message: " .. tostring(record.message))
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
        event_time = audit_data.event_time,
        -- user_id = audit_data.user_id,
        -- user_type = audit_data.user_type
    }

    -- Log the final output
    print("LUA_FILTER: FINAL OUTPUT")
    for k, v in pairs(result) do
        print(string.format("%s: %s", k, type(v) == "table" and "table" or tostring(v)))
    end

    return 1, timestamp, result
end
