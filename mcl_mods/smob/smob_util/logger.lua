
function satlantis.log(type, tag, msg)
    minetest.debug("[STL."..type..":"..tag.. "] "..msg)
end

function satlantis.critical(tag, msg)
    satlantis.log("Critical", tag, msg)
end

function satlantis.error(tag, msg)
    satlantis.log("Error", tag, msg)
end

function satlantis.warning(tag, msg)
    satlantis.log("Warning", tag, msg)
end

function satlantis.debug(tag, msg)
    satlantis.log("Debug", tag, msg)
end

function satlantis.debug(msg)
    satlantis.log("Debug", "-", msg)
end