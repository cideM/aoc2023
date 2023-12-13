local function advance(c, groups, seq)
	local g = groups[1]
	if c == "#" then
		if seq + 1 == g or seq + 1 < g then
			return groups, seq + 1
		end
		return nil
	elseif c == "." then
		if seq == g then
			return { table.unpack(groups, 2) }, 0
		end
		if seq < g and seq > 0 then
			return nil
		elseif seq < g and seq == 0 then
			return groups, 0
		end
	end
end

local cache = {}
local function combinations(s, groups, seq)
	seq = seq or 0
	if not groups then
		return 0
	end

	local key = seq .. s .. table.concat(groups, ";")
	if cache[key] then
		return cache[key]
	elseif #groups == 0 then
		return s:match("#") and 0 or 1
	elseif s == "" then
		local result = seq == groups[1] and #groups == 1 and 1 or 0
		cache[key] = result
		return result
	end

	local head, tail, t = s:sub(1, 1), s:sub(2), 0
	t = (head == "#" or head == ".") and combinations(tail, advance(head, groups, seq))
		or combinations(tail, advance("#", groups, seq)) + combinations(tail, advance(".", groups, seq))
	cache[key] = t
	return t
end

local p1, p2 = 0, 0
for line in io.lines() do
	local s, s2 = line:match("([^%s]+) (.+)")
	local groups = {}
	for d in s2:gmatch("%d+") do
		table.insert(groups, tonumber(d))
	end
	p1 = p1 + combinations(s, groups)
	s, s2 = table.concat({ s, s, s, s, s }, "?"), table.concat({ s2, s2, s2, s2, s2 }, ",")
	groups = {}
	for d in s2:gmatch("%d+") do
		table.insert(groups, tonumber(d))
	end
	p2 = p2 + combinations(s, groups)
end
print(p1, p2)
