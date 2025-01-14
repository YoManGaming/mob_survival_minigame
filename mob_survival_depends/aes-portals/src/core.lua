local S = minetest.get_translator("aes_portals")
local storage = minetest.get_mod_storage()

local function check_portal_node() end

local exceptions = {block_league = {}, fantasy_brawl = {}}
local just_checked = {}

if storage:get_string("exceptions") ~= "" then
  exceptions = minetest.deserialize(storage:get_string("exceptions"))
end



minetest.register_globalstep(function(dtime)
  for _, pl in pairs(hub.get_players_in_hub(true)) do
    local p_node_name = minetest.get_node(pl:get_pos()).name
    local pl_name = pl:get_player_name()

    -- se han appena toccato un portale, non controllo per un secondo
    if not just_checked[pl_name] then
      check_portal_node("mob_survival", "aes_portals:portal_lobby", nil, p_node_name, pl_name)
    end
  end
end)



----------------------------------------------
---------------------CORE---------------------
----------------------------------------------

function aes_portals.link(mod, id)
  local mod_ref = arena_lib.mods[mod]
  if not mod_ref or not mod_ref.arenas[id] or not exceptions[mod][id] then return end

  exceptions[mod][id] = nil
  storage:set_string("exceptions", minetest.serialize(exceptions))
end



function aes_portals.unlink(mod, id)
  local mod_ref = arena_lib.mods[mod]
  if not mod_ref or not mod_ref.arenas[id] or exceptions[mod][id] then return end

  exceptions[mod][id] = true
  storage:set_string("exceptions", minetest.serialize(exceptions))
end



function aes_portals.get_linked_arenas(mod)
  if not arena_lib.mods[mod] then return end

  local list = {}
  local arenas

  if mod == "block_league" then
    arenas = BL_ARENAS
  elseif mod == "fantasy_brawl" then
    arenas = FB_ARENAS
  else
    return
  end

  for id, arena in pairs(arenas) do
    if not exceptions[mod][id] then
      list[id] = arena.name
    end
  end

  return list
end




local portal_enabled = true
----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

local function send_player_to(name, param)
  tribyu_api.msp.hop_player(name, param, function(success, data)
    if success then -- API call success 
      if data.success then -- Hop success
        core.log("action", "hop_player success")
      else -- Hop failed, check reason
        core.log("warning", "hop_player fail: " .. data.reason)
      end
    elseif data then -- API call returned failed status with known reason
      core.log("error", "hop_player fail: " .. data.reason)
    else -- API call failed with unknown reason (most likely server or network issues)
      core.log("error", "hop_player api call failure")
    end
  end)
end

function check_portal_node(mod, portal_node, arenas, p_node_name, p_name)
  if p_node_name == portal_node and not arena_lib.is_player_in_queue(p_name, mod) then
    if portal_enabled then
      send_player_to(p_name, "Lobby")
    else
      arena_lib.HUD_send_msg("broadcast", p_name, "This portal is not enabled yet!")
    end
  elseif p_node_name == portal_node then
    arena_lib.HUD_send_msg("broadcast", p_name, "Leave the minigame queue first before you can use this!")
  else
    arena_lib.HUD_hide("broadcast", p_name)
  end
end