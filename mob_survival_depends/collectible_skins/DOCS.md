# Collectible skins docs

# Table of Contents
* [1 Skins](#1-skins)
	* [1.1 Collections](#11-collections)
	* [1.2 UI](#12-ui)
	* [1.3 Storage](#13-storage)
* [2 API](#2-api)
    * [2.1 Skins handlers](#21-skins-handlers)
    * [2.2 Utils](#22-utils)
    * [2.3 Getters](#23-getters)
    * [2.4 Setters](#24-setters)
    * [2.5 Callbacks](#25-callbacks)
* [3 About the author(s)](#3-about-the-authors)

## 1 Skins
A skin is a table with the following fields:
```yaml
skin_name:
    name:
    description:
    texture:
    hint: (optional, default "(locked)")
    model: (optional, default "character.b3d")
    tier: (optional, default 1)
```

Where `skin_name` is a technical name used as unique identifier to retrieve the skin. There can't be more skins with the same technical name.  

Check the README to know how to add new skins.  

When a skin is correctly loaded, it also adds the extra field `technical_name` for cross-referencing, and `collection` to indicate the collection it's in.  

Skins can be assigned either as temporary or permanent. A temporary skin is not remembered when players log in again, a permanent is.

## 1.1 Collections
Skins are declared inside `.yaml` files, representing one collection each. Check out the `skins` world folder to learn about how they work.  
Data about collections can be retrieved via a few functions like `get_collection(..)`. Such data is a table containing:
* `name`: (string) the readable translated name of the collection
* `image`: (string) the image shown in the upper left corner of the built-in UI. Default is `nil`
* `background`: (string) the image shown as a custom background in the right part of the built-in UI. Default is `nil`
* `skins`: (table) an ordered list of the skin names belonging to the collection. It's the same as doing `get_sorted_skins(..)`

## 1.2 UI
Collectible Skins comes with a built-in UI, but it also allows modders to implement their own interface (you can either override `collectible_skins.show_skins_GUI(..)` or create your own implementation from scratch). Keep in mind that the main goal of Collectible Skins is to provide an API to register skins, meaning that the built-in UI is designed to be useful for generic uses, and that it won't see great feature updates.  

What it does is to display all the skins sharing the same model the player has, ignoring empty collections.

## 1.3 Storage
Collectible Skins uses the mod storage to store all the skins unlocked by a certain player, and a string metadata (`collectible_skins:skin`) to store the technical name of the skin currently equipped. There's no need to access (nor, most importantly, alter) such metadata, as the API already provides all the functions needed (e.g. `get_player_skin(..)`)

## 2 API
### 2.1 Skins handlers
* `collectible_skins.unlock_skin(p_name, skin_name)`: unlocks skin `skin_name` for `p_name`
* `collectible_skins.remove_skin(p_name, skin_name)`: removes skin `skin_name` from `p_name`

### 2.2 Utils
* `collectible_skins.is_skin(skin_name)`: returns whether `skin_name` is an actual skin, as a boolean
* `collectible_skins.has_skin(p_name, skin_name)`: returns whether `p_name` has unlocked the specified skin, as a boolean
* `collectible_skins.does_collection_exist(coll_name)`: returns whether a collection called `c_name` exists, as a boolean
* `collectible_skins.is_in_storage(p_name)`: returns whether `p_name` has connected at least once since the addition of Collectible Skins, as a boolean
* `collectible_skins.show_skins_GUI(p_name)`: opens up the default skins GUI
  * If you want to reimplement the built-in interface, override this function so that it calls a `minetest.show_formspec(..)` with your custom formspec

### 2.3 Getters
* `collectible_skins.get_skins(<filter>)`: returns a copy of all the loaded skins, format `{skin_name = skin}`
  * `filter` is an optional table that can contain one or more of the following fields: `collection`, `tier`, `model`. It only returns skins matching the declared values
* `collectible_skins.get_collections()`: returns a copy of all the loaded collections, format `{coll_name = coll_data}`
* `collectible_skins.get_sorted_skins(coll_name, <filter>)`: returns a table of format `{"skin_name1", "skin_name2"}`, sorted by the declaration order in the collection file (no gaps). See `get_skins(..)` for `filter`
* `collectible_skins.get_sorted_collections()`: returns a table of format `{"coll_name1", "coll_name2"}`, sorted by collections' weights (no gaps)
* `collectible_skins.get_skins_amount(<filter>)`: returns the amount of the current skins.  See `get_skins(..)` for `filter`
* `collectible_skins.get_skin(skin_name)`: returns a copy of the skin corresponding to `skin_name`, if any
* `collectible_skins.get_collection(coll_name)`: returns a copy of the specified collection, format `{coll_name = coll_data}`
* `collectible_skins.get_player_skins(p_name, <filter>)`: returns a table containing as value all the skins that `p_name` has unlocked, format `{"skin_name1", "skin_name2"}`. See `get_skins(..)` for `filter`
* `collectible_skins.get_player_skin(p_name, <permanent_only>)`: returns a copy of the skin that `p_name` has currently equipped, if online.
  * `permanent_only` is a boolean that, if present, ignores the temporary skin the player might have equipped, returning the permanent one

### 2.4 Setters
* `collectible_skins.set_skin(player, skin_name, <is_permanent>)`: sets skin `skin_name` to `player`.
  * Player must be online or it won't work
  * `is_permanent` is an optional boolean indicating whether the skin should be remembered the next time they log in if they didn't change it before logging out (defaults to `false`)

### 2.5 Callbacks
* `collectible_skins.register_on_set_skin(function(p_name, skin_name))`: additional behaviour when a player changes skin. This callback is not launched when people log in

## 3. About the author(s)
I'm Zughy (Marco), a professional Italian pixel artist who fights for FOSS and digital ethics. If this library spared you a lot of time and you want to support me somehow, please consider donating on [Liberapay](https://liberapay.com/Zughy/). Also, this project wouldn't have been possible if it hadn't been for some friends who helped me testing through: `Giov4`, `SonoMichele`, `_Zaizen_` and `Xx_Crazyminer_xX`
