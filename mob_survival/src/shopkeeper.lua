local shopkeeper= {
  initial_properties = {
    hp_max = 100,
    physical = true,
    collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
    visual = "mesh",
    mesh = "character.b3d",
    textures = {"character.png"},
    nametag = "Shopkeeper"
  },

  -- where we'll store the arena associated to the king, to use it in the callbacks
  -- that follow
  arena = {},

  -- if the server crashes, we instantly remove the leftover king (staticdata is
  -- the arena name only when spawned by this mod; there is no get_staticdata())
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
  end
}

minetest.register_entity("mob_survival:shopkeeper", shopkeeper)