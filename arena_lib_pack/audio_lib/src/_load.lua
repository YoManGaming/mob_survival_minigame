local function load_world_folder()

  local wrld_dir = minetest.get_worldpath() .. "/hub"
  local content = minetest.get_dir_list(wrld_dir)

  -- se la cartella di audio_lib non esiste/è vuota, copio la cartella base `IGNOREME`
  if not next(content) then
    local src_dir = minetest.get_modpath("hub") .. "/IGNOREME"

    minetest.cpdir(src_dir, wrld_dir)
    os.remove(wrld_dir .. "/README.md")

    content = minetest.get_dir_list(wrld_dir)
  end
end

load_world_folder()

dofile(minetest.get_worldpath() .. "/audio_lib/SETTINGS.lua")
