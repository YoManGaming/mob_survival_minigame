auction_house = {}

local function create_item(item_data)
    return item_data.asicsType ~= nil, {
        id = item_data.id,
        quantity = item_data.quantity,
        price = item_data.price,
        seller_id = item_data.sellerId,
        seller_name = item_data.sellerName,
        created_at = item_data.createdAt,
        sold_at = item_data.soldAt,
        buyer_id = item_data.buyerId,
        type = item_data.type,
        name = item_data.name,
        asics_type = item_data.asicsType
    }
end

function auction_house.get_items(p_name, callback)
    tribyu_api.get(tribyu_api.endpoints.auction_get_items, function(success, resp)
        if success then
            if resp and resp.data then
                local asics_items = {}
                local joules_items = {}
                for _, v in ipairs(resp.data) do
                    --core.log("action", "item " .. dump(v))
                    local asics, item = create_item(v)
                    if asics then
                        table.insert(asics_items, item)
                    else
                        table.insert(joules_items, item)
                    end
                end
                callback(true, asics_items, joules_items)
                return
            else
                core.log("error", "Invalid response format from auction_house.get_items status 200 for user " .. p_name .. ": " .. dump(resp))
            end
        else
            core.log("action", "auction_house.get_items failed, user " .. p_name .. ". Resp: " .. dump(resp))
        end
        callback(false)
    end)
end

return auction_house