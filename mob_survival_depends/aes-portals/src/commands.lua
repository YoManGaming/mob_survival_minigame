local S = minetest.get_translator("aes_portals")

local cmd = chatcmdbuilder.register("portals", {
  params = "link | unlink <mod> <arena_name>\nlist <mod>",
  description = S("Portals management"),
  privs = { server = true }
})



cmd:sub("link :minigame :arena", function(sender, mod, arena_name)
  local id = arena_lib.get_arena_by_name(mod, arena_name)

  if not id then
    aes_portals.print_error(sender, S("Unknown minigame and/or arena!"))
    return end

  if aes_portals.get_linked_arenas(mod)[id] then
    aes_portals.print_error(sender, S("Arena @1 is already linked", arena_name))
    return end

  aes_portals.link(mod, id)
  aes_portals.print_info(sender, S("Arena @1 successfully linked", arena_name))
end)


cmd:sub("unlink :minigame :arena", function(sender, mod, arena_name)
  local id = arena_lib.get_arena_by_name(mod, arena_name)

  if not id then
    aes_portals.print_error(sender, S("Unknown minigame and/or arena!"))
    return end

  if not aes_portals.get_linked_arenas(mod)[id] then
    aes_portals.print_error(sender, S("Arena @1 is already unlinked", arena_name))
    return end

  aes_portals.unlink(mod, id)
  aes_portals.print_info(sender, S("Arena @1 successfully unlinked", arena_name))
end)

cmd:sub("list :minigame", function(sender, mod)
  local list = aes_portals.get_linked_arenas(mod)

  if not list then
    aes_portals.print_error(sender, S("This minigame doesn't exist!"))
    return end

  minetest.chat_send_player(sender, dump(list))
end)