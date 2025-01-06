local S = core.get_translator("server_manager")

core.register_node("server_manager:barrier", {
    description = S("Barrier"),
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    air_equivalent = true,
    drop = "",
    inventory_image = "servermanager_barrier.png",
    wield_image = "servermanager_barrier.png"
})

core.register_node("server_manager:invisible_light", {
    description = S("Invisible Light"),
    drawtype = "airlike",
    paramtype = "light",
    walkable = false,
    pointable = false,
    diggable = false,
    light_source = core.LIGHT_MAX,
    sunlight_propagates = true,
    air_equivalent = true,
    drop = "",
    inventory_image = "servermanager_light.png",
    wield_image = "servermanager_light.png",
    buildable_to = true
})

core.register_alias("barrier", "server_manager:barrier")
core.register_alias("invisible_light", "server_manager:invisible_light")
