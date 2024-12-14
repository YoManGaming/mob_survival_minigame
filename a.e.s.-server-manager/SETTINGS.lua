local S = core.get_translator("server_manager")   -- to translate strings



--== CHAT ==--

server_manager.blocked_cmds = {
	me = true
}

server_manager.blocked_cmds_when_muted = {
	me = true, msg = true, whisper = true, r = true, w = true, tell = true, message = true
}

-- caps prevention
server_manager.min_infringements_number_to_mute_for_caps = 3

-- flood prevention
server_manager.min_infringements_number_to_mute_for_flood = 3
server_manager.min_delay_between_messages = 1.5  -- in seconds,

-- chat filter
server_manager.min_infringements_number_to_mute_for_swearing = 3

-- After the min amount of infringements, every time they'll misbehave,
-- they'll be muted by the next duration in the list (in minutes)
server_manager.punishment_mute_durations = {1, 5, 10, 30, 60, 120, 300, 600}



--== BROADCASTING ==--

server_manager.broadcasts_prefix = "[Server]"
server_manager.broadcast_msgs_color = "#eea160"
server_manager.broadcast_delay = 600  -- in seconds

-- these messages will be displayed in the chat every broadcast_delay seconds
server_manager.broadcast_msgs = {
	S("Do you see someone breaking the rules? Report them using /report!"),
}



--== OTHER ==--

-- not given by default, if you want to change it edit the "default" role
server_manager.build_priv = "build"

server_manager.default_shadow_intensity = 0.2 -- 0.0 to 1.0
server_manager.default_bloom_intensity = 0 -- 0.0 to 1.0

server_manager.time_after_player_gets_afk = 120  -- in seconds

server_manager.max_reports_per_hour = 3  -- per player, so that they can't spam reports

server_manager.users_who_can_bypass_userlimit = {
	"YoManGaming101",
	"banana",
	"Duhneeno",
}

-- custom privs that will be registered when the server starts
server_manager.custom_privs = {
	aes_event = {},

	-- your_priv_name = {
	-- 	description = "something...",
	--		give_to_singleplayer = true/false (true by default),
	--		give_to_admin = true/false (true by default),
	-- }
}
