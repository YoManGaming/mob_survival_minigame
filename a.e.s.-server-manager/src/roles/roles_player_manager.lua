local S = core.get_translator("server_manager")



core.register_on_joinplayer(function(player, last_login)
    local pl_name = player:get_player_name()
    local pl_roles = roles.get_roles(pl_name)

    -- removing expired roles
    for _, role_ref in ipairs(pl_roles) do
        if type(role_ref) == "table" then  -- an expiring role
            local current_time = server_manager.get_time_in_seconds()
            if current_time > role_ref[2] then
                local role_name = S(roles.get_def(role_ref[1]).name)
                server_manager.warn_player(pl_name, S("Your \"@1\" role has expired!",  role_name))
                roles.remove_role(pl_name, role_ref[1])
            end
        end
    end

    roles.update_roles(pl_name)
end)