-- part 1 42m 34s 16ms
local GRID, LOOP, CACHE, S_REAL = {}, {}, {}, nil

local function key(x, y)
	return string.format("%d;%d", x, y)
end

local function unkey(s)
	local x, y = s:match("(%d+);(%d+)")
	return tonumber(x), tonumber(y)
end

local function printgrid()
	local max_x, max_y = math.mininteger, math.mininteger
	for k in pairs(GRID) do
		local x, y = unkey(k)
		max_y = math.max(y, max_y)
		max_x = math.max(x, max_x)
	end

	for y = 1, max_y do
		local row = {}
		for x = 1, max_x do
			if CACHE[key(x, y)] then
				table.insert(row, "o")
			elseif LOOP[key(x, y)] then
				table.insert(row, "L")
			elseif GRID[key(x, y)] == "." then
				table.insert(row, "x")
			else
				table.insert(row, GRID[key(x, y)])
			end
		end
		print(table.concat(row))
	end
end

local function adjacent(k)
	local x, y = unkey(k)
	local cur, keys = GRID[k], {}
	if cur == "|" then
		keys = { key(x, y - 1), key(x, y + 1) }
	elseif cur == "F" then
		keys = { key(x + 1, y), key(x, y + 1) }
	elseif cur == "J" then
		keys = { key(x - 1, y), key(x, y - 1) }
	elseif cur == "-" then
		keys = { key(x - 1, y), key(x + 1, y) }
	elseif cur == "7" then
		keys = { key(x - 1, y), key(x, y + 1) }
	elseif cur == "L" then
		keys = { key(x, y - 1), key(x + 1, y) }
	elseif cur == "S" then
		local S_neighbours = { up = nil, down = nil, left = nil, right = nil }
		for _, neighbour_key in ipairs({ key(x, y - 1), key(x - 1, y), key(x + 1, y), key(x, y + 1) }) do
			if not GRID[neighbour_key] then
				goto continue
			end
			for _, neighbour_neighbour_key in ipairs(adjacent(neighbour_key)) do
				if GRID[neighbour_neighbour_key] == "S" then
					table.insert(keys, neighbour_key)
					if neighbour_key == key(x, y - 1) then
						S_neighbours.up = true
					elseif neighbour_key == key(x - 1, y) then
						S_neighbours.left = true
					elseif neighbour_key == key(x + 1, y) then
						S_neighbours.right = true
					elseif neighbour_key == key(x, y + 1) then
						S_neighbours.down = true
					end
					goto continue
				end
			end
			::continue::
		end
		if S_neighbours.up and S_neighbours.down then
			S_REAL = "|"
		elseif S_neighbours.left and S_neighbours.right then
			S_REAL = "-"
		elseif S_neighbours.up and S_neighbours.right then
			S_REAL = "L"
		elseif S_neighbours.up and S_neighbours.left then
			S_REAL = "J"
		elseif S_neighbours.down and S_neighbours.left then
			S_REAL = "7"
		elseif S_neighbours.down and S_neighbours.right then
			S_REAL = "F"
		end
	end

	local neighbour_keys = {}
	for _, neighbour_key in ipairs(keys) do
		local n = GRID[neighbour_key]
		if n and n ~= "." then
			table.insert(neighbour_keys, neighbour_key)
		end
	end
	return neighbour_keys
end

do
	local row, col = 1, 1
	for line in io.lines() do
		col = 1
		for c in line:gmatch(".") do
			GRID[key(col, row)] = c
			col = col + 1
		end
		row = row + 1
	end
end

local S = nil
for k, v in pairs(GRID) do
	if v == "S" then
		S = k
	end
end

local dists = { [S] = 0 }
local q = { S }
while #q > 0 do
	local cur = table.remove(q, 1)
	local cur_dist = dists[cur]
	for _, n in ipairs(adjacent(cur)) do
		if not dists[n] then
			table.insert(q, n)
			dists[n] = cur_dist + 1
		end
	end
end

local loop_end = nil
local max = math.mininteger
for k, v in pairs(dists) do
	if v > max then
		max = v
		loop_end = k
	end
end
print("======================")
print("P1", max)
assert(S)
GRID[S] = S_REAL

local qrev, seen = { loop_end }, { loop_end }
while #qrev > 0 do
	local cur = table.remove(qrev, 1)
	for _, k in ipairs(adjacent(cur)) do
		if not seen[k] then
			seen[k] = true
			table.insert(qrev, k)
			LOOP[k] = true
		end
	end
end

local function p2_adj(k)
	print(k)
	local x, y = unkey(k)
	local up = key(x, y - 1)
	local down = key(x, y + 1)
	local left = key(x - 1, y)
	local right = key(x + 1, y)

	if LOOP[k] then
		local neighbour_keys = {}
		for _, kk in ipairs(adjacent(k)) do
			table.insert(neighbour_keys, { key = kk })
		end
		if GRID[k] == "7" then
			table.insert(neighbour_keys, { key = up })
			table.insert(neighbour_keys, { key = right })
		elseif GRID[k] == "L" then
			table.insert(neighbour_keys, { key = left })
			table.insert(neighbour_keys, { key = down })
		elseif GRID[k] == "F" then
			table.insert(neighbour_keys, { key = left })
			table.insert(neighbour_keys, { key = up })
		elseif GRID[k] == "J" then
			table.insert(neighbour_keys, { key = right })
			table.insert(neighbour_keys, { key = down })
		end
		local out = {}
		for _, item in ipairs(neighbour_keys) do
			local kk = item.key
			if GRID[kk] then
				table.insert(out, { key = kk })
			end
		end

		return out
	end

	local neighbour_keys = {}

	local _, keys = assert(GRID[k], string.format("key %s not in GRID", k)), { up, down, left, right }
	for _, neighbour_key in ipairs(keys) do
		if GRID[neighbour_key] and not LOOP[neighbour_key] then
			table.insert(neighbour_keys, { key = neighbour_key })
		end
		if GRID[neighbour_key] and LOOP[neighbour_key] then
			if neighbour_key == up and GRID[up] ~= "-" then
				if GRID[up] == "L" then
					table.insert(neighbour_keys, { key = neighbour_key,  })
				end
			end
			if neighbour_key == left and GRID[left] ~= "|" then
				table.insert(neighbour_keys, { key = neighbour_key })
			end
			if neighbour_key == right and GRID[right] ~= "|" then
				table.insert(neighbour_keys, { key = neighbour_key })
			end
			if neighbour_key == down and GRID[down] ~= "-" then
				table.insert(neighbour_keys, { key = neighbour_key })
			end
		end
	end

	return neighbour_keys
end

-- add all edge pieces
local queue = {}
for k in pairs(GRID) do
	local x, y = unkey(k)
	for _, kk in ipairs({ key(x, y - 1), key(x, y + 1), key(x - 1, y), key(x + 1, y) }) do
		if not GRID[kk] and not LOOP[k] then
			table.insert(queue, { key = k })
			goto continue
		end
	end
	::continue::
end

local seen2 = {}
while #queue > 0 do
	local item = table.remove(queue, 1)
	local cur = item.key
	seen2[cur] = true
	if not LOOP[cur] then
		CACHE[cur] = true
	end
	for _, kk in ipairs(p2_adj(cur)) do
		if not seen2[kk.key] then
			table.insert(queue, kk)
			seen2[kk.key] = true
		end
	end
end

local p2 = 0
for k in pairs(GRID) do
	if not LOOP[k] and not CACHE[k] then
		p2 = p2 + 1
	end
end
print("p2", p2)
printgrid()
