local auth = {}

local tokens = {}
local refresh_tokens = {}
local user_ids = {}

-- NOTE: Login will be handled by the MSP server directly, this function is for dev/debug purposes only
function auth.login(name, callback)
    local payload = {username = name}
    tribyu_api.post(tribyu_api.endpoints.auth_login, payload, function(success, resp)
        if success then
            core.log("action", name .. " successfully authenticated to Firebase.")
            if resp and resp.data and resp.data.metaData and resp.data.metaData.userId and resp.data.metaData.token and resp.data.metaData.refreshToken then
                tokens[name] = resp.data.metaData.token
                refresh_tokens[name] = resp.data.metaData.refreshToken
                user_ids[name] = resp.data.metaData.userId
                if callback then
                    callback(name, true)
                end
                return
            else
                core.log("error", "Invalid response format from auth.login status 200 for user " .. name .. ": " .. dump(resp))
            end
        else
            core.log("action", name .. " failed to authenticate on Firebase. Resp: " .. dump(resp))
        end
        if callback then
            callback(name, false)
        end
    end)
end

function auth.refresh(name, callback)
    local refresh_token = refresh_tokens[name]
    if refresh_token == nil then
        core.log("error", name .. " calling auth.refresh but no refresh token found!")
        return
    end
    local payload = {refresh_token = refresh_token}
    tribyu_api.post(tribyu_api.endpoints.auth_refresh, payload, function(success, resp)
        if success then
            if resp and resp.data and resp.data.metaData and resp.data.metaData.token and resp.data.metaData.refreshToken then
                tokens[name] = resp.data.metaData.token
                refresh_tokens[name] = resp.data.metaData.refreshToken
                if callback then
                    callback(true)
                end
                return
            else
                core.log("error", "Invalid response format from auth.refresh status 200 for user " .. name .. ": " .. dump(resp))
            end
        else
            core.log("action", name .. " failed to refresh token on Firebase. Resp: " .. dump(resp))
        end
        if callback then
            callback(false)
        end
    end)
end

-- Get the Firebase auth token
function auth.get_token(name)
    return tokens[name]
end

-- Get the Firebase refresh token
function auth.get_refresh_token(name)
    return refresh_tokens[name]
end

-- Get the Firebase user id (email)
function auth.get_user_id(name)
    return user_ids[name]
end

-- Clear all local auth session data from this user
function auth.clear(name)
    tokens[name] = nil
    refresh_tokens[name] = nil
    user_ids[name] = nil
end

core.register_on_joinplayer(function(player)
    local p_name = player:get_player_name()
    tribyu_api.msp.get_auth_tokens(p_name, function(success, auth_token, refresh_token, user_id)
        if success then
            tokens[p_name] = auth_token
            refresh_tokens[p_name] = refresh_token
            user_ids[p_name] = user_id
        else
            core.log("error", "Could not get auth tokens of " .. p_name)
        end
    end)
end)

core.register_on_leaveplayer(
    function(player, timed_out)
        local p_name = player:get_player_name()
        auth.clear(p_name)
    end
)

return auth