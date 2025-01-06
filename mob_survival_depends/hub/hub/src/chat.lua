local S = minetest.get_translator("hub")

hub.chat = true



minetest.register_on_chat_message(function(p_name, message)
  if not arena_lib.is_player_in_arena(p_name) and not hub.chat and not minetest.get_player_privs(p_name)["hub_admin"] then
    hub.print_error(p_name, S("Chat in the hub is temporarily disabled"))
    return true
  end
end)
