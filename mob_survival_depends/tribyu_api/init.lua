tribyu_api = {}

local MOD_PATH = core.get_modpath(core.get_current_modname()) .. "/"
local TIMEOUT = 4

local storage = core.get_mod_storage()
local http_api = minetest.request_http_api();
if not http_api then
    core.log("error", "HTTP access hasn't been granted to tribyu_api. Cannot start.")
    return
end

function load_submodule(filename)
    local path = MOD_PATH .. filename
    local f, err = loadfile(path)
    if f == nil then
        core.log("error", "Failed to load submodule " .. filename .. ": " .. err)
        return nil
    end
    return f()
end

-- Load Submodules
-- endpoints must be loaded first
tribyu_api.endpoints = load_submodule("endpoints.lua")
tribyu_api.auth = load_submodule("auth.lua")
tribyu_api.auction_house = load_submodule("auction_house.lua")
tribyu_api.msp = load_submodule("msp.lua")
tribyu_api.user = load_submodule("user.lua")

-- Local Functions

local function get_payload_str(payload)
    if type(payload) == "string" then
        return payload
    end
    return core.write_json(payload)
end

-- Callback receives (success, response_data)
-- response_data can be nil
-- if refresh_token == true, user must be set to the player name
local function http_fetch(request, callback, refresh_token, user)
    core.debug(request.method .. " " .. request.url)
    http_api.fetch(request, function(response)
        core.debug(request.method .. " " .. request.url .. ": " .. dump(response))
        if response.succeeded then
            local response_json = core.parse_json(response.data or "")
            if refresh_token and response.code == 403 then 
                -- we must refresh the auth token
                tribyu_api.auth.refresh(user, function(success)
                    if success then
                        -- try again, but without a new refresh attempt to avoid infinite recursion
                        http_fetch(request, callback, false, nil)
                    else
                        -- could not refresh token, so original request fails
                        callback(false, response_json)
                    end
                end)
            else
                callback(response.code == 200, response_json)
            end
        else
            callback(false, nil)
        end
    end)
end

local function api_key_request(method, endpoint, payload, callback)
    if not endpoint or not endpoint.url then
        core.log("error", "api_key_request with no endpoint set!")
        return
    end
    if endpoint.auth_mode ~= tribyu_api.endpoints.auth_mode.API_KEY and endpoint.auth_mode ~= tribyu_api.endpoints.auth_mode.NONE then
        core.log("error", "Endpoint " .. endpoint.name .. " does not use API_KEY or NONE auth mode!")
        return
    end
    local request = {
        url = endpoint.url,
        timeout = TIMEOUT,
        method = method,
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json"
        },
    }
    if endpoint.auth_mode == tribyu_api.endpoints.auth_mode.API_KEY then
        table.insert(request.extra_headers, "API-KEY: " .. tribyu_api.endpoints.get_api_key())
    end
    if payload then
        local payload_str = core.write_json(payload)
        if payload_str == nil then
            core.log("error", "Unable to deserialize payload for " .. endpoint.name .. ": " .. dump(payload))
            return
        end
        request.data = payload_str
    end
    http_fetch(request, callback, false, nil)
end

local function bearer_token_request(method, user, endpoint, payload, callback)
    if not endpoint or not endpoint.url then
        core.log("error", "bearer_token_request with no endpoint set!")
        return
    end
    if endpoint.auth_mode ~= tribyu_api.endpoints.auth_mode.BEARER_TOKEN then
        core.log("error", "Endpoint " .. endpoint.name .. " does not use BEARER_TOKEN auth mode!")
        return
    end
    if not user then
        core.log("error", "Endpoint " .. endpoint.name .. " requires user, got nil.")
        return
    end
    local token = tribyu_api.auth.get_token(user)
    if not token then
        core.log("error", "User " .. user .. " is not authenticated.")
        return
    end
    local request = {
        url = endpoint.url,
        timeout = TIMEOUT,
        method = method,
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "Authorization: Bearer " .. token
        },
    }
    if payload then
        local payload_str = core.write_json(payload)
        if payload_str == nil then
            core.log("error", "Unable to deserialize payload for " .. endpoint.name .. ": " .. dump(payload))
            return
        end
        request.data = payload_str
    end
    http_fetch(request, callback, true, user)
end

-- REST Functions

function tribyu_api.get(endpoint, callback)
    api_key_request("GET", endpoint, nil, callback)
end

function tribyu_api.post(endpoint, payload, callback)
    api_key_request("POST", endpoint, payload, callback)
end

function tribyu_api.put(endpoint, payload, callback)
    api_key_request("PUT", endpoint, payload, callback)
end

function tribyu_api.user_get(p_name, endpoint, callback)
    bearer_token_request("GET", p_name, endpoint, nil, callback)
end

function tribyu_api.user_post(p_name, endpoint, payload, callback)
    bearer_token_request("POST", p_name, endpoint, payload, callback)
end

function tribyu_api.user_put(p_name, endpoint, payload, callback)
    bearer_token_request("PUT", p_name, endpoint, payload, callback)
end

function tribyu_api.download(p_name, url, filename, callback)
    local request = {
        url = url,
        timeout = TIMEOUT,
        method = "GET",
    }
    http_api.fetch(request, function(response)
        core.debug("downloading " .. request.url)
        if response.succeeded and response.code == 200 and response.data then
            local options = {filename = filename, filedata = response.data, to_player = p_name, ephemeral = false}
            local success = core.dynamic_add_media(options, function(p_name)
                    core.log("action", p_name .. " received file " .. filename)
                    callback(true)
            end)
            if not success then 
                core.log("error", "Unable to send " .. filename .. " to user " .. p_name)
                callback(false)
            end
        else
            core.log("error", "Failed to download file from " .. request.url)
            callback(false)
        end
    end)
end