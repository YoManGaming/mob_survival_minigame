minetest.register_on_joinplayer(function(player)
  collectible_skins.init_player(player)
end)
