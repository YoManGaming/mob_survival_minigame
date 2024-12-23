local storage = core.get_mod_storage()


function server_manager.store_table(key, table)
	storage:set_string(key, core.serialize(table))
end


function server_manager.store_string(key, string)
	storage:set_string(key, string)
end


function server_manager.get_table(key)
	return core.deserialize(storage:get_string(key), true) or {}
end


function server_manager.get_string(key)
	return storage:get_string(key)
end