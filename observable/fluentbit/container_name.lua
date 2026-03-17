function simplify_container_metadata(tag, timestamp, record)
    new_record = record
    new_record["container_id_short"] = string.sub(tag, 8, 19)
    return 1, timestamp, new_record
end