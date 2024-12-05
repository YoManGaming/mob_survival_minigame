local yaml = dofile(minetest.get_modpath("collectible_skins") .. "/libs/tinyyaml.lua")
local storage = minetest.get_mod_storage()
local S = minetest.get_translator("collectible_skins")

local function load_player_data() end
local function try_to_load_player() end
local function filter_checks_passed() end
local function migrate_old_skins() end


local players_skins = {}                        -- KEY: p_name; VALUE: {skin_names}
local loaded_skins = {}                         -- KEY: id; VALUE: {skin info}
local collections = {}                          -- KEY: coll_name; VALUE: {name, image, skins = {N = name}}
local ordered_coll = {}                         -- KEY: id; VALUE: coll_name
local equipped_skin = {}                        -- KEY: p_name; VALUE: skin_name
local default_skins = collectible_skins.SETTINGS.default_skins
local skins_to_migrate = collectible_skins.SETTINGS.migrate_skins



local function register_hand_from_texture(name, texture)
	local hand_name = "collectible_skins:hand_" .. name
	local hand_def = {}

  -- costruisco la definizione per una nuova mano prendendo le proprietà
  -- che non mi interessano e impostandole ai valori di base
	for key, value in pairs(minetest.registered_items[""]) do
		if key ~= "mod_origin" and key ~= "type" and key ~= "wield_image" then
			hand_def[key] = value
		end
	end

	hand_def.tiles = {texture}
	hand_def.visual_scale = 1
	hand_def.wield_scale = {x=4,y=4.5,z=4.5}
	hand_def.paramtype = "light"
	hand_def.drawtype = "mesh"

  hand_def.mesh = "cskins_hand.obj"

	hand_def.use_texture_alpha = "clip"
	minetest.register_node(hand_name, hand_def)
end



