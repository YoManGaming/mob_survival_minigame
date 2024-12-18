local formspec = {}

formspec.colors = {
    black = "#000000",
    white = "#FFFFFF"
}

function formspec.container(x, y)
    return {
        x = x,
        y = y,
    
        fs = ([=[container[%f,%f]\n]=]):format(o.x, o.y),

        text = function(o, text, options)
            return ([[
                hypertext[0,1;7,0.8;deposit_here;<style halign=center color=#000000 size=24>Deposit Here</style>]
            ]]):format()
        end,

        finish = function(o)
            return fs .. "container_end[]"
        end
    }
end



-- Options:
-- color = #ffffff
-- font_size = number
-- align = left|center|right
function formspec.