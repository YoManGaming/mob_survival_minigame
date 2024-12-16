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
local diff_on_elim = diff
local moblist = {}

local mobnames = keyset(mob_survival.mobdiffs)

arena_lib.on_load("mob_survival", function(arena)
    for pl_name, _ in pairs(arena.players) do
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
    local pos = {}
    pos.x = 2
	pos.y = 3
	pos.z = -34
    shopkeeper = minetest.add_entity(pos, "mob_survival:shopkeeper", arena.name)
    on_time_tick(arena)
end)

function on_time_tick(arena)
    arena_lib.HUD_send_msg_all("hotbar", arena, "Mobs left: " .. tablelen(moblist))
    for k,v in pairs(moblist) do
        if v.health <= 0 then
            table.remove(moblist, k)
        end
    end

    if not shopkeeper then
        shopkeeper = minetest.add_entity(pos, "mob_survival:shopkeeper", arena.name)
    end

    if tablelen(moblist) == 0 and not wave_cleared then
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
            minetest.chat_send_player(player:get_player_name(), "You got "..increase.." Gold for clearing this wave!")
        end
    end

    if wave_cleared then
        arena_lib.HUD_send_msg_all("hotbar", arena, "Wave cleared! Wave "..diff.." starts in "..seconds.."!")
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
        end)
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
end)

arena_lib.on_respawn("mob_survival", function(arena, p_name)
    local player = minetest.get_player_by_name(p_name)
    local p_meta = player:get_meta()
  
    if p_meta:get_int("eliminated") == 1 then
      player:set_pos(arena.spectator_jail)
    end
    
    diff_on_elim = diff
    
    check_for_respawn(arena, player)
end)

function check_for_respawn(arena, player)
    if diff ~= diff_on_elim then
        local pos = random(1, 4)
        player:set_pos(arena.spawn_points[pos].pos)
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
                check_for_respawn(arena, player)
            end)
        end
    end
end

function wave_clear()
    local totaldiff = diff * mob_survival.total_mob_diff

    local currentdiff = 0

    while currentdiff ~= totaldiff do
        local mobID = random(1, tablelen(mobnames))
        local mobName = mobnames[mobID]
        local mobdiff = mob_survival.mobdiffs[mobName]

        local rand = random(1, 3)
        local pos = {}
        if rand == 1 then
            pos.x = random(-42, 18)
            pos.y = 10
            pos.z = random(-85, -49)
        elseif rand == 2 then
            pos.x = random(42, 35)
            pos.y = 18
            pos.z = random(-71, 20)
        else
            pos.x = random(27, 0)
            pos.y = 8
            pos.z = random(7, -20)
        end

        if (currentdiff+mobdiff) <= totaldiff then
            local def = mcl_mobs.spawn(pos, mobName)
            local obj = def:get_luaentity()
            table.insert(moblist, obj)
            currentdiff = currentdiff + mobdiff

            def:set_nametag_attributes({
                text = "V",
                color = {a=255, r=255, g=0, b=0},
                bgcolor = {a=0, r=0, g=0, b=0}
            })
        end
    end
end

arena_lib.on_end("mob_survival", function(arena, winners, is_forced)
    if is_forced then
        shopkeeper:remove()
    end
    minetest.clear_objects({mode = "quick"})
    diff = 1

    for i, mob in pairs(moblist) do
        mobs:remove(mob, false)
    end
    moblist = {}

    for pl_name, _ in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        local p_meta = player:get_meta()

        for pl_name, _ in pairs(arena.players) do
            p_meta:set_int("gold", 0)
        end

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
    end
end)