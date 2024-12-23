-- Thanks moreblocks for making every slab and stair explode when disabling the mod,
-- it was very fun to fix. The time of our life, master in design

local default_nodes = {
    "stone",
    "stone_block",
    "cobble",
    "mossycobble",
    "brick",
    "sandstone",
    "steelblock",
    "goldblock",
    "copperblock",
    "bronzeblock",
    "diamondblock",
    "tinblock",
    "desert_stone",
    "desert_stone_block",
    "desert_cobble",
    "meselamp",
    "glass",
    "tree",
    "wood",
    "jungletree",
    "junglewood",
    "pine_tree",
    "pine_wood",
    "acacia_tree",
    "acacia_wood",
    "aspen_tree",
    "aspen_wood",
    "obsidian",
    "obsidian_block",
    "obsidianbrick",
    "obsidian_glass",
    "stonebrick",
    "desert_stonebrick",
    "sandstonebrick",
    "silver_sandstone",
    "silver_sandstone_brick",
    "silver_sandstone_block",
    "desert_sandstone",
    "desert_sandstone_brick",
    "desert_sandstone_block",
    "sandstone_block",
    "coral_skeleton",
    "ice",
}

for _, name in pairs(default_nodes) do
    minetest.register_alias_force("moreblocks:stair_" .. name, "stairs:stair_" .. name)
    minetest.register_alias_force("moreblocks:stair_" .. name .. "_outer", "stairs:stair_outer_" .. name)
    minetest.register_alias_force("moreblocks:stair_" .. name .. "_inner", "stairs:stair_inner_" .. name)
    minetest.register_alias_force("moreblocks:slab_" .. name, "stairs:slab_" .. name)
end