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
    properties = {
      diff = 1,
      wave_cleared = false,
      shopkeeper = nil,
      seconds = 0
    },
    spectator_properties = {
      diff_on_elim = 0
    },  
    is_team_chat_default = false,
    end_when_too_few = false,
    show_nametags = true,
    eliminate_on_death = false,
    spectate_mode = "blind",
    min_players = 1,
    hotbar = {
        slots = 8,
        background_image = "arenalib_gui_hotbar2.png"
      },
    }
)

mob_survival.player_queue = {}

minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  minetest.chat_send_player(name, "Welcome to the minigame Mob Survival! You have now been queued for the next game. "..
  "If you want to leave the queue and go back to the lobby, use the command /leave")
  local id, arena = arena_lib.get_arena_by_name("mob_survival", "sphinx")
  if not arena.in_game and arena.players_amount < 4 then
    arena_lib.join_queue("mob_survival", arena, name)
  else
    table.insert(mob_survival.player_queue, name)
  end
end)

local function hop_player_to_lobby(name)
  tribyu_api.msp.hop_player(name, "Lobby", function(success, data)
      if success then -- API call success 
          if data.success then -- Hop success
              core.log("action", "hop_player success")
          else -- Hop failed, check reason
              core.log("warning", "hop_player fail: " .. data.reason)
          end
      elseif data then -- API call returned failed status with known reason
          ore.log("error", "hop_player fail: " .. data.reason)
      else -- API call failed with unknown reason (most likely server or network issues)
          core.log("error", "hop_player api call failure")
      end
  end)
end

minetest.register_chatcommand("leave", {
  description = "Leave the match/queue",
  func = function(name)
    if arena_lib.is_player_playing(name, "mob_survival") then
      local id, arena = arena_lib.get_arena_by_name("mob_survival","sphinx")
      arena_lib.remove_player_from_arena(name, 3, "Server")
      --hop_player_to_lobby(name)
    else
      arena_lib.remove_player_from_queue(name)
    end
  end
})

arena_lib.register_on_leave_queue(function(mod, arena, p_name, has_queue_status_changed)
  --hop_player_to_lobby(p_name)
end)

arena_lib.on_join_queue("mob_survival", function(arena, p_name)
  if arena.players_amount == 4 then
    arena_lib.force_start(nil, "mob_survival", arena)
  end
end)
mob_survival.path = minetest.get_modpath(minetest.get_current_modname())

dofile(mob_survival.path.."/src/files_loader.lua")
dofile(mob_survival.path.."/src/api.lua")
dofile(mob_survival.path.."/src/shop.lua")
dofile(mob_survival.path.."/src/shopkeeper.lua")
dofile(mob_survival.path.."/src/arena_manager.lua")