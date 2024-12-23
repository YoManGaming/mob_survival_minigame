for name, def in pairs(server_manager.custom_privs) do
	core.register_privilege(name, def)
end