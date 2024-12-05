# Skins collectible

Wear and unlock skins on Minetest  
  
<a href="https://liberapay.com/Zughy/"><img src="https://i.imgur.com/4B2PxjP.png" alt="Support my work"/></a>  

### How to

To add a skin:
1. be sure the world has been launched at least once with Collectible Skins active
2. go to `your world folder/skins`
3. open an existing `.yml` file or create a new one (Collectible Skins can read multiple skins from multiple files)
4. follow the template down below (`skin_name` is the technical name without spaces of sort, `name` is the readable name)
```yaml
skin_name:
    name:
    description:
    texture:
    hint: (optional, default "(locked)")
    model: (optional, default none)
    tier: (optional, default 1)
```

For more information check out the `instructions.txt` file inside that folder.  

For using the API, check out the [DOCS](/DOCS.md)

### Commands
* `/skins remove <p_name> <skin_name>`: removes a skin
* `/skins unlock <p_name> <skin_name>`: unlocks a skin

### Want to help?
Feel free to:
* open an [issue](https://gitlab.com/zughy-friends-minetest/collectible-skins/-/issues)
* submit a merge request. In this case, PLEASE, do follow milestones and my [coding guidelines](https://cryptpad.fr/pad/#/2/pad/view/-l75iHl3x54py20u2Y5OSAX4iruQBdeQXcO7PGTtGew/embed/). I won't merge features for milestones that are different from the upcoming one (if it's declared), nor messy code
* join the dev room of my Minetest server (A.E.S.) on [Matrix](https://matrix.to/#/%23minetest-aes-dev:matrix.org)
