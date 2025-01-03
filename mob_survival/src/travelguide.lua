function mob_survival.open_travel_page(player) end

local travelguide = {
    initial_properties = {
        hp_max = 100,
        physical = true,
        collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
        visual = "mesh",
        mesh = "character.b3d",
        textures = {"character.png"},
        nametag = "Travel Guide"
    },
  
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
        mob_survival.open_travel_page(puncher)
        return true
    end,
    
    on_rightclick = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
        mob_survival.open_travel_page(puncher)
        return true
    end,
}
  
minetest.register_entity("mob_survival:travelguide", travelguide)

function mob_survival.open_travel_page(player)
    local text = "Where would you like to travel to?"
    local formspecstr = {
        "formspec_version[4]",
        "size[6,5]",
        "label[0.375,0.5;Traveling...]",
        "hypertext[0.375,1.25;5.25,2;gameovertext;",core.formspec_escape(text),"]",
        "button_exit[0.25,3.5;1.5,1.1;Lobby;Lobby]",
        "button_exit[2,3.5;1.75,1.1;Orbiter;Orbiters]",
        "button_exit[4,3.5;1.75,1.1;Overworld;Overworld]"
    }
    
    local formspec = table.concat(formspecstr, "")
end

local function hop_player(name, place)
    tribyu_api.msp.hop_player(name, place, function(success, data)
        if success then -- API call success 
            if data.success then -- Hop success
                core.log("action", "hop_player success")
            else -- Hop failed, check reason
                core.log("warning", "hop_player fail: " .. data.reason)
            end
        elseif data then -- API call returned failed status with known reason
            core.log("error", "hop_player fail: " .. data.reason)
        else -- API call failed with unknown reason (most likely server or network issues)
            core.log("error", "hop_player api call failure")
        end
    end)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pl_name = player:get_player_name()
    
    local inv = player:get_inventory()
    local p_meta = player:get_meta()

	for field, _ in pairs(fields) do
        if field == "Overworld" or field == "Orbiter" or field == "Lobby" then
            hop_player(pl_name, field)
        end
	end
	return false
end)