local S = minetest.get_translator("aes_portals")



function aes_portals.print_error(p_name, msg)
    if not p_name or not minetest.get_player_by_name(p_name) then
      -- se ci sono stringhe tradotte, le ripulisco
      if msg:find("\27%(T@[%w_-]+%)") then
        msg = msg:gsub("\27%(T@[%w_-]+%)", "")  -- removing \27(T@mod_name)
        msg = msg:gsub("\27F", "")
        msg = msg:gsub("\27E", "")
      end

      minetest.log("error", "[AES_PORTALS] [!] " .. msg)
    else
      minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] @1", msg)))
    end
  end



  function aes_portals.print_info(p_name, msg)
    if not p_name or not minetest.get_player_by_name(p_name) then
      -- se ci sono stringhe tradotte, le ripulisco
      if msg:find("\27%(T@[%w_-]+%)") then
        msg = msg:gsub("\27%(T@[%w_-]+%)", "")  -- removing \27(T@mod_name)
        msg = msg:gsub("\27F", "")
        msg = msg:gsub("\27E", "")
      end

      minetest.log("action", "[AES_PORTALS] " .. msg)
    else
      minetest.chat_send_player(p_name, msg)
    end
  end