local function load_skins()
  local coll_weight_table = {} -- la uso per ordinare le collezioni
  local dir = minetest.get_worldpath() .. "/skins"
  local files = minetest.get_dir_list(dir, false)

  for _, f_name in pairs(files) do
    if f_name:sub(-4) == ".yml" or f_name:sub(-5) == ".yaml" then
      local file = io.open(dir .. "/" .. f_name, "r")
      local skins = yaml.parse(file:read("*all"))
      local coll_info = table.copy(skins._COLLECTION_INFO)

      assert(coll_info, "[SKINS_COLLECTIBLE] Missing mandatory field `_COLLECTION_INFO` in file `" .. f_name .. "`! Check out the DOCS")

      local coll_name = coll_info.technical_name

      assert(coll_name, "[SKINS_COLLECTIBLE] Missing mandatory field `technical_name` in _COLLECTION_INFO, file `" .. f_name .. "`!")
      assert(collections[coll_name] == nil, "[SKINS_COLLECTIBLE] There's already another collection having `" .. coll_name .. " as a technical name!")

      collections[coll_name] = {name = S(coll_info.name), background = coll_info.background, image = coll_info.image, skins = {}}
      coll_weight_table[#coll_weight_table + 1] = {weight = coll_info.weight or 0, name = coll_name}
      skins._COLLECTION_INFO = nil  -- evito che me lo consideri una skin

      local coll = collections[coll_name].skins
      local skins_order_id = {}
      local n = 1

      -- estraggo l'ordine
      if coll_info.order then
        coll_info.order:gsub("[%w_]+", function(val)
          skins_order_id[val] = n
          n = n + 1
        end)
      end

      -- se alcune skin non son state specificate nell'ordine, le metto alla fine
      for name, _ in pairs(skins) do
        if not skins_order_id[name] then
          skins_order_id[name] = n
          n = n + 1
        end
      end

      for name, skin in pairs(skins) do
        -- i doppioni li controllo direttamente dentro tinyyaml.lua (checkdupekey),
        -- che ho modificato appositamente
        assert(skin.name,               "[SKINS COLLECTIBLE] Skin `" .. name .. "` has no name!")
        assert(skin.description,        "[SKINS COLLECTIBLE] Skin `" .. name .. "` has no description!")
        assert(skin.texture,            "[SKINS COLLECTIBLE] Skin `" .. name .. "` has no texture!")

        coll[skins_order_id[name]] = name

        loaded_skins[name] = {
          technical_name  = name,         -- for cross-reference
          name            = skin.name,
          description     = skin.description,
          collection      = coll_info.technical_name,
          hint            = skin.hint or "(locked)",
          model           = skin.model or "character.b3d",
          texture         = skin.texture,
          tier            = skin.tier or 1
        }

        register_hand_from_texture(name, skin.texture)
      end

      file:close()
    end
  end

  table.sort(coll_weight_table, function(a,b) return a.weight < b.weight end)

  for k, v in pairs(coll_weight_table) do
    ordered_coll[k] = v.name
  end
end

load_skins()



----------------------------------------------
--------------INTERNAL USE ONLY---------------
----------------------------------------------

function collectible_skins.init_player(player)
  load_player_data(player)
end





----------------------------------------------
-------------------CORPO----------------------
----------------------------------------------

function collectible_skins.unlock_skin(p_name, skin_name)
  try_to_load_player(p_name)

  -- se la skin non esiste, annullo
  if not loaded_skins[skin_name] then
    collectible_skins.print_warning("There has been an attempt to give player " .. p_name .. " a skin that doesn't exist (`" .. skin_name .. "`)!")
    return end

  -- se lə giocante non si è mai connessə, annullo
  if storage:get_string(p_name) == "" then
    collectible_skins.print_warning("Can't unlock skin " .. skin_name .. " for player " .. p_name .. ", as they've never connected")
    return end

  -- se ce l'ha già, annullo
  if collectible_skins.has_skin(p_name, skin_name) then return end

  local p_skins

  -- se è online
  if minetest.get_player_by_name(p_name) then
    p_skins = players_skins[p_name]
    minetest.chat_send_player(p_name, S("You've unlocked the skin @1!", loaded_skins[skin_name].name))
  -- se è offline
  else
    p_skins = minetest.deserialize(storage:get_string(p_name))
  end

  p_skins[skin_name] = true
  storage:set_string(p_name, minetest.serialize(p_skins))

  return true
end



function collectible_skins.remove_skin(p_name, skin_name)
  try_to_load_player(p_name)

  -- se l'aspetto non esiste, annullo
  if not loaded_skins[skin_name] then
    collectible_skins.print_warning("There has been an attempt to remove player " .. p_name .. " a skin that doesn't exist (`" .. skin_name .. "`)!")
    return end

  -- se lə giocante non si è mai connessə, annullo
  if storage:get_string(p_name) == "" then
    collectible_skins.print_warning("Can't remove skin " .. skin_name .. " for player " .. p_name .. ", as they've never connected")
    return end

  -- se non ce l'ha, annullo
  if not collectible_skins.has_skin(p_name, skin_name) then return end

  local p_skins
  local player = minetest.get_player_by_name(p_name)

  -- se è online
  if player then
    p_skins = players_skins[p_name]
    minetest.chat_send_player(p_name, S("Your skin @1 has been removed...", loaded_skins[skin_name].name))

    -- se ce l'aveva addosso, ne metto uno casuale tra i predefiniti
    if equipped_skin[p_name] == skin_name then
      for _, sk_name in ipairs(default_skins) do
        if skin_name ~= sk_name and players_skins[p_name][sk_name] then
          minetest.chat_send_player(p_name, S("The skin you were wearing has been removed from you. A default skin has been put instead"))
          collectible_skins.set_skin(player, sk_name, true)
          break
        end
      end
    end

  -- se è offline
  else
    p_skins = minetest.deserialize(storage:get_string(p_name))
  end

  -- rimuovo
  p_skins[skin_name] = nil
  storage:set_string(p_name, minetest.serialize(p_skins))
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function collectible_skins.is_skin(skin_name)
  return loaded_skins[skin_name] ~= nil
end



function collectible_skins.has_skin(p_name, skin_name)
  try_to_load_player(p_name)
  local p_skins = players_skins[p_name]

  if p_skins and p_skins[skin_name] then return true
  else return false end
end



function collectible_skins.does_collection_exist(collection)
  return collections[collection] ~= nil
end



function collectible_skins.is_in_storage(p_name)
  return storage:get_string(p_name) ~= ""
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function collectible_skins.get_skins(filter)
  if not filter then
    return table.copy(loaded_skins)

  else
    local skins = {}

    for sk_name, sk_data in pairs(loaded_skins) do
      if filter_checks_passed(filter, sk_data) then
        skins[sk_name] = loaded_skins[sk_name]
      end
    end

    return table.copy(skins)
  end
end



function collectible_skins.get_collections()
  return table.copy(collections)
end



function collectible_skins.get_sorted_skins(coll_name, filter)
  if not collections[coll_name] then return end

  if not filter then
    return collections[coll_name].skins

  else
    local ret = {}

    for _, sk_name in ipairs(collections[coll_name].skins) do
      if filter_checks_passed(filter, loaded_skins[sk_name]) then
        ret[#ret + 1] = sk_name
      end
    end

    return ret
  end
end



function collectible_skins.get_sorted_collections()
  return ordered_coll
end



function collectible_skins.get_skins_amount(filter)
  local n = 0

  if not filter then
    for _, _ in pairs(loaded_skins) do
      n = n + 1
    end

  else
    for _, sk_data in pairs(loaded_skins) do
      if filter_checks_passed(filter, sk_data) then
        n = n + 1
      end
    end
  end

  return n
end



function collectible_skins.get_skin(skin_name)
  return table.copy(loaded_skins[skin_name])
end



function collectible_skins.get_collection(coll_name)
  if not collections[coll_name] then return end

  return table.copy(collections[coll_name])
end



function collectible_skins.get_player_skins(p_name, filter)
  try_to_load_player(p_name)
  if not players_skins[p_name] then return {} end

  local skins_table = {}

  if not filter then
    for name, _ in pairs(players_skins[p_name]) do
      if loaded_skins[name] then
        skins_table[#skins_table + 1] = name
      end
    end

  else
    for name, _ in pairs(players_skins[p_name]) do
      if loaded_skins[name] then
        if filter_checks_passed(filter, loaded_skins[name]) then
          skins_table[#skins_table + 1] = name
        end
      end
    end
  end

  return skins_table
end



function collectible_skins.get_player_skin(p_name, permanent_only)
  -- TEMP: serve https://github.com/minetest/minetest/pull/9177 per accedere ai
  -- metadati dellɜ giocanti offline e far sì che la funzione possa essere eseguita
  -- anche su di loro
  if not minetest.get_player_by_name(p_name) then return end

  if not permanent_only then
    return table.copy(loaded_skins[equipped_skin[p_name]])
  else
    local sk_name = minetest.get_player_by_name(p_name):get_meta():get_string("collectible_skins:skin")

    if loaded_skins[sk_name] then
      return table.copy(loaded_skins[sk_name])
    end
  end
end





----------------------------------------------
-----------------SETTERS----------------------
----------------------------------------------

-- at_login è un parametro interno che serve solo per evitare di lanciare il richiamo
-- on_set_skin anche quando si connettono
function collectible_skins.set_skin(player, skin_name, is_permanent, at_login)
  local p_name = player:get_player_name()

  if not minetest.get_player_by_name(p_name) then return end

  -- se la skin non è più in memoria, assegnane una casuale tra quelle predefinite
  if not loaded_skins[skin_name] then
    collectible_skins.print_warning("Attempt to equipping unknown skin " .. skin_name .. " to " .. p_name .. ". Equipping a default skin instead")
    skin_name = default_skins[math.random(#default_skins)]
    is_permanent = true
  end

  player_api.set_texture(player, 1, loaded_skins[skin_name].texture)

  equipped_skin[p_name] = skin_name
  player:get_inventory():set_size("hand", 1)
  player:get_inventory():set_stack("hand", 1, "collectible_skins:hand_" .. tostring(skin_name))

  if is_permanent then
    player:get_meta():set_string("collectible_skins:skin", skin_name)
  end

  if at_login then return end

  -- eventuali richiami
  for _, callback in ipairs(collectible_skins.registered_on_set_skin) do
    callback(player:get_player_name(), skin_name, at_login)
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function load_player_data(player)
  local p_name = player:get_player_name()

  -- se lə giocante entra per la prima volta o ha perso il metadato, lo inizializzo...
  -- il controllo del metadato è l'unico modo che ho trovato di sapere se qualcuno ha usato
  -- minetest.remove_player sullə giocante.
  if storage:get_string(p_name) == "" or not player:get_meta():contains("collectible_skins:skin") then
    players_skins[p_name] = {}

    -- migrazione vecchio sistema basato sugli id
    if player:get_meta():contains("collectible_skins:skin_ID") then
      local p_skins = minetest.deserialize(storage:get_string(p_name))

      -- se p_skins non esiste significa che hanno cancellato il mod storage, ma non i metadati degli utenti
      if p_skins then
        migrate_old_skins(player, p_name)
        return
      end

      player:get_meta():set_string("collectible_skins:skin_ID", "")
    end


    -- sblocco gli aspetti base
    for _, sk_name in pairs(default_skins) do
      players_skins[p_name][sk_name] = true
    end

    storage:set_string(p_name, minetest.serialize(players_skins[p_name]))

    -- ...e ne assegno uno casuale
    local random_ID = math.random(#default_skins)
    collectible_skins.set_skin(player, default_skins[random_ID], true, true)

  --sennò assegno l'aspetto che aveva
  else
    local skin_name = player:get_meta():get_string("collectible_skins:skin")

    -- potrebbe già esser stato caricato da try_to_load_player, risparmio un'eventuale deserializzazione
    if not players_skins[p_name] then
      players_skins[p_name] = minetest.deserialize(storage:get_string(p_name))
    end

    local p_skins = players_skins[p_name]

    -- se è stato aggiunto qualche aspetto base dall'ultima volta, sbloccalo
    for _, sk_name in pairs(default_skins) do
      if not p_skins[sk_name] then
        p_skins[sk_name] = true
      end
    end

    -- se l'aspetto che aveva lə è stato rimosso, ne metto uno casuale tra i predefiniti
    if not p_skins[skin_name] then
      for _, sk_name in ipairs(default_skins) do
        if p_skins[sk_name] then
          skin_name = sk_name
          minetest.chat_send_player(p_name, S("The skin you were wearing has been removed from you. A default skin has been put instead"))
          break
        end
      end
    end

    collectible_skins.set_skin(player, skin_name, false, true)
  end
end



function try_to_load_player(p_name)
  if players_skins[p_name] then return end

  local skins = storage:get_string(p_name)

  if skins then
    players_skins[p_name] = minetest.deserialize(skins)
  end
end



function filter_checks_passed(filter, sk_data)
  if filter.collection and sk_data.collection ~= filter.collection then
    return false
  end
  if filter.tier and sk_data.tier ~= filter.tier then
    return false
  end
  if filter.model and sk_data.model ~= filter.model then
    return false
  end

  return true
end



-- TEMP: I cannot remove this function, as it's not possible to access nor change
-- metadata of offline players (https://github.com/minetest/minetest/pull/9177).
-- This means that a server which used this mod in its alpha state (i.e. A.E.S.)
-- can't convert skins as it can't touch offline players' metadata - it can only
-- perform storage conversion
function migrate_old_skins(player, p_name)
  assert(skins_to_migrate ~= nil, "[COLLECTIBLE_SKINS] You need to migrate your skins using the new nomenclature system instead of IDs!"
          .. "Check out the DOCS to learn about the new structure and use the setting `migrate_skins` to migrate "
          .. "(it's probably only in the IGNOREME folder of the mod, just copy it)")

  local curr_skin_id = player:get_meta():get_int("collectible_skins:skin_ID")
  local p_skins = minetest.deserialize(storage:get_string(p_name))

  for id, name in pairs(skins_to_migrate) do
    if p_skins[id] then
      players_skins[p_name][name] = true

      if id == curr_skin_id then
        collectible_skins.set_skin(player, name, true, true)
      end
    end
  end

  storage:set_string(p_name, minetest.serialize(players_skins[p_name]))
  player:get_meta():set_string("collectible_skins:skin_ID", "")
end
