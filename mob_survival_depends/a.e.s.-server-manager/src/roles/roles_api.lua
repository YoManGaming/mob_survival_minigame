local function get_expiry_date(role) end

local pl_roles = roles.pl_roles
local def = roles.def  -- {"role_name" = {def...}, ...}
local S = core.get_translator("server_manager")


-- Unlocks a role for a player
---@param pl_name string The player's name
---@param role_name string The role's name
---@return boolean result if the role was unlocked, false otherwise - this can happen if the role is already unlocked
function roles.unlock_role(pl_name, role_name)
    if roles.has_role(pl_name, role_name) then
        return false
    end

    pl_roles[pl_name] = pl_roles[pl_name] or {}
    pl_roles[pl_name].roles = pl_roles[pl_name].roles or {}

    local role = def[role_name]

    if role.also_unlocks then
        for _, role_name in ipairs(role.also_unlocks) do
            roles.unlock_role(pl_name, role_name)
        end
    end

    if role.duration then
        local role_ref = {role_name, get_expiry_date(role)}
        table.insert(pl_roles[pl_name].roles, role_ref)
    else
        table.insert(pl_roles[pl_name].roles, role_name)
    end
    roles.update_db()

    if role.static then
        roles.set_static_role(pl_name, role_name)
    end

    if role.equippable and not roles.get_equipped_role(pl_name) then
        roles.set_equipped_role(pl_name, role_name)
    end

    return true
end



-- Removes a role from a player
---@param pl_name string The player's name
---@param role_name string The role's name
---@return boolean result if the role was removed, false otherwise - this can happen if the role was not unlocked
function roles.remove_role(pl_name, role_name)
    if not roles.has_role(pl_name, role_name) or role_name == "default" then
        return false
    end

    pl_roles[pl_name] = pl_roles[pl_name] or {}
    pl_roles[pl_name].roles = pl_roles[pl_name].roles or {}

    -- if the role_ref is its prefix
    local ref_idx = table.indexof(pl_roles[pl_name].roles, role_name)

    -- if the role_ref is a table
    if ref_idx == -1 then
        for i, ref in ipairs(roles.get_roles(pl_name)) do
            if type(ref) == "table" and ref[1] == role_name then
                ref_idx = i
                break
            end
        end
    end

    table.remove(pl_roles[pl_name].roles, ref_idx)

    if roles.get_static_role(pl_name) and roles.get_static_role(pl_name).internal_name == role_name then
        roles.clear_static_role(pl_name)
    end
    if roles.get_equipped_role(pl_name) and roles.get_equipped_role(pl_name).internal_name == role_name then
        roles.clear_equipped_role(pl_name)
    end

    local role = def[role_name]
    if role.also_unlocks then
        for _, role_ref in ipairs(role.also_unlocks) do
            roles.remove_role(pl_name, role_ref)
        end
    end

    roles.update_roles(pl_name)

    return true
end



-- Removes the static role from a player
---@param pl_name string The player's name
---@return boolean result if the role was removed, false otherwise - this can happen if the player has no static role
function roles.remove_static_role(pl_name)
    if not pl_roles[pl_name] or not pl_roles[pl_name].roles then
        return false
    end

    for _, role_ref in ipairs(roles.get_roles(pl_name)) do
        local role_name = roles.get_def(role_ref).internal_name

        if def[role_name].static_role then
            roles.remove_role(pl_name, role_name)
            return true
        end
    end

    return false
end



-- Renews a role for a player
---@param pl_name string The player's name
---@param role_name string The role's name
---@return boolean result if the role was renewed, false otherwise - this can happen if the role is not unlocked
function roles.renew(pl_name, role_name)
    for _, ref in ipairs(roles.get_roles(pl_name)) do
        if type(ref) == "table" then
            if ref[1] == role_name and roles.get_def(ref).duration then
                ref[2] = get_expiry_date(roles.get_def(ref[1]))
                roles.update_db()
                return true
            end
        end
    end

    return false
end



-- Returns whether a player has a role
---@param pl_name string The player's name
---@param role_name string The role's name
---@return boolean result if the player has the role, false otherwise
function roles.has_role(pl_name, role_name)
    if role_name == "default" then return true end

    for i, ref in ipairs(roles.get_roles(pl_name)) do
        if type(ref) == "table" then
            if ref[1] == role_name then
                return true
            end
        else
            if ref == role_name then
                return true
            end
        end
    end

    return false
end



-- Sets the static role for a player
---@param pl_name string The player's name
---@param role_name string The role's name
---@return boolean result if the role was set, false otherwise - this can happen if the role is not unlocked
function roles.set_static_role(pl_name, role_name)
    local role = def[role_name]

    if not roles.has_role(pl_name, role_name) then
        return false
    end

    pl_roles[pl_name].static_role = role.internal_name
    roles.update_roles(pl_name)

    return true
end



-- Sets the equipped role for a player
---@param pl_name string The player's name
---@param role_name string The role's name
---@return boolean result if the role was set, false otherwise - this can happen if the role is not unlocked
function roles.set_equipped_role(pl_name, role_name)
    local role = def[role_name]

    if not roles.has_role(pl_name, role_name) then
        return false
    end

    pl_roles[pl_name].equipped_role = role.internal_name
    roles.update_roles(pl_name)

    return true
