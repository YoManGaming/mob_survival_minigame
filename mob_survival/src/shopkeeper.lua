local shopkeeper = {
  initial_properties = {
    hp_max = 100,
    physical = true,
    collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
    visual = "mesh",
    mesh = "character.b3d",
    textures = {"detailed_computer_terminal_skin.png"},
    nametag = "Shop"
  },

  arena = {},

  on_activate = function(self, staticdata, dtime_s)
    if staticdata == "" then
      self.object:remove()
      return
    end

    local _, arena = arena_lib.get_arena_by_name("mob_survival:shopkeeper", staticdata)
    self.arena = arena
end,

  on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
      mob_survival.open_shop(puncher, "guns")
      return true
    end,
  
  on_rightclick = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    mob_survival.open_shop(puncher, "guns")
    return true
  end,

  on_blast = function(self, damage)
    return false, false, {}
  end
}

minetest.register_entity("mob_survival:shopkeeper", shopkeeper)