local GRID = {}
do
	-- Parse the input and insert markers for expanded rows
	for line in io.lines() do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, c)
		end
		table.insert(GRID, row)
		if line:match("^%.+$") then
			for i in ipairs(row) do
				row[i] = "x"
			end
		end
	end

	-- Go through each column and insert markers for expanded columns
	for x = 1, #GRID[1] do
		local col = {}
		for y = 1, #GRID do
			table.insert(col, GRID[y][x])
		end
		if table.concat(col):match("^[%.x]+$") then
			for y = 1, #GRID do
				GRID[y][x] = "x"
			end
		end
	end
end

-- bfs calculates the distances between "start" and *all* other points
-- in the grid. It's inefficient but you can get away with it here. It
-- doesn't store the distance as a number but as a list of steps. That way
-- it's easy to know how many markers were traveresed, so we can then
-- arbitrarily adjust the actual distance by giving the markers different
-- distances.
local function bfs(start) -- {x,y}
	local queue, distances = { start }, { [start[1] .. ";" .. start[2]] = {} }
	while #queue > 0 do
		local current = table.remove(queue, 1)
		local x, y = table.unpack(current)
		for _, vector in ipairs({ { -1, 0 }, { 0, -1 }, { 1, 0 }, { 0, 1 } }) do
			local dx, dy = table.unpack(vector)
			local x2, y2 = x + dx, y + dy
			local neighbour = (GRID[y2] or {})[x2]
			if neighbour and not distances[x2 .. ";" .. y2] then
				table.insert(queue, { x2, y2 })
				local path_until_here = distances[x .. ";" .. y]
				local copy = table.move(path_until_here, 1, #path_until_here, 1, {})
				table.insert(copy, neighbour)
				distances[x2 .. ";" .. y2] = copy
			end
		end
	end
	return distances
end

-- Find the locations of all galaxies
local galaxies = {}
for y, row in ipairs(GRID) do
	for x, col in ipairs(row) do
		if col == "#" then
			table.insert(galaxies, { x, y })
		end
	end
end

-- For each galaxy, calculate the paths to all other points.
-- Then, find just the paths to other galaxies and walk them again,
-- but this time counting "." as 1 and "x" (expansion marker) as either
-- 2 (part 1) or 1000000 (part 2).
local p1, p2 = 0, 0
for i, galaxy in ipairs(galaxies) do
	local current_distances = bfs(galaxy)
	for _, other in ipairs({ table.unpack(galaxies, i + 1) }) do
		for _, step in ipairs(current_distances[table.concat(other, ";")]) do
			p1 = p1 + (step == "x" and 2 or 1)
			p2 = p2 + (step == "x" and 1000000 or 1)
		end
	end
end
print(p1, p2)
