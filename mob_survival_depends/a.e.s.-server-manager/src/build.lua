local old_is_protected = core.is_protected

function core.is_protected(pos, name)
  if arena_lib.is_player_in_arena(name) or core.check_player_privs(name, {[server_manager.build_priv] = true}) then
    return old_is_protected(pos, name)
  else
    return true
  end
end

core.register_privilege(server_manager.build_priv, {
  description = "Can build",
  give_to_singleplayer = false,
  give_to_admin = true
})
