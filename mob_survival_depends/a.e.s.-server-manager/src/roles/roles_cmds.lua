ChatCmdBuilder.new("role", function(cmd)
    cmd:sub("unlock :plname:username :role", function(name, target, role_name)
        if not roles.def[role_name] then
            server_manager.warn_player(name, "The role doesn't exist!")
            return
        end
        
        if roles.unlock_role(target, role_name) then
            core.chat_send_player(name, "Role unlocked")
        else
            server_manager.warn_player(name, "Role already unlocked!")
        end
    end)

    cmd:sub("remove :plname:username :role", function(name, target, role_name)
        if not roles.def[role_name] then
            server_manager.warn_player(name, "The role doesn't exist!")
            return
        end

        if roles.remove_role(target, role_name) then
            core.chat_send_player(name, "Role removed")
        else
            server_manager.warn_player(name, "Role not unlocked!")
        end
    end)

    cmd:sub("equip :plname:username :role", function(name, target, role_name)
        if not roles.def[role_name] then
            server_manager.warn_player(name, "The role doesn't exist!")
            return
        end

        if roles.set_equipped_role(target, role_name) then
            core.chat_send_player(name, "Role equipped")
        else
            server_manager.warn_player(name, "Role not unlocked!")
        end
    end)

    cmd:sub("unequip :plname:username", function(name, target)
        if roles.clear_equipped_role(target) then
            core.chat_send_player(name, "Role unequipped")
        else
            server_manager.warn_player(name, "Role not unlocked!")
        end
    end)

    cmd:sub("setstatic :plname:username :role", function(name, target, role_name)
        if not roles.def[role_name] then
            server_manager.warn_player(name, "The role doesn't exist!")
            return
        end

        if roles.set_static_role(target, role_name) then
            core.chat_send_player(name, "Role set as static")
        else
            server_manager.warn_player(name, "Role not unlocked!")
        end
    end)

    cmd:sub("renew :plname:username :role", function(name, target, role_name)
        if not roles.def[role_name] then
            server_manager.warn_player(name, "The role doesn't exist!")
            return
        end
        
        if roles.renew(target, role_name) then
            core.chat_send_player(name, "Role renewed")
        else
            server_manager.warn_player(name, "Role not unlocked!")
        end
    end)

    cmd:sub("list", function(name)
        local list = ""
        for name, _ in pairs(roles.def) do
            list = list..name..", "
        end
        core.chat_send_player(name, "Roles list: "..list)
    end)

    cmd:sub("list :plname:username", function(name, target)
        local list = ""
        for i, ref in pairs(roles.get_roles(target)) do
            local name = ref
            if type(ref) == "table" then
                name = ref[1]
            end
            list = list..name..", "
        end
        core.chat_send_player(name, target.." roles list: "..list)
    end)
end, {
  description = [[

  ADMIN COMMANDS
  /role unlock <player> <role>
  /role remove <player> <role>
  /role equip <player> <role>
  /role unequip <player>
  /role setstatic <player> <role>
  /role renew <player> <role>
  /role list [player]
  ]],
  privs = { server = true }
})