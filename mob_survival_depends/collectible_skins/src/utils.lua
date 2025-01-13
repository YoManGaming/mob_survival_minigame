function collectible_skins.print_warning(msg)
  -- se ci sono stringhe tradotte, le ripulisco
  if msg:find("\27%(T@[%w_-]+%)") then
    msg = msg:gsub("\27%(T@[%w_-]+%)", "")  -- removing \27(T@mod_name)
    msg = msg:gsub("\27F", "")
    msg = msg:gsub("\27E", "")
  end

  minetest.log("warning", "[COLLECTIBLE_SKINS] [!] " .. msg)
end