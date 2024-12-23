local S = minetest.get_translator("collectible_skins")



ChatCmdBuilder.new("skins", function(cmd)
    -- sblocco aspetti
    cmd:sub("unlock :playername :skinname", function(sender, p_name, skin_name)
      if not collectible_skins.is_skin(skin_name) then
        minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("Skin @1 doesn't exist!", skin_name)))
        return end

      if not collectible_skins.is_in_storage(p_name) then
        minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("Can't run this action if the player has never connected since the addition of Collectible Skins!")))
        return end

      if collectible_skins.has_skin(p_name, skin_name) then
        minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("Player @1 already has this skin!", p_name)))
        return end

      collectible_skins.unlock_skin(p_name, skin_name)
      minetest.chat_send_player(sender, S("Skin @1 for @2 successfully unlocked", collectible_skins.get_skin(skin_name).name, p_name))
    end)

    -- rimozione aspetti
    cmd:sub("remove :playername :skinname", function(sender, p_name, skin_name)
      if not collectible_skins.is_skin(skin_name) then
        minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("Skin @1 doesn't exist!", skin_name)))
        return end

        if not collectible_skins.is_in_storage(p_name) then
          minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("Can't run this action if the player has never connected since the addition of Collectible Skins!")))
          return end

      if not collectible_skins.has_skin(p_name, skin_name) then
        minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("Player @1 doesn't have this skin!", p_name)))
        return end

      collectible_skins.remove_skin(p_name, skin_name)
      minetest.chat_send_player(sender, S("Skin @1 for @2 successfully removed", collectible_skins.get_skin(skin_name).name, p_name))
    end)

    -- aiuto
    cmd:sub("help", function(sender)
      minetest.chat_send_player(sender,
        minetest.colorize("#ffff00", S("COMMANDS")) .. "\n"
        .. minetest.colorize("#00ffff", "/skins remove") .. " <" .. S("player") .. "> <" .. S("technical name") .. ">: " .. S("removes a skin") .. "\n"
        .. minetest.colorize("#00ffff", "/skins unlock") .. " <" .. S("player") .. "> <" .. S("technical name") .. ">: " .. S("unlocks a skin")
      )
    end)

end, {
  params = "help",
  description = S("Manage players skins. It requires cskins_admin"),
  privs = { cskins_admin = true }
})
