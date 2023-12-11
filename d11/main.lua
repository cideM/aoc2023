local GRID, GALAXIES = {}, {}
do
	-- Parse the input and insert markers for expanded rows
	for line in io.lines() do
		local row = {}
		for c in line:gmatch(".") do
			table.insert(row, c)
			if c == "#" then
				table.insert(GALAXIES, { #row, #GRID + 1 })
			end
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

-- For each pair walk left -> right and top -> bottom and
-- add 1 for each normal step and 2 or 1000000 for each
-- expanded row/column
local p1, p2 = 0, 0
for i, galaxy in ipairs(GALAXIES) do
	for _, other in ipairs({ table.unpack(GALAXIES, i + 1) }) do
		for x = math.min(galaxy[1], other[1]) + 1, math.max(galaxy[1], other[1]) do
			p1 = p1 + (GRID[1][x] == "x" and 2 or 1)
			p2 = p2 + (GRID[1][x] == "x" and 1000000 or 1)
		end
		for y = math.min(galaxy[2], other[2]) + 1, math.max(galaxy[2], other[2]) do
			p1 = p1 + (GRID[y][1] == "x" and 2 or 1)
			p2 = p2 + (GRID[y][1] == "x" and 1000000 or 1)
		end
	end
end
print(p1, p2)
