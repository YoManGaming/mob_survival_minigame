local S = minetest.get_translator("collectible_skins")

minetest.register_tool("collectible_skins:wardrobe", {

  description = S("Wardrobe"),
  inventory_image = "cskins_wardrobe.png",
  groups = {oddly_breakable_by_hand = 2},
  on_place = function() end,
  on_drop = function() end,

  on_use = function(itemstack, user, pointed_thing)
    collectible_skins.show_skins_GUI(user:get_player_name())
  end
})
