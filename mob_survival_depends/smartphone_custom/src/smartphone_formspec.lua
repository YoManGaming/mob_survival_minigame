--[[
Defines the formspec for the smartphone app.
The `smartphone.get_smartphone_formspec` function generates the formspec, which
includes the header, footer, and the list of installed apps. The formspec is
customized based on the player's privileges and the available apps.
--]]

smartphone_custom.fs_width = 8.5
smartphone_custom.fs_height = 16
smartphone_custom.content_y = 1.3
smartphone_custom.nav_bar_height = 1.15
smartphone_custom.content_height = smartphone_custom.fs_height - smartphone_custom.content_y - smartphone_custom.nav_bar_height

local fs_width = smartphone_custom.fs_width
local fs_height = smartphone_custom.fs_height

local app_width = 1.5
local app_height = 1.5
local apps_offset = 2.5

local back_width = 0.5
local back_height = 0.5
local back_x = 1.9
local back_y = back_width

local home_width = 0.5
local home_height = 0.5
local home_x = 4
local home_y = home_width


function smartphone_custom.get_header(def)
	def = def or {}

	local bg = "image[0,0;"..fs_width..","..fs_height..";phone_bg_img.jpg^[mask:phone_bg.png]"
	if def.bg_color then
		bg = "image[0,0;8.5,16;phone_bg.png^[fill:1291x2434:0,0:"..def.bg_color.."^[mask:phone_bg.png]"
	end

	return
		"formspec_version[6]" ..
		"size["..(fs_width+0.05)..","..fs_height..",true]"..
		"no_prepend[]"..
		"background[0,0;"..fs_width..","..fs_height..";phone_bg.png]"..
		"bgcolor[;neither]"..
		"style_type[image_button;border=false;font=bold]"..
		"image_button_exit[8.7,0.1;0.7,0.7;phone_close.png;quit;;true;false]"..
		bg
		--"image[0,0;"..fs_width..","..fs_height..";phone_bg_topicons.png]"..
		--"image[0,0;"..fs_width..","..fs_height..";phone_bar_bg.png^[opacity:110]]"..
		--"label[0.65,0.65;Satlantis]"
end


smartphone_custom.smartphone_footer = ""..
	"container[0,"..(smartphone_custom.content_height+smartphone_custom.nav_bar_height).."]" ..
	"image_button["..back_x..","..back_y..";"..back_width..","..back_height..";phone_back.png;smtphone_back;]" ..
	"image_button["..home_x..","..home_y..";"..home_width..","..home_height..";phone_home.png;smtphone_home;]" ..
	"container_end[]"..
	"image[0,0;"..fs_width..","..fs_height..";phone_bg_frame.png]"


function smartphone_custom.get_smartphone_formspec(player)
	local formspec = smartphone_custom.get_header() ..

	"container[1,1.6]"

	local x = 0
	local y = 0
	for i, app in ipairs(smartphone_custom.apps_ordered) do
		if not app.priv_to_visualize or minetest.get_player_privs(player:get_player_name())[app.priv_to_visualize] then
			local btn_name = "app_btn|"..app.technical_name
			formspec = formspec..
			"image_button["..x..","..y..";"..app_width ..","..app_height..";"..app.icon.."^[mask:phone_app_mask.png;"..btn_name..";]"..
			"hypertext["..x..","..(y + app_height)..";"..app_width..",0.8;pname_txt;<global size=14 halign=center valign=middle><b>" .. app.name .. "</b>]"

			x = x + apps_offset
			if x > fs_width - app_width then
				x = 0
				y = y + apps_offset
			end
		end
	end

	return formspec.."container_end[]"..smartphone_custom.smartphone_footer
end
