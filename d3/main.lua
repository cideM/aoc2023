-- Completed in 54m19s0 with about 30s for part 2
local SYMBOLS, GRID, P1, P2 = {}, {}, 0, 0

local function key(x, y)
	return string.format("%s;%s", x, y)
end

local function unkey(s)
	local x, y = s:match("(%d+);(%d+)")
	return x, y
end

-- Build the grid and remember the symbol locations
do
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
end

local SEEN = {}
for k_sym, sym in pairs(SYMBOLS) do
	-- build_number first goes left until it runs out of numbers,
	-- and then it goes right to find the full number
	-- . . . 5 4 [2] 1 2
	--            ^-- you are here
	-- 1. Go to the start
	-- . . . [5] 4 2 1 2
	--        ^-- you are now here
	-- 2. Go to the end while tracking the digits
	-- . . . 5 4 2 1 2 []
	--       ^ ^ ^ ^ ^  ^-- you are here
	local build_number = function(k)
		local x, y = unkey(k)
		local digits = {}
		while tonumber(GRID[key(x, y)]) do
			x = x - 1
		end
		x = x + 1
		while tonumber(GRID[key(x, y)]) do
			SEEN[key(x, y)] = true
			table.insert(digits, GRID[key(x, y)])
			x = x + 1
		end

		local n = tonumber(table.concat(digits))
		return n
	end

	local x_sym, y_sym = unkey(k_sym)
	local adjacent_numbers = {}
	for _, dx in ipairs({ -1, 0, 1 }) do
		for _, dy in ipairs({ -1, 0, 1 }) do
			local x, y, k = x_sym + dx, y_sym + dy
			local k = key(x, y)
			-- We can visit the same digit from multiple symbols (I guess?),
			-- so we need to track what we've seen so far
			if tonumber(GRID[k]) and not SEEN[k] then
				local n = build_number(k)
				table.insert(adjacent_numbers, n)
				P1 = P1 + n
			end
		end
	end
	if sym == "*" and #adjacent_numbers == 2 then
		local a, b = table.unpack(adjacent_numbers)
		P2 = P2 + a * b
	end
end
print(P1, P2)
