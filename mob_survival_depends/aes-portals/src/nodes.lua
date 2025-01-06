minetest.register_node("aes_portals:portal_lobby",{
  description = "Lobby portal",
  drawtype = "liquid",
  inventory_image = "aesportals_bl.png^[verticalframe:4:1",
  tiles = {{
    name = "aesportals_bl.png",
    animation = {
      backface_culling = true,
      type = "vertical_frames",
      aspect_w = 16,
      aspect_h = 16,
      length = 0.5,
    },
  }
  },
  liquidtype = "none",
  post_effect_color = {a = 103, r = 40, g = 224, b = 223},
  light_source = 8,
  walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
  drop = "",
})