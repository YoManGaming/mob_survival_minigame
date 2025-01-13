local S = minetest.get_translator("collectible_skins")
local function FS(...) return minetest.formspec_escape(S(...)) end

local function get_formspec() end
local function get_skins() end
local function get_collections() end

local COLL_LIST = "coll_" .. table.concat(collectible_skins.get_sorted_collections(), ",coll_") -- per lo stile dei pulsanti
local COLL_LIST_HOV = "coll_" .. table.concat(collectible_skins.get_sorted_collections(), ":hovered,coll_") .. ":hovered"
local BAR_MAX_SIZE = 9.3

local p_data = {}                          -- KEY: p_name; VAL: {name = skin_name, coll = coll_name, scrollbar_pos = 0}
local completed_colls = {}                 -- KEY: p_name; VAL: c_names_as_fs_string



function collectible_skins.show_skins_GUI(p_name)
  local player = minetest.get_player_by_name(p_name)

  if not player then return end

  local p_skin = collectible_skins.get_player_skin(p_name, true)
  local skin_name = p_skin.technical_name
  local model = p_skin.model
  local compl_colls = {}

  completed_colls[p_name] = ""

  for _, coll_name in pairs(collectible_skins.get_sorted_collections()) do
    local filter = {collection = coll_name, model = model}
    if #collectible_skins.get_player_skins(p_name, filter) == collectible_skins.get_skins_amount(filter) then
      table.insert(compl_colls, coll_name)
    end
  end

  completed_colls[p_name] = "coll_" .. table.concat(compl_colls, ",coll_")

  p_data[p_name] = {skin = skin_name, coll = p_skin.collection, scrollbar_pos = 0}
  minetest.show_formspec(p_name, "collectible_skins:GUI", get_formspec(p_name, skin_name))
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function get_formspec(p_name, skin_name)
  local is_unlocked = collectible_skins.has_skin(p_name, skin_name)
  local skin = collectible_skins.get_skin(skin_name)
  local model = skin.model
  local coll_name = skin.collection
  local skins, curr_id = get_skins(p_name, skin_name, model, coll_name)
  local collections = get_collections(p_name, model)
  local collection = collectible_skins.get_collection(coll_name)
  local p_coll_amount = #collectible_skins.get_player_skins(p_name, {collection = coll_name, model = model})
  local coll_amount = #collectible_skins.get_sorted_skins(coll_name, {model = model})
  local bar_percentage = BAR_MAX_SIZE * p_coll_amount/coll_amount
  local whitespace = curr_id < 10 and "  " or "   " -- per centrare il testo

  local coll_btn, coll_btn_hov, bar_col

  if p_coll_amount == coll_amount then
    coll_btn = "cskins_gui_coll_button_100_sel.png"
    coll_btn_hov = "cskins_gui_coll_button_100_sel_hov.png"
    bar_col = "#71aa34ff"
  else
    coll_btn = "cskins_gui_coll_button_sel.png"
    coll_btn_hov = "cskins_gui_coll_button_sel_hov.png"
    bar_col = "#31a2c3ff"
  end

  local formspec = {
    "formspec_version[4]",
    "size[17,10,true]",
    "no_prepend[]",
    "bgcolor[;neither]",
    "style_type[image_button;border=false;font=bold]",
    "style[go_left,go_right;sound=cskins_click3]",
    "style[close;sound=cskins_click]",
    "style[" .. COLL_LIST .. ";textcolor=#f4cca1;fgimg=cskins_gui_coll_button.png;sound=cskins_click]",
    "style[" .. COLL_LIST_HOV .. ";fgimg=cskins_gui_coll_button_hov.png]",
    "style[" .. completed_colls[p_name] .. ";textcolor=#b6d53c]",
    "style[coll_" .. coll_name .. ";textcolor=#ffffff;fgimg=" .. coll_btn .. "]",
    "style[coll_" .. coll_name .. ":hovered;fgimg=" .. coll_btn_hov .. "]",
    "background[0,0;17,10;cskins_gui_bg.png]",
    "image[0.45,0.69;4.68,3.82;" .. (collection.image or "blank.png") .. "]",
    "image[5.58,0.9;11.13,7.63;" .. (collection.background or "blank.png") .. "]",
    "container[0.5,5]",
    collections,
    "container_end[]",
    "container[5.55,0.9]",
    "box[0,0;11.2,1.65;#000000]",
    "hypertext[0,0;11.2,0.8;pname_txt;<global size=24 halign=center valign=bottom>" .. whitespace .. "<b>" .. FS(is_unlocked and skin.name or "???") .. "</b> <style color=#a0938e size=18>#" .. curr_id .. "]",
    "hypertext[0,0.85;11.2,0.8;pname_txt;<global size=15 halign=center valign=top><i>" .. FS(is_unlocked and skin.description or skin.hint) .. "</i>]",
    "container[0,2.4]",
    "image_button[0.2,1.6;0.45,0.8;cskins_gui_arrow_left.png;go_left;]",
    "image_button[10.5,1.6;0.45,0.8;cskins_gui_arrow_right.png;go_right;]",
    skins,
    "image_button[4.3,3.8;2.65,0.9;cskins_gui_wear.png;equip;" .. S("Wear") .. "]",
    "container[0.02,5.56]",
    "box[0.27,0;" .. bar_percentage .. ",0.24;" .. bar_col .. "]",
    "container_end[]",
    "hypertext[9.88,5.52;1.25,0.4;pname_txt;<global size=13 halign=center valign=middle color=#cfc6b8><b>" .. p_coll_amount .. "/" .. coll_amount .. "</b>]",
    "container_end[]",
    "container_end[]",
    "image_button[17.15,0.57;0.6,0.6;cskins_gui_close.png;close;;true;false;]"
  }

  return table.concat(formspec, "")
