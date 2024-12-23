--[[
    {
        "player1": {
            roles = {"helper", "vip_diamond", "vip_gold", {"videomaker", <expiry_date>}}
            static_role = "helper",  -- where helper is the role's name
            equipped_role = "vip_diamond"
        },
        ...
    }

    SPACE CONSUMPTION:
        if the server had 100 new players each month for 5 years, and each one of them
        unlocked 4 roles (each role name being approx. 11 byte):
        100*12*5 * [(4+2)*11 + 29 + 10 + 8*4] = 0.822Mb
                       ^       ^    ^    ^ approx. numeric indexes size
                       ^       ^    ^ approx. player username size
                       ^       ^ string keys total size
                       ^ static and equipped roles
--]]
roles.pl_roles = server_manager.get_table("pl_roles")



function roles.update_db()
	-- serialize data and save it
	core.handle_async(function (pl_data)
		return core.serialize(pl_data)
	end,
	function(serialized_pl_data)
        server_manager.store_string("pl_roles", serialized_pl_data)
	end, roles.pl_roles)
end
