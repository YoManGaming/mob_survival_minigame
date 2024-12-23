if minetest.get_modpath("3d_armor") then
	armor.get_player_skin = function(self, p_name)
		local player = minetest.get_player_by_name(p_name)
		if not player then return end

		local pl_texture = player:get_properties().textures[1]

		if not pl_texture or pl_texture == "blank.png" then
			return collectible_skins.get_player_skin(p_name).texture
		end

		return pl_texture
	end
end
