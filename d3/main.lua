-- Completed in 54m19s0 with about 30s for part 2
local SYMBOLS, GRID, P1, P2 = {}, {}, 0, 0

local function key(x, y)
	return string.format("%s;%s", x, y)
end

local function unkey(s)
	local x, y = s:match("(%d+);(%d+)")
	return x, y
end

local y = 1
for line in io.lines() do
	local x = 1
	for c in line:gmatch(".") do
		GRID[key(x, y)] = c
		if c ~= "." and not tonumber(c) then
			SYMBOLS[key(x, y)] = c
		end
		x = x + 1
	end
	y = y + 1
end

local SEEN = {}
for k, sym in pairs(SYMBOLS) do
	local x, y = unkey(k)
	local part_nums = {}
	for _, xy in ipairs({
		{ x - 1, y - 1 },
		{ x - 1, y },
		{ x - 1, y + 1 },
		{ x, y - 1 },
		{ x, y },
		{ x, y + 1 },
		{ x + 1, y - 1 },
		{ x + 1, y },
		{ x + 1, y + 1 },
	}) do
		local x2, y2 = table.unpack(xy)
		local k2 = key(x2, y2)
		if tonumber(GRID[k2]) and not SEEN[k2] then
			local digits = {}
			local xcur = x2
			while tonumber(GRID[key(xcur, y2)]) do
				xcur = xcur - 1
			end
			xcur = xcur + 1
			while tonumber(GRID[key(xcur, y2)]) do
				local k3 = key(xcur, y2)
				SEEN[k3] = true
				table.insert(digits, GRID[k3])
				xcur = xcur + 1
			end

			local n = tonumber(table.concat(digits))
			table.insert(part_nums, n)
			P1 = P1 + n
			SEEN[k2] = true
		end
	end
	if sym == "*" and #part_nums == 2 then
		local a, b = table.unpack(part_nums)
		P2 = P2 + a * b
	end
end
print(P1, P2)
