local function apply(map, seed)
	local l, r, vec = table.unpack(map)
	local l2, r2 = table.unpack(seed)

	if r < l2 or l > r2 then
		return { seed }, {}
	end

	if l2 >= l and r2 <= r then -- seed is in map
		return {}, { { l2 + vec, r2 + vec } }
	end

	if l >= l2 and r <= r2 then -- map is in seed
		local unmatched = {}

		if l ~= l2 then
			table.insert(unmatched, { l2, l - 1 })
		end
		if r ~= r2 then
			table.insert(unmatched, { r + 1, r2 })
		end
		return unmatched, { { l + vec, r + vec } }
	end

	if l <= l2 and r <= r2 then -- overlap on the left
		return { { r + 1, r2 } }, { { l2 + vec, r + vec } }
	end

	if l >= l2 and r >= r2 then -- overlap on the right
		return { { l2, l - 1 } }, { { l + vec, r2 + vec } }
	end
end

local SEEDS, TODO, P1, P2 = {}, {}, math.huge, math.huge
for line in io.lines() do
	if line:find("^seeds:") then
		for pair in line:gmatch("%d+ %d+") do
			local start, len = pair:match("(%d+) (%d+)")
			start, len = tonumber(start), tonumber(len)
			table.insert(SEEDS, { start, start + len - 1 })
			table.insert(SEEDS, { tonumber(start), tonumber(start) })
			table.insert(SEEDS, { tonumber(len), tonumber(len) })
		end
	end

	if line:find("map:") then
		table.move(TODO, 1, #TODO, #SEEDS + 1, SEEDS) -- leftover unmatched carry over
		TODO, SEEDS = table.move(SEEDS, 1, #SEEDS, 1, {}), {}
	end

	local dest, map, len = line:match("^(%d+) (%d+) (%d+)")
	if dest and map and len then
		dest, map, len = tonumber(dest), tonumber(map), tonumber(len)
		local all_unmatched = {}
		for _, range in ipairs(TODO) do
			local unmatched, matched = apply({ map, map + len - 1, dest - map }, range)
			table.move(matched, 1, #matched, #SEEDS + 1, SEEDS)
			table.move(unmatched, 1, #unmatched, #TODO + 1, all_unmatched)
		end
		TODO = all_unmatched
	end
end

table.move(TODO, 1, #TODO, #SEEDS + 1, SEEDS)

for _, v in pairs(SEEDS) do
	if v[1] == v[2] then
		P1 = math.min(v[1], P1)
	else
		P2 = math.min(v[1], P2)
	end
end
print(P1, P2)
