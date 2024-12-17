mob_survival = {}

--set world spawn
minetest.register_chatcommand("setspawn", {
  description = "Set server spawnpoint",
  privs = "server",
  params = "[save]",
  func = function(name, param)
          local player = minetest.get_player_by_name(name)
          if not player then
                  return false, "Must be in-game!"
          end

          local pos = player:get_pos()
          if param == "save" then                          
                  return true, minetest.pos_to_string(pos)
          end
          return false, "Use /setspawn save"
  end,
})

arena_lib.register_minigame("mob_survival", {
    name = "Mob Survival",
    prefix = "[Mob Survival] ",
    teams = {
        "Players",
      },
    teams_color_overlay = {
        "blue"
      },
    is_team_chat_default = true,
    min_players = 1,
    hotbar = {
        slots = 8,
        background_image = "arenalib_gui_hotbar2.png"
      },
    properties = {
        spectator_jail = {x = -2, y = 29, z = -34}
      }
      
    }
)

-- Autoqueue for arena
--[[ minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  minetest.chat_send_player(name, "Welcome to the minigame Mob Survival! You have now been queued for the next game. "..
  "If you want to leave the queue and go back to the lobby, use the command /leave")
  id, arena = arena_lib.get_arena_by_name("mob_survival","mob_arena")
  arena_lib.join_queue("mob_survival", arena, name)
end)

minetest.register_chatcommand("leave", {
  description = "Leave",
  func = function(name)
    if arena_lib.is_player_playing(name, "mob_survival") then
      id, arena = arena_lib.get_arena_by_name("mob_survival","mob_arena")
      arena_lib.remove_player_from_arena(name, arena, "Server")
      -- TODO: Send to lobby server
    end
  end
})
 ]]
mob_survival.path = minetest.get_modpath(minetest.get_current_modname())

dofile(mob_survival.path.."/src/files_loader.lua")
dofile(mob_survival.path.."/src/arena_manager.lua")
dofile(mob_survival.path.."/src/api.lua")
dofile(mob_survival.path.."/src/shop.lua")
dofile(mob_survival.path.."/src/shopkeeper.lua")