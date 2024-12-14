

function smob_dump_table_compare_keys(tableA, tableB, compTag, predicate, msg) 
	minetest.debug(compTag..": table comparison started.")
	local keys = {}
	for k,v in pairs(tableA) do
		if predicate(k, tableB) then keys[k] = 1 end
	end
	for k,v in pairs(tableB) do
		if predicate(k, tableA) then keys[k] = 1 end
	end
	--print filtered results
	for k,v in pairs(table_name) do
		minetest.debug(keys[i])
	end
	minetest.debug(compTag..": table comparison ended.")
end

function smob_dump_table_diff(tableA, tableB, compTag) 
	local has_key = function(t, k)
		return t[k] == nil
	end
	smob_dump_table_compare_keys(tableA, tableB, compTag, has_key, "") 
end

function smob_dump_table_cross(tableA, tableB, compTag) 
	local has_key = function(t, k)
		return t[k] ~= nil
	end
	smob_dump_table_compare_keys(tableA, tableB, compTag, has_key, "") 
end