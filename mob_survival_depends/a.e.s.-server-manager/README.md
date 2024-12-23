# Server Manager Mod Documentation

## Overview

The `server_manager` mod is a comprehensive mod for Luanti servers that provides various features and functionalities to help manage and moderate the server. It includes features such as chat moderation, player management, roles and permissions, broadcasting messages, and more.

## Features

### Chat Moderation

The mod includes several features to moderate the in-game chat:

- **Caps Prevention**: Prevents players from abusing CAPS in their chat messages. If a player uses too many capital letters, they will be muted temporarily.
- **Flood Prevention**: Limits the rate at which players can send chat messages to prevent chat flooding. If a player sends messages too quickly, they will be muted temporarily.
- **Mute**: Allows server administrators to mute players for a specified duration or permanently. Muted players cannot send chat messages.


### Player Management

The mod provides tools for managing players on the server:

- **AFK Detection**: Detects when players are away from keyboard (AFK).
- **IP Tracking**: Tracks the IP addresses of online players for moderation purposes: use `/accounts <pl_name>` to see someone's online accounts.


### Roles and Permissions

The mod includes a role and permission system:

- **Roles**: Allows defining custom roles with specific permissions and capabilities.
- **Role Database**: Stores player roles and permissions in a database for persistence.
- **Role API**: Provides an API for managing roles and permissions programmatically.
- **Role Nametag**: Displays the player's role as a nametag above their character.
- **Role Chat Prefix**: Adds a prefix to the player's chat messages based on their role.
- **Role Player Manager**: Allows managing player roles and permissions through chat commands.

The mod supports two types of roles:

- **Static Role**: A static role is the player's most important role, the one that has priority and that is always displayed as the player's nametag and chat prefix, regardless of any other equipped roles.
- **Equippable Role**: An equippable role is a role that can be equipped or unequipped by the player or an administrator. When an equippable role is equipped, if no static roles are defined, it will override the player's default role and be displayed as the nametag and chat prefix. If a static role is defined, the equippable role will just be concatenated to the static role as a chat prefix, but won't be showed as the nametag.

This distinction between static and equippable roles allows for greater flexibility in managing player roles and permissions. Static roles can be used for permanent or long-term assignments (staff roles), while equippable roles can be used for temporary or situational assignments (VIP, event, etc).

If a player has more than a static role unlocked, you can select which one to display with the `/role setstatic <player> <role>` command. Technically, if you really need to, you can also use it to set a non-static role as static for a player.


### Miscellaneous

- **Broadcast Messages**: Periodically broadcasts configurable messages to all players on the server.
- **Custom Nodes**: Registers custom nodes such as barriers and invisible light sources.
- **Custom Privileges**: Allows registering custom privileges for fine-grained permissions control.



## Chat Commands

The mod provides several chat commands for managing the server and players:

- `/tp <player> [to_target]`: Teleports you to player or the specified player to the target player.
- `/mute <player> <duration> <unit (m, h)> <reason>`: Mutes the specified player for the given duration and reason.
- `/unmute <player>`: Unmutes the specified player.
- `/role` subcommands:
  - `/role unlock <player> <role>`: Unlocks the specified role for the player.
  - `/role remove <player> <role>`: Removes the specified role from the player.
  - `/role equip <player> <role>`: Equips the specified role for the player.
  - `/role unequip <player>`: Unequips the currently equipped role for the player.
  - `/role setstatic <player> <role>`: Sets the specified role as the static role for the player.
  - `/role renew <player> <role>`: Renews the specified role for the player by resetting the time left for it to expire to the original duration again. If the role expires, it will get removed from the player and you won't be able to renew it anymore, but you'll have to unlock it to them again.
  - `/role list [player]`: Lists the roles for the specified player or all available roles if no player is provided.
- `/report <player> <reason>`: Reports the specified player for the given reason.
- `/reports <num>`: Shows the last <num> reports. Subcommands:
  - `/reports from <reporter> <num>`
  - `/reports about <reported> <num>`
  - `/reports reset`: Erases all reports from the database.
- `/spectate <target>`: Spectates the specified player, useful to check if someone is cheating.
- `/unspectate`: Unspectates the player.
- `/accounts <player>`: Lists the online accounts of the specified player.


## License

The `server_manager` mod is licensed under the GNU General Public License v3.0. You can find the full license text in the `LICENSE` file. The assets are CC0.
