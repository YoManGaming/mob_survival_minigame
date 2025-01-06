local minigames = hub.settings.metrics_minigames
local exclude = hub.settings.metrics_exclude
local games_launched


local function init_histogram()
  local ids = {}

  for mg, id in pairs(minigames) do
    ids[id] = id
  end

  -- controllo se i dati inseriti siano corretti; after perché i minigiochi
  -- potrebbero caricare dopo Hub e non venire quindi letti
  minetest.after(0.1, function()
    for mg, _ in pairs(minigames) do
      if not arena_lib.mods[mg] then
        minetest.log("warning", "[HUB METRICS] Minigame " .. mg .. " doesn't exist!")
      elseif exclude[mg] then
        for a_name, _ in pairs(exclude[mg]) do
          if not arena_lib.get_arena_by_name(mg, a_name) then
            minetest.log("warning", "[HUB METRICS] Arena " .. a_name .. " doesn't exist!")
          end
        end
      end
    end
  end)

  games_launched = monitoring.histogram("games_launched", "games launched", ids)
end

init_histogram()





arena_lib.register_on_load(function(mod, arena)
  local mg_id = minigames[mod]

  if not mg_id or (exclude[mod] and exclude[mod][arena.name]) then return end

  games_launched.count = games_launched.count + 1
  games_launched.sum = games_launched.sum + 1
  games_launched.bucketvalues[mg_id] = games_launched.bucketvalues[mg_id] + 1
end)



arena_lib.register_on_end(function(mod, arena, winners, is_forced)
  local mg_id = minigames[mod]

  if not mg_id or (exclude[mod] and exclude[mod][arena.name]) then return end

  games_launched.bucketvalues[mg_id] = games_launched.bucketvalues[mg_id] - 1
end)