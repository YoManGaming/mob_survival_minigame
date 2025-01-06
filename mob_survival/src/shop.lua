storage = minetest.get_mod_storage()

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

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

function string.endswith(string, ending)
    return ending == "" or string:sub(-#ending) == ending
end

local function open_shop_page(page)
    local formspec = ""
    local i = 0

    for itemname, price in pairs(mob_survival.shop_items) do
        local item = minetest.registered_tools[itemname]
        if not item then
            item = minetest.registered_craftitems[itemname]
        end
        local image = item.inventory_image

        local t = split(item.description, "\n")

        local item_desc = ""
        for index, record in pairs(t) do
            if index ~= 1 then
                local record_t = split(record, ")")
                if index == #t then
                    record_t = split(record, "@")[1]
                else
                    record_t = record_t[#record_t]
                end
                item_desc = item_desc..record_t.."\n"
            end
        end
        local title_raw = split(t[1], ")")
        local item_title = title_raw[#title_raw]

        local box = "box[0,0;8.5,5;#00000055]" or ""

        local icon = "image[0,0.32;1.8,1.8;"..image.."]"

        local name
        if minetest.registered_tools[itemname] then
            if split(itemname, ":")[1] == "3d_armor" then
                local armor = split(itemname, "_")
                local material = armor[#armor]
                name = "hypertext[2,0.1;5.3,2;pname_txt;<style color=#00FF00 font=normal size=20>"..material.." Armor Set</style>]"
            else
                name = "hypertext[2,0.1;5.3,2;pname_txt;<style color=#00FF00 font=normal size=20>"..item_title.."</style>]"
            end
        else
            if split(itemname, ":")[1] == "rangedweapons" and itemname ~= "rangedweapons:40mm" and itemname ~= "rangedweapons:rocket" then
                name = "hypertext[2,0.1;5.3,2;pname_txt;<style color=#00FF00 font=normal size=20>30x "..item_title.."</style>]"
            elseif itemname ~= "rangedweapons:40mm" and itemname ~= "rangedweapons:rocket" then
                name = "hypertext[2,0.1;5.3,2;pname_txt;<style color=#00FF00 font=normal size=20>12x "..item_title.."</style>]"
            else
                name = "hypertext[2,0.1;5.3,2;pname_txt;<style color=#00FF00 font=normal size=20>6x "..item_title.."</style>]"
            end      
        end

		local desc = "hypertext[2,0.85;3.2,6.5;pname_txt;<style color=#FFFFFF font=normal size=14>"..item_desc.."</style>]"
		local gold_icon = "image[6.75,1.6;0.6,0.6;gold.png]"
		local cost = ("hypertext[4.25,1.75;3.4,0.4;pname_txt;<global size=14 halign=center><b>Cost: %s</b>]"):format(price)
        local buy_button = ("image_button[5.5,3;1.5,1.2;phone_button_yellow.png;buy_"..itemname.."_btn;Buy!]")

        local padding = i * 5

        local statement_guns = page == "guns" and split(itemname, ":")[1] == "rangedweapons" and not minetest.registered_craftitems[itemname]
        local statement_ammo = page == "ammo" and minetest.registered_craftitems[itemname] and split(itemname, ":")[1] == "rangedweapons"
        local statement_armor = page == "armor" and split(itemname, ":")[1] == "3d_armor"

        if statement_guns or statement_ammo or statement_armor then
            formspec = formspec..
            "container[0," .. padding.. "]" ..
            box ..
            icon .. name .. desc .. cost .. gold_icon .. buy_button .. [[
            container_end[]
            ]]

            i = i + 1
        elseif page == "misc" and split(itemname, ":")[1] ~= "rangedweapons" and split(itemname, ":")[1] ~= "3d_armor" then
            formspec = formspec..
            "container[0," .. padding.. "]" ..
            box ..
            icon .. name .. desc .. cost .. gold_icon .. buy_button .. [[
            container_end[]
            ]]

            i = i + 1
        end
    end

    return formspec
end

function mob_survival.open_shop(player, page)
    local p_meta = player:get_meta()
    if not p_meta then return end
    local gold_player = p_meta:get_int("gold")

    if not gold_player then
        gold_player = 0
    end

    local formspec = smartphone_custom.get_header()
    formspec = formspec.."scrollbaroptions[]"

    if page == "guns" then
        formspec = formspec.."image_button[0.25,0.5;2,1.2;phone_button_yellow.png;goto_guns_btn;Guns]"
    else
        formspec = formspec.."image_button[0.25,0.5;2,1.2;phone_button_blue.png;goto_guns_btn;Guns]"
    end
    if page == "ammo" then
        formspec = formspec.."image_button[2.25,0.5;2,1.2;phone_button_yellow.png;goto_ammo_btn;Ammo]"
    else
        formspec = formspec.."image_button[2.25,0.5;2,1.2;phone_button_blue.png;goto_ammo_btn;Ammo]"
    end
    if page == "armor" then
        formspec = formspec.."image_button[4.25,0.5;2,1.2;phone_button_yellow.png;goto_armor_btn;Armor]"
    else
        formspec = formspec.."image_button[4.25,0.5;2,1.2;phone_button_blue.png;goto_armor_btn;Armor]"
    end
    if page == "misc" then
        formspec = formspec.."image_button[6.25,0.5;2,1.2;phone_button_yellow.png;goto_misc_btn;Food]"
    else
        formspec = formspec.."image_button[6.25,0.5;2,1.2;phone_button_blue.png;goto_misc_btn;Food]"
    end

    formspec = formspec.."hypertext[4.25,2;3.4,0.4;pname_txt;<global size=14 halign=center><b>Balance:"..gold_player.."</b>]"..
    "image[7,2;0.6,0.6;gold.png]"..
    "scrollbar[0,2;0,0;vertical;itemscrollbar;]"..
    "scroll_container[0,3;8,16;itemscrollbar;vertical]"
    ..open_shop_page(page)
    .."scroll_container_end[]"

    minetest.show_formspec(player:get_player_name(), "mob_survival:shop", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pl_name = player:get_player_name()
    
    local inv = player:get_inventory()
    local p_meta = player:get_meta()

	for field, _ in pairs(fields) do
        if string.starts(field, "goto_") then
            local str
			str = field:gsub("goto_", "")
			str = str:gsub("_btn", "")
            mob_survival.open_shop(player, str)
        end
		if string.starts(field, "buy_") then
			local str
			str = field:gsub("buy_", "")
			str = str:gsub("_btn", "")

			local name = str

			local gold_player = p_meta:get_int("gold")
            if not gold_player then
                gold_player = 0
            end

            local price = mob_survival.shop_items[name]
            if gold_player >= price then
                if minetest.registered_tools[name] then
                    if split(name, ":")[1] == "3d_armor" then
                        local temparmor = split(name, "_")
                        local material = temparmor[#temparmor]
                        armor:remove_all(player)
                        armor:equip(player, ItemStack("3d_armor:helmet_"..material))
                        armor:equip(player, ItemStack("3d_armor:chestplate_"..material))
                        armor:equip(player, ItemStack("3d_armor:leggings_"..material))
                        armor:equip(player, ItemStack("3d_armor:boots_"..material))
                        mob_survival.open_shop(player, "armor")
                    else
                        inv:add_item("main", name)
                        mob_survival.open_shop(player, "guns")
                    end
                else
                    if split(name, ":")[1] == "rangedweapons" and name ~= "rangedweapons:40mm" and name ~= "rangedweapons:rocket" then
                        inv:add_item("main", name.." 30")
                        mob_survival.open_shop(player, "ammo")
                    elseif name ~= "rangedweapons:40mm" and name ~= "rangedweapons:rocket" then
                        inv:add_item("main", name.." 12")
                        mob_survival.open_shop(player, "misc")
                    else
                        inv:add_item("main", name.." 6")
                        mob_survival.open_shop(player, "ammo")
                    end
                end
                gold_player = gold_player - price
                p_meta:set_int("gold", gold_player)
            else
                minetest.chat_send_player(pl_name, "You do not have enough gold to purchase this item!")
                return
            end
        end
	end
	return false
end)