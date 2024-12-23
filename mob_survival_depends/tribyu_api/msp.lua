msp = {}

-- Callback args: success, auth_token, refresh_token, user_id (email)
function msp.get_auth_tokens(p_name, callback)
    tribyu_api.get(tribyu_api.endpoints.msp_get_auth_tokens:with_url_param(p_name), function(success, resp)
        if success and resp then
            callback(true, resp.token, resp.refreshToken, resp.userId)
        else
            core.log("error", "get_auth_tokens api call failed for " .. p_name)
            callback(false)
        end
    end)
end

-- Callback args: success, data
-- Data keys: {success, joined, reason} or nil
function msp.enqueue_player(p_name, server, callback)
    local payload = {player = p_name, server = server}
    tribyu_api.put(tribyu_api.endpoints.msp_enqueue, payload, function(success, resp)
        if success then
            local data = {
                success = resp.success,
                joined = resp.joined,
                reason = resp.reason
            }
            callback(true, data)
        elseif resp then
            core.log("action", "enqueue_player failed for " .. p_name .. ": " .. resp)
            callback(false, resp)
        else
            core.log("error", "enqueue_player api call failed for " .. p_name)
            callback(false, nil)
        end
    end)
end

-- Callback args: success, data
-- Data keys: {success, reason} or nil
function msp.hop_player(p_name, server, callback)
    local payload = {player = p_name, server = server}
    tribyu_api.put(tribyu_api.endpoints.msp_hop, payload, function(success, resp)
        if success then
            local data = {
                success = resp.success,
                reason = resp.reason
            }
            callback(true, data)
        elseif resp then
            core.log("action", "hop_player failed for " .. p_name .. ": " .. resp)
            callback(false, resp)
        else
            core.log("error", "hop_player api call failed for " .. p_name)
            callback(false, nil)
        end
    end)
end

return msp