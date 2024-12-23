-- "pl_name" = {msg = "...", date = <date in seconds>}
server_manager.chat_logs = {}
local max_saved_messages = 10



core.register_on_chat_message(function(name, msg)
    local logs = server_manager.chat_logs
    logs[name] = logs[name] or {}

    table.insert(logs[name], {msg = msg, date = server_manager.get_time_in_seconds()})

    if #logs[name] > max_saved_messages then
        table.remove(logs[name], #logs[name] - max_saved_messages)
    end
end)