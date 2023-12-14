local G = {}
for line in io.lines() do
	local row = {}
	for c in line:gmatch(".") do
		table.insert(row, c)
	end
	table.insert(G, row)
end

local function transpose(t)
	local t2 = {}
	for _, row in ipairs(t) do
		for x, cell in ipairs(row) do
			if not t2[x] then
				t2[x] = {}
			end
			table.insert(t2[x], 1, cell)
		end
	end
	return t2
end

local function grid_to_string(g)
	local buf = {}
	for _, r in ipairs(g) do
		table.insert(buf, table.concat(r))
	end
	return table.concat(buf, "\n")
end

local function score(g)
	local v = 0
	for y, row in ipairs(g) do
		for _, cell in ipairs(row) do
			if cell == "O" then
				v = v + (#g - (y - 1))
			end
		end
	end
	return v
end

local function cycle(grid, tilts)
	tilts = tilts or 4
	local g, dx, dy = grid, 0, -1
	for _ = 1, tilts do
		for yy, row in ipairs(g) do
			for xx in ipairs(row) do
				if g[yy][xx] == "O" then
					local y, x = yy, xx
					local y2, x2 = y + dy, x + dx
					while (g[y2] or {})[x2] == "." do
						g[y][x], g[y2][x2] = ".", "O"
						y, y2, x, x2 = y2, y2 + dy, x2, x + dx
					end
				end
			end
		end
		g = transpose(g)
	end
	for _ = 1, 4 - tilts do
		g = transpose(g) -- restore original orientation for score
	end
	return g, score(g)
end

local _, p1 = cycle(G, 1)
print(p1)

local seen, i, g = {}, 1, G
while true do
	g, _ = cycle(g)
	if seen[grid_to_string(g)] then
		break
	else
		seen[grid_to_string(g)] = i
	end
	i = i + 1
end

local cycle_length = i - seen[grid_to_string(g)]
for _ = 1, (1000000000 - i) % cycle_length do
	g, _ = cycle(g)
end
print(score(g))
