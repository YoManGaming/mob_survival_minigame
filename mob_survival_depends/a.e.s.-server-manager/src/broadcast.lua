local DELAY = server_manager.broadcast_delay
local broadcast_index = 1
local messages = server_manager.broadcast_msgs


local function main()
  broadcast_index = broadcast_index +1

  if broadcast_index > #messages then
    broadcast_index = 1
  end

  core.chat_send_all(
    "\n"..server_manager.broadcasts_prefix.." "..
    core.colorize(server_manager.broadcast_msgs_color, messages[broadcast_index])
    .. "\n")
  core.after(DELAY, main)
end

core.after(DELAY, main)
