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

local shopkeeper
local random = math.random
local wave_cleared = false
local seconds
local diff = 1

mob_survival.moblist = {}

local mobnames = keyset(mob_survival.mobdiffs)

arena_lib.on_join("mob_survival", function(arena, p_name, as_spectator, was_spectator)
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
end)

local all_players

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
    all_players = table.copy(arena.players)
    total_players = #arena.players
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
    end
end)

arena_lib.on_start("mob_survival", function(arena)
    wave_clear()
    local pos = minetest.deserialize(storage:get_string("shopkeeper"))
    shopkeeper = minetest.add_entity(pos, "mob_survival:shopkeeper", arena.name)
    on_time_tick(arena)
end)

local function startswith(string, start)
    return string:sub(1, #start) == start
end

function on_time_tick(arena)
    for _, entity in pairs(minetest.luaentities) do
        if mob_survival.mobdiffs[entity.name] then
            local nametag = entity.object:get_nametag_attributes()
            if nametag then
                if nametag.text == "" then
                    -- Refresh entityref if mob is unloaded
                    for i, mob in pairs(mob_survival.moblist) do
                        if mob.moblist_id == entity.moblist_id then
                            mob_survival.moblist[i] = entity
                        end
                    end

                    print("nametag change for "..entity.name)
                    entity.object:set_nametag_attributes({
                        text = "V",
                        color = {a=255, r=255, g=0, b=0},
                        bgcolor = {a=0, r=0, g=0, b=0}
                    })
                end
            end
        end
    end

    for i, mob in pairs(mob_survival.moblist) do
        if mob.health <= 0 then
            table.remove(mob_survival.moblist, i)
        end
    end

    arena_lib.HUD_send_msg_all("broadcast", arena, "Mobs left: " .. tablelen(mob_survival.moblist))

    if not shopkeeper then
        shopkeeper = minetest.add_entity(pos, "mob_survival:shopkeeper", arena.name)
    end

    if tablelen(mob_survival.moblist) == 0 and not wave_cleared then
        wave_cleared = true
        diff = diff + 1
        seconds = 10
        for pl_name, _ in pairs(arena.players) do
            local player = minetest.get_player_by_name(pl_name)
            local p_meta = player:get_meta()

            p_meta:set_int("waves_survived", diff-1)

            local gold_player = p_meta:get_int("gold")

            if not gold_player then
                gold_player = 0
            end
            local increase
            if mob_survival.gold_addition[diff-1] ~= nil then
                gold_player = gold_player + mob_survival.gold_addition[diff-1]
                increase = mob_survival.gold_addition[diff-1]
            else
                gold_player = gold_player + mob_survival.gold_addition[#mob_survival.gold_addition]
                increase = mob_survival.gold_addition[#mob_survival.gold_addition]
            end
            p_meta:set_int("gold", gold_player)
            arena_lib.HUD_send_msg("hotbar", pl_name, "Wave cleared! You got "..increase.." gold for clearing this wave!", 5)
        end
    end

    if wave_cleared then
        arena_lib.HUD_send_msg_all("broadcast", arena, "Wave cleared! Wave "..diff.." starts in "..seconds.."!")
        seconds = seconds - 1
        if seconds == 0 then
            wave_clear()
            wave_cleared = false
        end
    end

    local restart_time_tick = true

    for pl_name, _ in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        local p_meta = player:get_meta()

        local players_eliminated = 0

        if p_meta:get_int("eliminated") == 1 then
            players_eliminated = players_eliminated + 1
            if players_eliminated == tablelen(arena.players) then
                arena_lib.force_end("Server", "mob_survival", arena)
                restart_time_tick = false
            end
        end
    end
    if tablelen(arena.players) == 0 then
        arena_lib.force_end("Server", "mob_survival", arena)
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
end)

--Handle eliminations
arena_lib.on_death("mob_survival", function(arena, p_name, reason)
    local player = minetest.get_player_by_name(p_name)
    local p_meta = player:get_meta()
  
    p_meta:set_int("eliminated", 1)

    arena_lib.remove_player_from_arena(p_name, 1, "mobs")

    if #arena.players > 0 then
        local spectate_player = minetest.get_player_by_name(arena.players[1])
        arena_lib.spectate_target("mob_survival", arena, p_name, spectate_player, spectate_player:get_player_name())
        check_for_respawn({player, diff_on_elim})
    end

    local diff_on_elim = diff
end)

function check_for_respawn(tabl)
    local p_name = player:get_player_name()
    local id
    local arena
    id, arena = arena_lib.get_arena_by_name("mob_survival", "sphinx")
    local player = tabl[1]
    local diff_on_elim = tabl[2]
    
    if diff ~= diff_on_elim then
        arena_lib.leave_spectate_mode(p_name)
        arena_lib.join_arena("mob_survival", p_name, id, false, true)
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
                check_for_respawn(arena, player, diff_on_elim)
            end, tabl)
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

        storage:set_string("shopkeeper", minetest.serialize(player:get_pos()))
            
        return true, "Spawn point for shopkeeper created!"
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

function wave_clear()
    local totaldiff = diff * mob_survival.total_mob_diff

    local currentdiff = 0
    local mobcount = 0

    while currentdiff ~= totaldiff do
        local mobID = random(1, tablelen(mobnames))
        local mobName = mobnames[mobID]
        local mobdiff = mob_survival.mobdiffs[mobName]

        local spawn_areas = minetest.deserialize(storage:get_string("spawn_areas"))

        local rand = random(1, #spawn_areas)
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
            mob = minetest.add_entity(pos, mobName, tostring(mobcount))
            mob:set_nametag_attributes({
                text = "V",
                color = {a=255, r=255, g=0, b=0},
                bgcolor = {a=0, r=0, g=0, b=0}
            })
            table.insert(mob_survival.moblist, mob:get_luaentity())
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

mob_survival.register_global_callback(function(mob_name, killer)
    local p_meta = killer:get_meta()
    if p_meta then
      local gold = p_meta:get_int("gold")
  
      if mob_survival.mob_kills_gold[mob_name] then
        local addition = mob_survival.mob_kills_gold[mob_name]
        p_meta:set_int("gold", gold+addition)
        local mob_human_name = split(mob_name, ":")[2]
        arena_lib.HUD_send_msg("hotbar", killer:get_player_name(), "You just got "..addition.." gold for killing a "..mob_human_name.."!", 2)
      end
    end
  end)

local total_players
local slots_available

arena_lib.on_end("mob_survival", function(arena, winners, is_forced)
    if is_forced then
        shopkeeper:remove()
    end
    minetest.clear_objects({mode = "quick"})
    diff = 1

    for i, mob in pairs(minetest.luaentities) do
        if startswith(mob.name, "mobs_mc:") then
            mob.object:remove(mob, false)
        end
    end
    mob_survival.moblist = {}

    for pl_name, _ in pairs(all_players) do
        local player = minetest.get_player_by_name(pl_name)
        if player then
            local p_meta = player:get_meta()
            
            p_meta:set_int("gold", 0)

            local waves_survived = p_meta:get_int("waves_survived")
            local highscore = mob_survival.check_record_and_set(pl_name, waves_survived)

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


            local text = "Everyone was eliminated, so the game ends! Would you like to play again?"
            
            local formspecstr = {
                "formspec_version[4]",
                "size[6,5]",
                "label[0.375,0.5;Game over!]",
                "hypertext[0.375,1.25;5.25,2;gameovertext;",core.formspec_escape(text),"]",
                "button_exit[0.25,3.5;3.5,1.1;back;Go back to lobby]",
                "button_exit[4,3.5;1.75,1.1;play;Play again!]"
            }

            local formspec = table.concat(formspecstr, "")

            core.show_formspec(pl_name, "mob_survival:play_again", formspec)
        end
    end

    total_players = 4
    slots_available = 0
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

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    for field, _ in pairs(fields) do
        if field == "play" then
            local id, arena = arena_lib.get_arena_by_name("mob_survival", "sphinx")
            arena_lib.join_queue("mob_survival", arena, name)
        end
		if field == "back" then
            slots_available = slots_available + 1
            --hop_player_to_lobby(name)
        end
    end

    if total_players then
        total_players = total_players - 1
    end

    if total_players == 0 then
        for i = 1, slots_available do
            if mob_survival.player_queue[1] then
                local id, arena = arena_lib.get_arena_by_name("mob_survival", "sphinx")
                arena_lib.join_queue("mob_survival", arena, mob_survival.player_queue[1])
                table.remove(mob_survival.player_queue, 1)
            end
        end
    end
end)