end



function get_skins(p_name, skin_name, skin_model, coll_name)
  local skins = collectible_skins.get_sorted_skins(coll_name, {model = skin_model})
  local amnt = #skins

  local needed_skins = {}
  local overlay = {}
  local model = ""
  local curr_id

  if amnt > 1 then
    for id, sk_name in pairs(skins) do
      if sk_name == skin_name then
        needed_skins[1] = id - 2 > 0 and skins[id-2] or (id -1 > 0 and skins[amnt] or skins[amnt-1])
        needed_skins[2] = id - 1 > 0 and skins[id-1] or skins[amnt]
        needed_skins[3] = sk_name
        needed_skins[4] = id + 1 <= amnt and skins[id+1] or skins[1]
        needed_skins[5] = id + 2 <= amnt and skins[id+2] or (id + 1 <= amnt and skins[1] or skins[2])

        overlay[1] = collectible_skins.has_skin(p_name, needed_skins[1]) and "^[multiply:#888888" or "^[multiply:#000000"
        overlay[2] = collectible_skins.has_skin(p_name, needed_skins[2]) and "^[multiply:#bbbbbb" or "^[multiply:#000000"
        overlay[3] = collectible_skins.has_skin(p_name, needed_skins[3]) and "^[contrast:25:13" or "^[multiply:#000000"
        overlay[4] = collectible_skins.has_skin(p_name, needed_skins[4]) and "^[multiply:#bbbbbb" or "^[multiply:#000000"
        overlay[5] = collectible_skins.has_skin(p_name, needed_skins[5]) and "^[multiply:#888888" or "^[multiply:#000000"

        -- converto in tabella
        for i = 1, #needed_skins do
          needed_skins[i] = collectible_skins.get_skin(needed_skins[i])
        end

        model = needed_skins[1].model -- non è possibile vedere modelli diversi contemporaneamente, ergo son tutti uguali
        curr_id = id
        break
      end
    end

  else
    local is_unlocked = collectible_skins.has_skin(p_name, skin_name)
    local skin = collectible_skins.get_skin(skin_name)
    local overlay_unsel_far, overlay_unsel, overlay_sel

    if is_unlocked then
      overlay_unsel_far = "^[multiply:#888888"
      overlay_unsel = "^[multiply:#bbbbbb"
      overlay_sel = "^[contrast:25:13"
    else
      overlay_unsel_far = "^[multiply:#000000"
      overlay_unsel = "^[multiply:#000000"
      overlay_sel = "^[multiply:#000000"
    end

    needed_skins = {skin, skin, skin, skin, skin}
    overlay = {overlay_unsel_far, overlay_unsel, overlay_sel, overlay_unsel, overlay_unsel_far}
    model = skin.model
    curr_id = 1
  end

  local formspec = {
    "model[0.9,1.05;1.8,1.8;chara;" ..  model .. ";" .. needed_skins[1].texture .. overlay[1] .. ";0,-160;false;true]",
    "model[2,0.8;3,2.3;chara;" ..   model .. ";" .. needed_skins[2].texture .. overlay[2] .. ";0,-160;false;true]",
    "model[6.2,0.8;3,2.3;chara;" .. model .. ";" .. needed_skins[4].texture .. overlay[4] .. ";0,160;false;true]",
    "model[8.45,1.05;1.8,1.8;chara;" .. model .. ";" .. needed_skins[5].texture .. overlay[5] .. ";0,160;false;true]",
    "image[1.45,0.65;0.7,0.11;cskins_gui_stars"  .. needed_skins[1].tier .. ".png" .. overlay[1] .. "]",
    "image[3.05,0.5;0.9,0.13;cskins_gui_stars"  .. needed_skins[2].tier .. ".png" .. overlay[2] .. "]",
    "image[7.25,0.5;0.9,0.13;cskins_gui_stars"  .. needed_skins[4].tier .. ".png" .. overlay[4] .. "]",
    "image[9,0.65;0.7,0.11;cskins_gui_stars"     .. needed_skins[5].tier .. ".png" .. overlay[5] .. "]",
    "model[0.8,0;9.6,3.5;chara;" .. model .. ";" .. needed_skins[3].texture .. overlay[3] .. ";0,180;false;true]",
    "image[5.1,-0.45;1,0.16;cskins_gui_stars"   .. needed_skins[3].tier .. ".png" .. overlay[3] .. "]"
  }

  return table.concat(formspec, ""), curr_id
