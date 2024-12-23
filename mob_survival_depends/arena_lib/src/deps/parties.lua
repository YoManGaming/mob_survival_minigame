if not minetest.get_modpath("parties") then return end

local S = minetest.get_translator("arena_lib")





parties.register_on_pre_party_invite(function(sender, p_name)
  -- se il capogruppo è in coda
  if arena_lib.is_player_in_queue(sender) then
    arena_lib.print_error(sender, S("You can't perform this action while in queue!"))
    return false end

  -- se il capogruppo è in gioco
  if arena_lib.is_player_in_arena(sender) then
    arena_lib.print_error(sender, S("You can't perform this action while in game!"))
    return false end

  return true
end)



parties.register_on_pre_party_join(function(party_leader, p_name)
  -- se il capogruppo è in coda
  if arena_lib.is_player_in_queue(party_leader) then
    arena_lib.print_error(p_name, S("The party leader must not be in queue to perform this action!"))
    return false end

  -- se il capogruppo è in gioco
  if arena_lib.is_player_in_arena(party_leader) then
    arena_lib.print_error(p_name, S("The party leader must not be in game to perform this action!"))
    return false end

  local arena = arena_lib.get_arena_by_player(p_name)

  if not arena then return true end

  -- se l'invitato è in coda, lo rimuovo
  if arena_lib.is_player_in_queue(p_name) then
    arena_lib.remove_player_from_queue(p_name)
  end

  return true
end)



function arena_lib.get_party_members_playing(p_name, arena)
  local pt_members = {}

  if not arena then
    for _, pl_name in ipairs(parties.get_party_members(p_name, true)) do
      if arena_lib.is_player_playing(p_name) then
        pt_members[#pt_members +1] = pl_name
      end
    end

  else
    for _, pl_name in ipairs(parties.get_party_members(p_name, true)) do
      if arena.players[pl_name] then
        pt_members[#pt_members +1] = pl_name
      end
    end
  end

  return pt_members
end



function arena_lib.get_party_members_spectating(p_name, arena)
  local pt_members = {}

  if not arena then
    for _, pl_name in ipairs(parties.get_party_members(p_name, true)) do
      if arena_lib.is_player_spectating(p_name) then
        pt_members[#pt_members +1] = pl_name
      end
    end

  else
    for _, pl_name in ipairs(parties.get_party_members(p_name, true)) do
      if arena.spectators[pl_name] then
        pt_members[#pt_members +1] = pl_name
      end
    end
  end

  return pt_members
end