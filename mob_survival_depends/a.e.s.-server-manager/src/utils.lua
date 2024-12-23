function server_manager.warn_player(name, msg)
    core.chat_send_player(name, core.colorize("#e6482e", "[!] " .. msg))
end



function server_manager.warn_server(msg)
    core.chat_send_all("\n[!!] " .. core.colorize("#eea160", msg .. "\n"))
end



function server_manager.get_time_in_seconds()
    return core.get_us_time() / 1000000
end