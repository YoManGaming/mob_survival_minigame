local function update_leaderboard(leaderboardzombie)
    local leaderboard = mob_survival.get_leaderboard()
    local text = "Leaderboard:"
  
    local max_entries = 10
    if leaderboard then
        for place, def in pairs(leaderboard) do
            if place > max_entries then break end
            text = text.."\n#"..place..": "..def.player..", score: "..def.score
        end
    end

    leaderboardzombie:set_nametag_attributes({
        text = text,
        color = {a=255, r=255, g=255, b=255},
    })
  
    minetest.after(1, function()
      update_leaderboard(leaderboardzombie)
    end)
  end

local leaderboardzombie = {
    initial_properties = {
      hp_max = 100,
      physical = true,
      collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
      visual = "mesh",
      mesh = "mobs_mc_zombie.b3d",
      textures = {"mobs_mc_empty.png", "mobs_mc_zombie.png"},
    },

    on_activate = function(self, staticdata, dtime_s)
        if staticdata == "" then
          self.object:remove()
          return
        end
        update_leaderboard(self.object)

        local pos2 = {x=10078,y=4.5,z=545} --Spawn point for players
        local pos1=self.object:get_pos()
        local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
        local yaw = math.atan(vec.z/vec.x)-math.pi/2
        if pos1.x >= pos2.x then yaw = yaw+math.pi end
        self.object:set_yaw(yaw)
      end,

    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
        return true
    end,
}

minetest.register_entity("mob_survival:leaderboardzombie", leaderboardzombie)