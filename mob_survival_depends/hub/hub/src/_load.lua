local function load_world_folder()

  local wrld_dir = minetest.get_worldpath() .. "/hub"
  local content = minetest.get_dir_list(wrld_dir)

  -- se la cartella di hub non esiste/è vuota, copio la cartella base `IGNOREME`
  if not next(content) then
    local src_dir = minetest.get_modpath("hub") .. "/IGNOREME"

    minetest.cpdir(src_dir, wrld_dir)
    os.remove(wrld_dir .. "/README.md")
    os.remove(wrld_dir .. "/BGM/.gitkeep")

    content = minetest.get_dir_list(wrld_dir)

  else
    -- aggiungi musiche come contenuti dinamici per non appesantire il server
    local function iterate_dirs(dir)
      for _, f_name in pairs(minetest.get_dir_list(dir, false)) do
        -- NOT REALLY DYNAMIC MEDIA, since it's run when the server launches and there are no players online
        -- it's just to load these tracks from the world folder (so that `sound_play` recognises them without the full path)
        minetest.dynamic_add_media({filepath = dir .. "/" .. f_name})

      end
      for _, subdir in pairs(minetest.get_dir_list(dir, true)) do
        iterate_dirs(dir .. "/" .. subdir)
      end
    end

    iterate_dirs(wrld_dir .. "/BGM")
  end
end

load_world_folder()

-- SETTINGS.lua viene caricato dopo, quindi after
minetest.after(0, function()
  if next(hub.settings.music) then
    local bgm = hub.settings.music
    audio_lib.register_sound("bgm", bgm.track, bgm.description, bgm.params)
  end
end)



-- TODO: aggiornamento file SETTINGS una volta che la mod sarà rilasciata pubblicamente
