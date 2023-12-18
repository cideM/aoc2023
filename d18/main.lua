local input = {}
for line in io.lines() do
	table.insert(input, line)
end

local function run(parse_line)
	local LOOP = { { 1, 1 } }

	parse_line = parse_line
		or function(s)
			local dir, steps = s:match "(%a) (%d+)"
			return dir, steps
		end

	do
		local dirs =
			{ U = { 0, -1 }, D = { 0, 1 }, L = { -1, 0 }, R = { 1, 0 } }

		for _, line in ipairs(input) do
			local dir, steps = parse_line(line)
			for _ = 1, tonumber(steps) do
				local cur = LOOP[#LOOP]
				local x, y = cur[1], cur[2]
				local dx, dy = dirs[dir][1], dirs[dir][2]
				table.insert(LOOP, { x + dx, y + dy })
			end
		end
	end

	-- https://en.wikipedia.org/wiki/Shoelace_formula
	-- Using A = 0.5 * (yi + yi+1) * (xi + xi + 1) for i = [1..#LOOP)
	local area = 0
	for i = 1, #LOOP - 1 do
		local x1, y1 = LOOP[i][1], LOOP[i][2]
		local x2, y2 = LOOP[i + 1][1], LOOP[i + 1][2]
		area = area + (y1 + y2) * (x1 - x2)
	end
	area = math.abs(area) / 2

	-- https://en.wikipedia.org/wiki/Pick%27s_theorem
	-- A = area; i = enclosed; b = perimeter/boundary
	-- A = i + (b / 2) - 1
	-- A = i + (b / 2) - 1
	-- i = A - ((b / 2) - 1)
	-- i = A - (b / 2) + 1
	local i = area - (#LOOP / 2) + 1
	local all = i + #LOOP
	return math.floor(all)
end

print(run())
print(run(function(s)
	local distance, direction = s:match "%a %d+ %(#(%x%x%x%x%x)(%x)%)"
	local dirs = { ["0"] = "R", ["1"] = "D", ["2"] = "L", ["3"] = "U" }
	return dirs[direction], tonumber("0x" .. distance)
end))
