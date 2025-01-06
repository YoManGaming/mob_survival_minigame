local S = core.get_translator("server_manager")


core.register_on_joinplayer(function(player)
    local pl_name = player:get_player_name()
    local info = core.get_player_information(pl_name)

    if
        info.version_string
        and (
            string.match(info.version_string, "dragonfire")
            or string.match(info.version_string, "c47eae3")  -- release 2021.03
            or string.match(info.version_string, "b7abc8d")  -- release 2021.05
            or string.match(info.version_string, "350b6d1")  -- release 2022.05
        )
    then
        core.kick_player(pl_name, S("Dragonfire is not allowed on this server."))
        core.log("warning", pl_name.. " tried to join with an unsupported client version.")
    end

    player:set_lighting({
        shadows = {intensity = server_manager.default_shadow_intensity},
        bloom = {intensity = server_manager.default_bloom_intensity}
    })
end)