end



function get_collections(p_name, model)
  local collections = collectible_skins.get_sorted_collections()
  local coll_y = 0
  local coll_table = {}
  local coll_amount = #collections
  local empty_colls = 0

  for _, coll_name in ipairs(collections) do
    local skins_amount = collectible_skins.get_skins_amount({collection = coll_name, model = model})

    -- se è vuota, ignora
    if skins_amount == 0 then
      empty_colls = empty_colls - 1
    else
      local p_skins_amount = #collectible_skins.get_player_skins(p_name, {collection = coll_name, model = model})
      local section = "coll_" .. coll_name
      local name = collectible_skins.get_collection(coll_name).name

      coll_table[#coll_table +1] =  "image_button[0," .. coll_y .. ";4.58,0.85;;" .. section .. ";" .. name .. "]" ..
                                    "tooltip[" .. section .. ";" .. p_skins_amount .. "/" .. skins_amount .. ";#31a2c3;#ffffff]"
      coll_y = coll_y + 0.85
    end
  end

  coll_amount = coll_amount - empty_colls

  -- se ce ne son più di 5, metti barra scorrimento
  if coll_amount > 5 then
    local extra_coll = coll_amount - 5
    local max_val = extra_coll * 9
    local steps = math.ceil(max_val / 2)

    table.insert(coll_table, 1, "scroll_container[0,0;4.58,4.3;collections;vertical]")
    coll_table[#coll_table + 1] = "scroll_container_end[]" ..
                                  "scrollbaroptions[max=" .. max_val .. ";arrows=hide;thumbsize=3;smallstep=" .. steps .. "]" ..
                                  "scrollbar[4.4,0;0.18,4.3;vertical;collections;" .. p_data[p_name].scrollbar_pos .. "]"
  end

  return table.concat(coll_table, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "collectible_skins:GUI" then return end

  local p_name = player:get_player_name()

  if fields.close or fields.quit then
    p_data[p_name] = nil
    completed_colls[p_name] = nil
    minetest.close_formspec(p_name, "collectible_skins:GUI")
    return
  end

  local data = p_data[p_name]

  if fields.collections then
    data.scrollbar_pos = minetest.explode_scrollbar_event(fields.collections).value
  end

  if fields.equip then
    if collectible_skins.has_skin(p_name, data.skin) then
      collectible_skins.set_skin(player, data.skin, true)
      minetest.sound_play("cskins_confirm", {to_player = p_name})
      minetest.close_formspec(p_name, "collectible_skins:GUI")
    else
      minetest.sound_play("cskins_deny", {to_player = p_name})
    end
    return
  end

  if fields.go_left then
    local model = collectible_skins.get_player_skin(p_name).model
    local sorted_skins = collectible_skins.get_sorted_skins(data.coll, {model = model})
    local curr_skin_name = data.skin

    for id, sk_name in pairs(sorted_skins) do
      if curr_skin_name == sk_name then
        local prev_id = id -1 > 0 and id - 1 or #sorted_skins
        local prev_sk_name = sorted_skins[prev_id]

        data.skin = prev_sk_name
        minetest.show_formspec(p_name, "collectible_skins:GUI", get_formspec(p_name, prev_sk_name))
        return
      end
    end

  elseif fields.go_right then
    local model = collectible_skins.get_player_skin(p_name).model
    local sorted_skins = collectible_skins.get_sorted_skins(data.coll, {model = model})
    local curr_skin_name = data.skin

    for id, sk_name in pairs(sorted_skins) do
      if curr_skin_name == sk_name then
        local next_id = id +1 <= #sorted_skins and id + 1 or 1
        local next_sk_name = sorted_skins[next_id]

        data.skin = next_sk_name
        minetest.show_formspec(p_name, "collectible_skins:GUI", get_formspec(p_name, next_sk_name))
        return
      end
    end
  end

  -- pulsante collezioni
  for k, _ in pairs(fields) do
    local _, end_pos = string.find(k, "coll_")

    if end_pos then
      local coll_name = k:sub(end_pos +1)
      local model = collectible_skins.get_player_skin(p_name).model
      local first_skin = collectible_skins.get_sorted_skins(coll_name, {model = model})[1]

      p_data[p_name] = {skin = first_skin, coll = coll_name, scrollbar_pos = minetest.explode_scrollbar_event(fields.collections).value}
      minetest.show_formspec(p_name, "collectible_skins:GUI", get_formspec(p_name, first_skin))
    end
  end

end)