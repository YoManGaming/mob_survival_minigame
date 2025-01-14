storage = minetest.get_mod_storage()

function tablelen(T)
    local count = 0
    for k, v in pairs(T) do count = count + 1 end
    return count
end

function keyset(T)
    local keyset={}
    local n=0
    
    for k,v in pairs(T) do
        n=n+1
        keyset[n]=k
    end
    return keyset
end

function tablesearch(T, value)
    for k,v in pairs(T) do
        if v == value then
            return k
        end
    end
    return -1
end

local random = math.random

local mobnames = keyset(mob_survival.mobdiffs)

mob_survival.register_global_callback(function(mob_name, killer)
    local p_meta = killer:get_meta()
    if p_meta then
      local mob_human_name = split(mob_name, ":")[2]
      -- Handle quests data
      local quest_data = minetest.deserialize(p_meta:get_string("quest_data"))
      if quest_data[mob_human_name] then
        quest_data[mob_human_name] = quest_data[mob_human_name] + 1
      else
        quest_data[mob_human_name] = 1
      end
      p_meta:set_string("quest_data", minetest.serialize(quest_data))

      -- Handle gold and joule additions
      local gold = p_meta:get_int("gold")

      local joules_add = p_meta:get_int("joules_add")
      joules_add = joules_add + mob_survival.mob_kills_joules
      p_meta:set_int("joules_add", joules_add)
  
      if mob_survival.mob_kills_gold[mob_name] then
        local addition = mob_survival.mob_kills_gold[mob_name]
        p_meta:set_int("gold", gold+addition)
        arena_lib.HUD_send_msg("hotbar", killer:get_player_name(), "You just got "..addition.." gold for killing a "..mob_human_name.."!")
        p_meta:set_int("is_kill_HUD_active", 1)
        minetest.after(2, function(p_meta)
            p_meta:set_int("is_kill_HUD_active", 0)
        end, p_meta)
      end
    end
end)

local old_death_screen = minetest.show_death_screen

minetest.show_death_screen = function(player, reason)
	return
end

arena_lib.on_join("mob_survival", function(p_name, arena, as_spectator, was_spectator)
    local inv = minetest.get_player_by_name(p_name):get_inventory()
    if as_spectator then return end

    local sword = ItemStack("default:sword_steel")
      
    sword:get_meta():set_tool_capabilities({
        full_punch_interval = 0.8,
        groupcaps={
            snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=9999, maxlevel=2},
        },
        damage_groups = {fleshy=6},
        })
    
    inv:add_item("main", sword)
    for item, amount in pairs(mob_survival.start_items) do
        inv:add_item("main", item.." "..amount)
    end

    local player = minetest.get_player_by_name(p_name)
    local p_meta = player:get_meta()
      
    p_meta:set_int("eliminated", 0)
    p_meta:set_int("waves_survived", 0)
    p_meta:set_int("gold", 0)
    armor:remove_all(minetest.get_player_by_name(p_name))
end)

function table.copy(t)
    local t2 = {}
    -- iterate the array
    for k,v in pairs(t) 
    do
       t2[k] = v
    end
    return t2
 end

arena_lib.on_load("mob_survival", function(arena)
    arena.players_on_start = table.copy(arena.players)
    for pl_name, _ in pairs(arena.players) do
      armor:remove_all(minetest.get_player_by_name(pl_name))
      local inv = minetest.get_player_by_name(pl_name):get_inventory()
      local sword = ItemStack("default:sword_steel")
      
      sword:get_meta():set_tool_capabilities({
        full_punch_interval = 0.8,
        groupcaps={
            snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=9999, maxlevel=2},
        },
        damage_groups = {fleshy=6},
        })
    
        inv:add_item("main", sword)
      for item, amount in pairs(mob_survival.start_items) do
        inv:add_item("main", item.." "..amount)
      end

      local player = minetest.get_player_by_name(pl_name)
      local p_meta = player:get_meta()
      
      p_meta:set_int("eliminated", 0)
      p_meta:set_int("waves_survived", 0)
      p_meta:set_int("gold", 0)
      p_meta:set_int("joules_add", 0)
      p_meta:set_int("is_kill_HUD_active", 0)
      p_meta:set_int("mcl_hunger:hunger", 20)

      p_meta:set_string("quest_data", minetest.serialize({}))
    end
end)

