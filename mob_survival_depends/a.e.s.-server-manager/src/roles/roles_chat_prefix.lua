local format_chat_message = core.format_chat_message



function core.format_chat_message(p_name, msg)
    local static_role = roles.get_static_role(p_name)
    local equipped_role = roles.get_equipped_role(p_name)
    local default_role = roles.def["default"]
    local static_prefix = ""
    local equipped_prefix = ""

    if static_role and static_role.prefix then
        static_prefix = core.colorize(static_role.prefix_color or "#ffffff", static_role.prefix .. " ")
    elseif default_role.prefix then
        static_prefix = core.colorize(default_role.prefix_color or "#ffffff", default_role.prefix .. " ")
    end

    if equipped_role and equipped_role.prefix then
        equipped_prefix = core.colorize(equipped_role.prefix_color or "#ffffff", equipped_role.prefix .. " ")
    end

    if arena_lib.is_player_in_arena(p_name) then
        return format_chat_message(p_name, msg)
    else
        return static_prefix .. equipped_prefix .. format_chat_message(p_name, msg)
    end
end
