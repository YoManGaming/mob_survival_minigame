local endpoints = {}

local variables = {}
local auth_modes = {}

endpoints.auth_mode = {
    NONE = 0, 
    API_KEY = 1, 
    API_KEY_AUTH = 2, 
    BEARER_TOKEN = 3
}

endpoints.mt = {}
endpoints.mt.__index = function(table, key)
    return {
        name = key,
        url = variables[key],
        auth_mode = auth_modes[key],
        with_url_param = function(o, param)
            if string.sub(o.url, -1) == "/" then
                o.url = o.url .. core.urlencode(param)
            else
                o.url = o.url .. "/" .. core.urlencode(param)
            end
            return o
        end
    }
end
setmetatable(endpoints, endpoints.mt)

function endpoints.get_api_key()
    return os.getenv("TRIBYU_API_KEY")
end

function endpoints.get_api_key_auth()
    return os.getenv("TRIBYU_API_KEY_AUTH")
end

function endpoints.load_env_var(name, env_var_name, auth_mode)
    local value = os.getenv(env_var_name)
    if not value or value == "" then
        core.debug("error", "Environment variable not found: " .. env_var_name)
    end
    variables[name] = value
    auth_modes[name] = auth_mode
end

-- Auth endpoints --

endpoints.load_env_var("auth_login", "TRIBYU_AUTH_LOGIN", endpoints.auth_mode.API_KEY_AUTH)
endpoints.load_env_var("auth_refresh", "TRIBYU_AUTH_REFRESH", endpoints.auth_mode.NONE)

-- MSP endpoints --

endpoints.load_env_var("msp_get_auth_tokens", "TRIBYU_MSP_GET_AUTH_TOKENS", endpoints.auth_mode.NONE)
endpoints.load_env_var("msp_enqueue", "TRIBYU_MSP_ENQUEUE", endpoints.auth_mode.NONE)
endpoints.load_env_var("msp_hop", "TRIBYU_MSP_HOP", endpoints.auth_mode.NONE)

-- User Profile endpoints --

endpoints.load_env_var("user_profile", "TRIBYU_USER_PROFILE", endpoints.auth_mode.BEARER_TOKEN)
endpoints.load_env_var("user_add_joules", "TRIBYU_USER_ADD_JOULES", endpoints.auth_mode.API_KEY)
endpoints.load_env_var("make_premium_purchase", "TRIBYU_USER_MAKE_PREMIUM_PURCHASE", endpoints.auth_mode.BEARER_TOKEN)
endpoints.load_env_var("make_deposit", "TRIBYU_USER_MAKE_DEPOSIT", endpoints.auth_mode.BEARER_TOKEN)
endpoints.load_env_var("withdraw", "TRIBYU_USER_WITHDRAW", endpoints.auth_mode.BEARER_TOKEN)
endpoints.load_env_var("update_ln_addr", "TRIBYU_USER_UPDATE_LN_ADDR", endpoints.auth_mode.BEARER_TOKEN)

-- Auction House endpoints --

endpoints.load_env_var("auction_get_items", "TRIBYU_AUCTION_GET_ITEMS", endpoints.auth_mode.API_KEY)

--

return endpoints