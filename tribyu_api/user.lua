user = {}

function user.get_profile(p_name, callback)
    tribyu_api.user_get(p_name, tribyu_api.endpoints.user_profile, function(success, resp)
        if success then
            if resp and resp.data then
                callback(resp.data)
                return
            else
                core.log("error", "Invalid response format from user.get_profile status 200 for user " .. p_name .. ": " .. dump(resp))
            end
        else
            core.log("action", "user.get_profile failed, user " .. p_name .. ". Resp: " .. dump(resp))
        end
        callback(nil)
    end)
end

function user.add_joules(p_name, amount, callback)
    local user_id = tribyu_api.auth.get_user_id(p_name)
    if not user_id then
        -- TODO: if user is offline, get email from another endpoint
        core.log("error", "user.add_joules - unable to retrieve user_id from user " .. p_name)
        return
    end
    local payload = {user = user_id, amount = amount}
    tribyu_api.put(tribyu_api.endpoints.user_add_joules, payload, function(success, resp)
        if success then
            if resp and resp.data and resp.data.id then
                core.log("action", "Added " .. resp.data.joules_added .. " joules to " .. resp.data.id)
                callback(resp.data)
                return
            else
                core.log("error", "Invalid response format from user.add_joules status 200 for user " .. p_name .. ": " .. dump(resp))
            end
        end
        callback(nil)
    end)
end

function user.make_premium_purchase(p_name, callback)
    local user_id = tribyu_api.auth.get_user_id(p_name)
    if not user_id then
        core.log("error", "user.make_premium_purchase - unable to retrieve user_id from user " .. p_name)
        return
    end
    tribyu_api.user_post(p_name, tribyu_api.endpoints.make_premium_purchase, "", function(success, resp)
        if success then
            if resp and resp.data and resp.data.user then
                core.log("action", "Premium purchase successfull for user " .. resp.data.user)
                callback(true, resp.data)
            else
                core.log("error", "Invalid response format from user.make_premium_purchase status 200 for user " .. p_name .. ": " .. dump(resp))
                callback(false, nil)
            end
        elseif resp and resp.status then
            core.log("action", "premium purchase failed for " .. p_name .. ": " .. resp.status)
            callback(false, resp.status)
        else
            core.log("error", "premium purchase api call failed for " .. p_name)
            callback(false, nil)
        end
    end)
end

function user.make_deposit(p_name, callback)
    local user_id = tribyu_api.auth.get_user_id(p_name)
    if not user_id then
        core.log("error", "user.make_deposit - unable to retrieve user_id from user " .. p_name)
        return
    end
    tribyu_api.user_get(p_name, tribyu_api.endpoints.make_deposit, function(success, resp)
        if success then
            if resp and resp.data and resp.data.request and resp.data.qr_image then
                core.log("action", "Deposit request successfull for " .. p_name)
                callback(true, resp.data)
            else
                core.log("error", "Invalid response format from user.make_deposit status 200 for user " .. p_name .. ": " .. dump(resp))
                callback(false, nil)
            end
        elseif resp and resp.status then
            core.log("action", "Deposit request failed for " .. p_name .. ": " .. resp.status)
            callback(false, resp.status)
        else
            core.log("error", "Deposit request api call failed for " .. p_name)
            callback(false, nil)
        end
    end)
end

function user.update_ln_addr(p_name, addr, callback)
    local user_id = tribyu_api.auth.get_user_id(p_name)
    if not user_id then
        core.log("error", "user.update_ln_addr - unable to retrieve user_id from user " .. p_name)
        return
    end
    local payload = {["ln-address"] = addr}
    tribyu_api.user_put(p_name, tribyu_api.endpoints.update_ln_addr, payload, function(success, resp)
        if success then
            callback(true)
        elseif resp and resp.status then
            core.log("action", "Update LN request failed for " .. p_name .. ": " .. resp.status)
            callback(false)
        else
            core.log("error", "Update LN request api call failed for " .. p_name)
            callback(false)
        end
    end)
end

function user.withdraw(p_name, callback)
    local user_id = tribyu_api.auth.get_user_id(p_name)
    if not user_id then
        core.log("error", "user.withdraw - unable to retrieve user_id from user " .. p_name)
        return
    end
    tribyu_api.user_post(p_name, tribyu_api.endpoints.withdraw, "", function(success, resp)
        if success then
                callback(true)
        elseif resp and resp.status then
            core.log("action", "Withdraw request failed for " .. p_name .. ": " .. resp.status)
            callback(false)
        else
            core.log("error", "Withdraw request api call failed for " .. p_name)
            callback(false)
        end
    end)
end

return user