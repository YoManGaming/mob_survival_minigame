local function load_folder()
  local wrld_dir = minetest.get_worldpath() .. "/skins"
  local files = minetest.get_dir_list(wrld_dir, false)

  local modpath = minetest.get_modpath("collectible_skins")

  -- se la cartella delle skin non esiste/è vuota, copio la cartella base `skins`
  -- dentro quella del mondo
  if not next(files) then
    local src_dir = minetest.get_modpath("collectible_skins") .. "/IGNOREME"
    minetest.cpdir(src_dir, wrld_dir)
    os.remove(wrld_dir .. "/README.md")
  end

  --v------------------ LEGACY UPDATE, to remove in 2.0 -------------------v
  local i18n_dir = modpath .. "/locale/skins"

  for _, dir_name in ipairs(minetest.get_dir_list(modpath .. "/locale", true)) do
    if dir_name == "skins" then
      minetest.rmdir(i18n_dir, true)
    end
  end
  --^------------------ LEGACY UPDATE, to remove in 2.0 -------------------^

  -- carico quel che posso dalla cartella del mondo (non davvero media dinamici,
  -- dato che vengon eseguiti all'avvio del server)
  local function iterate_dirs(dir)
    for _, f_name in pairs(minetest.get_dir_list(dir, false)) do
      minetest.dynamic_add_media({filepath = dir .. "/" .. f_name}, function(name) end)
    end
    for _, subdir in pairs(minetest.get_dir_list(dir, true)) do
      iterate_dirs(dir .. "/" .. subdir)
    end
  end

  -- TEMP MT 5.9: per ora non si possono aggiungere contenuti dinamici all'avvio
  -- del server. Poi rimuovi anche 2° param da dynamic_add_media qui in alto
  minetest.after(0.1, function()
    iterate_dirs(wrld_dir .. "/locale")
    iterate_dirs(wrld_dir .. "/textures")
  end)


end



load_folder()

dofile(minetest.get_worldpath("collectible_skins") .. "/skins/SETTINGS.lua")
