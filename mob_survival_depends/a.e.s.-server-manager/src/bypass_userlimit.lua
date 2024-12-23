local exceptions = server_manager.users_who_can_bypass_userlimit

core.register_can_bypass_userlimit(function(name, ip)
  return table.indexof(exceptions, name) > 0
end)