arena_lib.on_start("mob_survival", function(arena)
    wave_clear(arena)
    local json = minetest.deserialize(storage:get_string("shopkeeper"))
    for i, pos in pairs(json) do
        if arena_lib.get_arena_by_pos(pos).name == arena.name then
            arena.shopkeeper = minetest.add_entity(pos, "mob_survival:shopkeeper", arena.name)
        end
    end
    on_time_tick(arena)
end)

local function startswith(string, start)
    return string:sub(1, #start) == start
end

function on_time_tick(arena)
    for _, entity in pairs(arena.moblist) do
        if mob_survival.mobdiffs[entity.name] then
            local nametag = entity.object:get_nametag_attributes()
            if nametag then
                if nametag.text == "" then
                    -- Refresh entityref if mob is unloaded
                    for i, mob in pairs(arena.moblist) do
                        if mob.moblist_id == entity.moblist_id then
                            arena.moblist[i] = entity
                        end
                    end

                    entity.object:set_nametag_attributes({
                        text = "V",
                        color = {a=255, r=255, g=0, b=0},
                        bgcolor = {a=0, r=0, g=0, b=0}
                    })
                end
            end
        end
    end

    for i, mob in pairs(arena.moblist) do
        if mob.health <= 0 then
            table.remove(arena.moblist, i)
        end
    end

    if not arena.shopkeeper then
        arena.shopkeeper = minetest.add_entity(pos, "mob_survival:shopkeeper", arena.name)
    end
    
    for pl_name, _ in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        local p_meta = player:get_meta()
        if p_meta:get_int("is_kill_HUD_active") == 0 then
            arena_lib.HUD_send_msg("hotbar", pl_name, "Mobs left: " .. tablelen(arena.moblist))
        end
    end

    if tablelen(arena.moblist) == 0 and not arena.wave_cleared then
        arena.wave_cleared = true
        arena.diff = arena.diff + 1
        arena.seconds = 10
        for pl_name, _ in pairs(arena.players) do
            local player = minetest.get_player_by_name(pl_name)
            local p_meta = player:get_meta()

            p_meta:set_int("waves_survived", arena.diff-1)

            local gold_player = p_meta:get_int("gold")

            if not gold_player then
                gold_player = 0
            end
            local increase
            if mob_survival.gold_addition[arena.diff-1] ~= nil then
                gold_player = gold_player + mob_survival.gold_addition[arena.diff-1]
                increase = mob_survival.gold_addition[arena.diff-1]
            else
                gold_player = gold_player + mob_survival.gold_addition[#mob_survival.gold_addition]
                increase = mob_survival.gold_addition[#mob_survival.gold_addition]
            end
            p_meta:set_int("gold", gold_player)
            arena_lib.HUD_send_msg("broadcast", pl_name, "Wave cleared! You got "..increase.." gold for clearing this wave!")
        end
    end

    if arena.wave_cleared then
        arena.seconds = arena.seconds - 1
        if arena.seconds <= 5 then
            arena_lib.HUD_send_msg_all("broadcast", arena, "Wave cleared! Wave "..arena.diff.." starts in "..arena.seconds.."!")
        end
        if arena.seconds == 0 then
            arena_lib.HUD_hide("broadcast", arena)
            wave_clear(arena)
            arena.wave_cleared = false
        end
    end

    local restart_time_tick = true
    if arena.players_amount == 0 then
        restart_time_tick = false
    end

    if restart_time_tick then
        minetest.after(1, function()
            on_time_tick(arena)
        end, arena)
    end
end

arena_lib.on_quit("mob_survival", function(arena, p_name, is_spectator, reason, p_properties)
    local player = minetest.get_player_by_name(p_name)
    local p_meta = player:get_meta()

    p_meta:set_int("eliminated", 1)
    player:set_pos({x=10078,y=4.5,z=544})
end)

--Handle eliminations
arena_lib.on_death("mob_survival", function(arena, p_name, reason)
    local player = minetest.get_player_by_name(p_name)
    local p_meta = player:get_meta()
  
    p_meta:set_int("eliminated", 1)
    arena.players[p_name].diff_on_elim = arena.diff

    arena_lib.remove_player_from_arena(p_name, 1, "mobs", nil, true)

    for ps_name, _ in pairs(arena.players) do
        if ps_name and arena.players_amount > 0 then
            local spectate_player = minetest.get_player_by_name(ps_name)
            arena_lib.spectate_target("mob_survival", arena, p_name, spectate_player, spectate_player:get_player_name())
            arena.spectators[p_name].diff_on_elim = arena.diff
            check_for_respawn(p_name, arena.name)
            break
        end
    end
end)

function check_for_respawn(pl_name, arena_name)
    local player = minetest.get_player_by_name(pl_name)
    local id, arena = arena_lib.get_arena_by_name("mob_survival", arena_name)
    if not arena.spectators[pl_name] then return end -- Check if player left using the leave item
    local diff_on_elim = arena.spectators[pl_name].diff_on_elim

    if arena.diff ~= diff_on_elim then
        arena_lib.leave_spectate_mode(pl_name)
        arena_lib.join_arena("mob_survival", pl_name, id, false, true)
        local p_meta = player:get_meta()
        p_meta:set_int("eliminated", 0)
    else
        local restart_respawn_check = true
        for pl_name, _ in pairs(arena.players) do
            local player = minetest.get_player_by_name(pl_name)
            local p_meta = player:get_meta()
    
            local players_eliminated = 0
    
            if p_meta:get_int("eliminated") == 1 then
                players_eliminated = players_eliminated + 1
                if players_eliminated == tablelen(arena.players) then
                    restart_respawn_check = false
                end
            end
        end
        if restart_respawn_check then
            minetest.after(1, function()
                check_for_respawn(pl_name, arena_name)
            end, pl_name, arena_name)
        end
    end
end

mob_survival.setup_pos = {}

minetest.register_chatcommand("/mob1", {
    description = "Set point 1 of the mob spawn",
    privs = "server",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        mob_survival.setup_pos[1] = player:get_pos()
        return true, "First pos set! Use //mob2 to create a spawn area!"
    end,
})

minetest.register_chatcommand("/shopkeeper", {
    description = "Set the spawnpoint of the shopkeeper!",
    privs = "server",
    func = function(name)
        local player = minetest.get_player_by_name(name)

        local spawn_areas = storage:get_string("shopkeeper")

        local json
        if not spawn_areas or spawn_areas == "" then
            json = {}
        else
            json = minetest.deserialize(spawn_areas)
        end

        table.insert(json, player:get_pos())

        storage:set_string("shopkeeper", minetest.serialize(json))
            
        return true, "Spawn point for shopkeeper created!"
    end,
})

minetest.register_chatcommand("/leaderboard", {
    description = "Set the spawnpoint of the leaderboard zombie",
    privs = "server",
    func = function(name)
        local player = minetest.get_player_by_name(name)

        storage:set_string("leaderboardzombie", minetest.serialize(player:get_pos()))
            
        return true, "Spawn point for leaderboard zombie created!"
    end,
})

minetest.register_chatcommand("reset_shopkeeper", {
    description = "Set the spawnpoint of the shopkeeper!",
    privs = "server",
    func = function(name)
        storage:set_string("shopkeeper", "")
            
        return true, "Spawn points for shopkeeper successfully reset!"
    end,
})

minetest.register_chatcommand("/mob2", {
    description = "Set point 1 of the mob spawn",
    privs = "server",
    func = function(name)
        if mob_survival.setup_pos[1] then
            local player = minetest.get_player_by_name(name)
            mob_survival.setup_pos[2] = player:get_pos()
            local spawn_areas = storage:get_string("spawn_areas")

            local json
            if not spawn_areas then
                json = {}
            else
                json = minetest.deserialize(spawn_areas)
            end

            if not json or json == "" then
                json = {}
            end
            
            local temp = {}
            temp[1] = mob_survival.setup_pos[1]
            temp[2] = mob_survival.setup_pos[2]

            table.insert(json, temp)
            storage:set_string("spawn_areas", minetest.serialize(json))
            
            return true, "Spawn area created!"
        else
            return false, "Use //mob1 first!"
        end
    end,
})

function wave_clear(arena)
    local totaldiff = arena.diff * mob_survival.total_mob_diff

    local currentdiff = 0
    local mobcount = 0

    while currentdiff ~= totaldiff do
        local mobID = random(1, tablelen(mobnames))
        local mobName = mobnames[mobID]
        local mobdiff = mob_survival.mobdiffs[mobName]

        local spawn_areas = minetest.deserialize(storage:get_string("spawn_areas"))

        local rand = random(1, #spawn_areas)

        -- Get a pos within the current playing arena
        while arena_lib.get_arena_by_pos(spawn_areas[rand][1]).name ~= arena.name do
            rand = random(1, #spawn_areas)
        end

        local pos = {}

        pos.x = random(spawn_areas[rand][1].x, spawn_areas[rand][2].x)

        if spawn_areas[rand][1].y > spawn_areas[rand][2].y then
            pos.y = spawn_areas[rand][1].y
        else
            pos.y = spawn_areas[rand][2].y
        end

        pos.z = random(spawn_areas[rand][1].z, spawn_areas[rand][2].z)

        if (currentdiff+mobdiff) <= totaldiff then
            mobcount = mobcount + 1
            local mob = minetest.add_entity(pos, mobName, tostring(mobcount))
            mob:set_nametag_attributes({
                text = "V",
                color = {a=255, r=255, g=0, b=0},
                bgcolor = {a=0, r=0, g=0, b=0}
            })
            table.insert(arena.moblist, mob:get_luaentity())
            currentdiff = currentdiff + mobdiff
        end
    end
end

function split(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

local function add_joules(p_name, amount)
    -- Check if player is premium first
    tribyu_api.user.get_profile(p_name, function(data)
        local is_premium
        if data and data.premium then -- API call success
            is_premium = data.premium.active
        else -- API call failed with unknown reason (most likely server or network issues)
            is_premium = false
            core.log("error", "[!] [mob_survival] ("..amount..")-Joule reward for game completion to "..p_name.." [failure]: unknown failure while checking if player is premium! (network issue?). Adding non-premium joules amount")
        end

        -- Add the joules
        local add_amount
        if is_premium then
            add_amount = amount * 2
        else
            add_amount = amount
        end
        tribyu_api.user.add_joules(p_name, add_amount, function(data)
            if data and data.success then -- API call success 
                core.log("action", "[i] [mob_survival] ("..add_amount..")-Joule reward for game completion to "..p_name.." [success]")
            elseif data then -- API call returned failed status with known reason
              core.log("error", "[!] [mob_survival] ("..add_amount..")-Joule reward for game completion to "..p_name.." [failure]: " .. data.reason)
            else -- API call failed with unknown reason (most likely server or network issues)
              core.log("error", "[!] [mob_survival] ("..add_amount..")-Joule reward for game completion to "..p_name.." [failure]: unknown api call failure (network issue?)")
            end
          end)
    end)
end

arena_lib.on_end("mob_survival", function(arena, winners, is_forced)
    if is_forced then
        arena.shopkeeper:remove()
    end

    for i, mob in pairs(minetest.object_refs) do
        if mob:get_pos() then
            if vector.in_area(mob:get_pos(), arena.pos1, arena.pos2) then
                mob:remove()
            end
        end
    end

    for i, obj in minetest.objects_in_area(arena.pos1, arena.pos2) do
        obj:remove()
    end

    arena_lib.hard_reset_map("server", "mob_survival", arena.name)

    for pl_name, _ in pairs(arena.players_on_start) do
        local player = minetest.get_player_by_name(pl_name)

        local p_meta = player:get_meta()
        local joules_add = p_meta:get_int("joules_add")
        --Add joules
        for i=1,arena.diff do
            if mob_survival.joule_addition[i] then
                joules_add = joules_add + mob_survival.joule_addition[i]
            else
                joules_add = joules_add + mob_survival.joule_addition[#mob_survival.joule_addition]
            end
        end
        add_joules(pl_name, joules_add)

        --Calculate highscores
        minetest.after(1, function()
            if player then
                player:set_pos({x=10078,y=4.5,z=544})
                local highscore = mob_survival.check_record_and_set(waves_survived)
                if highscore then
                    if highscore == waves_survived then
                        minetest.chat_send_player(pl_name, "You have set a new highscore of "..highscore.."!")
                    else
                    minetest.chat_send_player(pl_name, "You have beaten your highscore of "..highscore..
                    "! Your new highscore is: "..waves_survived.."!")
                    end
                else
                    minetest.chat_send_player(pl_name, "You haven't beaten your highscore :(.")
                end
            end
        end)
        if player then
            local p_meta = player:get_meta()
            
            p_meta:set_int("gold", 0)
            local inv = player:get_inventory()
            for i, stack in pairs(inv:get_list("main")) do
                inv:remove_item("main", stack)
            end

            local waves_survived = p_meta:get_int("waves_survived")
            local highscore = mob_survival.check_record_and_set(pl_name, waves_survived)
        end
    end
end)