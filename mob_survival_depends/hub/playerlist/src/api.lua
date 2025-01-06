local ping = {}
local MAX_SLOTS = hub.settings.plist_max_slots



local function update_ping()
  local players = minetest.get_connected_players()
  for i = 1, math.min(#players, MAX_SLOTS) do
    local pl_name = players[i]:get_player_name()
    ping[pl_name] = math.max(1, math.ceil(4 - (minetest.get_player_information(pl_name).avg_rtt or 0) * 50))
  end
  playerlist.HUD_update("ping")

  minetest.after(10, function() update_ping() end)
end

minetest.after(0.1, function()
  update_ping()
end)

function playerlist.get_ping(p_name)
  return ping[p_name]
end