end


-- Updates the nametag for a player by concatenating the static role prefix, or the equipped role prefix (in case the first one is not set) to the player's name
---@param pl_name string The player's name
---@return nil
function roles.update_nametag(pl_name)
    local player = core.get_player_by_name(pl_name)
    local static = roles.get_static_role(pl_name)
    local equipped = roles.get_equipped_role(pl_name)
    local default = roles.def["default"]

    if not player or server_manager.is_spectating(pl_name) then return end

    if static and static.prefix then
        player:set_nametag_attributes({
            text = core.colorize(static.prefix_color or "#ffffff", static.prefix .. " " .. pl_name),
            bgcolor = false
        })
    elseif equipped and equipped.prefix then
        player:set_nametag_attributes({
            text = core.colorize(equipped.prefix_color or "#ffffff", equipped.prefix .. " " .. pl_name),
            bgcolor = false
        })
    elseif default.prefix then
        player:set_nametag_attributes({
            text = core.colorize(default.prefix_color or "#ffffff", default.prefix .. " " .. pl_name),
            bgcolor = false
        })
    else
        player:set_nametag_attributes({
            text = pl_name,
            bgcolor = false
        })
    end
end


-- Updates the player's privileges based on the roles of the player: all in-role defined privileges are set to false, and only the privileges of the unlocked roles are set to true
---@param pl_name string The player's name
---@return nil
function roles.update_privs(pl_name)
    local pl_roles = roles.get_roles(pl_name)
    local privs = core.get_player_privs(pl_name)

    if privs.server then return false end

    -- setting all in role defined privs to false
    for name, def in pairs(roles.def) do
        for i, priv in ipairs(def.privs or {}) do
            privs[priv] = nil
        end
    end

    -- settings to true only the privs of the unlocked roles
    for i, role_ref in ipairs(pl_roles) do
        local role_def = roles.get_def(role_ref)

        for i, priv in ipairs(role_def.privs or {}) do
            privs[priv] = true
        end
    end

    core.set_player_privs(pl_name, privs)
end


-- Updates the nametag and privileges of a player, and updates the database.
---@param pl_name string The player's name
---@return nil
function roles.update_roles(pl_name)
    roles.update_nametag(pl_name)
    roles.update_privs(pl_name)
    roles.update_db()
end



-- Clears the equipped role for a player: it doesn't remove it, it just unequips it
---@param pl_name string The player's name
---@return boolean result if the role was cleared, false otherwise - this can happen if the role is not equipped
function roles.clear_equipped_role(pl_name)
    if not roles.get_equipped_role(pl_name) then
        return false
    end

    pl_roles[pl_name].equipped_role = nil
    roles.update_roles(pl_name)

    return true
end


-- Clears the static role for a player: it doesn't remove it, it just sets it as non-static for this player
---@param pl_name string The player's name
---@return boolean result if the role was cleared, false otherwise - this can happen if the role is not static
function roles.clear_static_role(pl_name)
    if not roles.get_static_role(pl_name) then
        return false
    end

    pl_roles[pl_name].static_role = nil
    roles.update_roles(pl_name)

    return true
end


-- Returns the static role for a player
---@param pl_name string The player's name
---@return role|false role if the role was found or false if not
function roles.get_static_role(pl_name)
    if not pl_roles[pl_name] then return false end
    return roles.get_def(pl_roles[pl_name].static_role)
end



-- Returns the equipped role for a player
---@param pl_name string The player's name
---@return role|nil role
function roles.get_equipped_role(pl_name)
    if not pl_roles[pl_name] then return nil end
    return roles.get_def(pl_roles[pl_name].equipped_role)
end



-- Returns the definition of a role
---@param ref role_ref The role's name or reference
---@return role|nil role if the role was found
function roles.get_def(ref)
    if type(ref) == "table" then  -- an expiring role
        ref = ref[1]
    end
    return def[ref]
end


-- Returns the roles of a player
---@param pl_name string The player's name
---@return table<number, role>|nil roles if the player has roles, nil otherwise
function roles.get_roles(pl_name)
    if not pl_roles[pl_name] or not pl_roles[pl_name].roles then
        return {"default"}
    end

    -- creating a table containing just the existing roles
    local unlocked_roles = {"default"}
    for i, ref in ipairs(pl_roles[pl_name].roles) do
        local def = roles.get_def(ref)
        if def then
            table.insert(unlocked_roles, def.internal_name)
        end
    end

    return unlocked_roles
end



-- Returns the roles that can be equipped by a player
---@param pl_name string The player's name
---@return table<number, role>|nil roles if the player has roles, nil otherwise
function roles.get_equippable_roles(pl_name)
    local output = {}

    for i, role_name in ipairs(roles.get_roles(pl_name)) do
        if def[role_name].equippable then
            table.insert(output, role_name)
        end
    end

    return output
end



function get_expiry_date(role)
    local duration_in_seconds = role.duration * 86400
    local expiry_date = server_manager.get_time_in_seconds() + duration_in_seconds

    return expiry_date
end
