arena_lib.register_on_load(function(mod, arena)
  for pl_name, _ in pairs (arena.players) do
    if panel_lib.get_panel(pl_name, "playerlist_data"):is_visible() then
      playerlist.HUD_hide(pl_name)
    end

    playerlist.HUD_update("minigame", pl_name)
  end
end)



arena_lib.register_on_join(function(mod, arena, p_name, as_spectator)
  if panel_lib.get_panel(p_name, "playerlist_data"):is_visible() then
    playerlist.HUD_hide(p_name)
  end

  playerlist.HUD_update("minigame", p_name)
end)



arena_lib.register_on_quit(function(mod, arena, p_name, is_spectator, reason)
  playerlist.HUD_update("minigame", p_name)
end)



arena_lib.register_on_end(function(mod, arena, winners, is_forced)
  for psp_name, _ in pairs(arena.players_and_spectators) do
    playerlist.HUD_update("minigame", psp_name)
  end
end)
