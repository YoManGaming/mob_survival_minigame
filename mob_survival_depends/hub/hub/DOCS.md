# Hub DOCS

**This mod is still experimental, expect brekages**

## 1. Getters
* `hub.get_hub_spawn_point()`: returns the spawn point declared in the settings file
* `hub.get_additional_items()`: returns the list of items given when entering the hub
* `hub.get_players_in_hub(to_player)`: returns the list of players connected as a table of their names (format `{[1] = name, [2] = other_name}`) or, if `to_player` is `true`, as players

## 2. Setters
* `hub.set_hub_physics(player)`: sets the physics of the hub to `player`
* `hub.set_items(player)`: sets the items of the hub to `player`
* `hub.set_celestial_vault(celvault)`: sets the celestial vault (as in the MT API) to every player in the hub

## 3. About the author(s)
I'm Zughy (Marco), a professional Italian pixel artist who fights for FOSS and digital ethics. If this mod spared you a lot of time and you want to support me somehow, please consider donating on [Liberapay](https://liberapay.com/Zughy/). Also, this project wouldn't have been possible if it hadn't been for some friends who helped me testing through: `Giov4`, `MrFreeman`, `_Zaizen_` and `Xx_Crazyminer_xX`
