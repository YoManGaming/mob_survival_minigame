local spawn_point = hub.settings.hub_spawn_point
local y_limit = hub.settings.y_limit



local function y_check()
  minetest.after(1, function()
    for _, pl in pairs(hub.get_players_in_hub(true)) do
      if not minetest.check_player_privs(pl:get_player_name(), "hub_admin") then
        if pl:get_pos().y < y_limit then
          pl:set_pos(spawn_point)
        end
      end
    end

    y_check()
  end)
end



y_check()