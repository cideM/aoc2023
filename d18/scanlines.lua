local input = {}
for line in io.lines() do
	table.insert(input, line)
end

local function make_grid(lines, parse_line)
	parse_line = parse_line
		or function(s)
			local dir, steps = s:match "(%a) (%d+)"
			return dir, steps
		end

	local perimeter = 0
	local rows = {}

	print "grid"
	do
		local directions =
			{ L = { -1, 0 }, U = { 0, -1 }, R = { 1, 0 }, D = { 0, 1 } }
		local symbols = { L = "-", U = "|", R = "-", D = "|" }
		local corner_symbols = {
			RU = "J",
			UR = "F",
			RD = "7",
			DR = "L",
			DL = "J",
			LD = "F",
			LU = "L",
			UL = "7",
		}

		local x, y = 1, 1
		local previous_dir_letter, previous_key = nil, nil
		local first_dir_letter_after_start = nil
		for i, line in ipairs(lines) do
			print(i .. "/" .. #lines)
			local current_dir_letter, steps = parse_line(line)
			steps = tonumber(steps)
			perimeter = perimeter + steps
			local direction = directions[current_dir_letter]
			for _ = 1, steps do
				if
					previous_dir_letter
					and previous_key
					and previous_dir_letter ~= current_dir_letter
				then
					rows[previous_key[2]][previous_key[1]] =
						corner_symbols[previous_dir_letter .. current_dir_letter]
				end

				x, y = x + direction[1], y + direction[2]
				if not rows[y] then
					rows[y] = {}
				end
				rows[y][x] = symbols[current_dir_letter]

				if not first_dir_letter_after_start then
					first_dir_letter_after_start = current_dir_letter
				end

				-- We've reached the first node again and need to link it to
				-- the next.
				if x == 1 and y == 1 and first_dir_letter_after_start then
					rows[y][x] =
						corner_symbols[current_dir_letter .. first_dir_letter_after_start]
				end

				previous_dir_letter, previous_key = current_dir_letter, { x, y }
			end
		end
	end

	print "sort rows by x"
	for y, r in pairs(rows) do
		local xs = {}
		for x in pairs(r) do
			table.insert(xs, x)
		end
		table.sort(xs, function(a, b)
			return a < b
		end)
		local r2 = {}
		for _, x in ipairs(xs) do
			table.insert(r2, { x, r[x] })
		end
		rows[y] = r2
	end

	print "insert ."
	for y, r in pairs(rows) do
		local r2 = { table.remove(r, 1) }
		for _, v in ipairs(r) do
			local last_x, x = r2[#r2][1], v[1]
			if x - last_x == 1 then
				table.insert(r2, v)
			else
				table.insert(r2, { last_x + 1, ".", x - (last_x + 1) })
				table.insert(r2, v)
			end
		end
		rows[y] = r2
	end

	return { rows, perimeter }
end

local function scanline(row)
	local inside, last_wall, score = false, nil, 0
	-- up: 1; down: -1
	local up_or_down = { L = 1, J = 1, ["7"] = -1, F = -1 }
	for _, cell in ipairs(row) do
		local tile = cell[2]
		-- print(x, tile, inside)
		if tile == "-" then
			goto continue
		elseif tile == "." and not inside then
			last_wall = nil
			goto continue
		elseif tile == "|" then
			inside = not inside
		elseif tile == "." and inside then
			score = score + cell[3]
			last_wall = nil
		elseif last_wall and up_or_down[tile] + up_or_down[last_wall] == 0 then
			inside = not inside
			last_wall = tile
		elseif tile == "F" or tile == "L" or tile == "J" or tile == "7" then
			last_wall = tile
		end
		::continue::
	end
	return score
end

local function parse_lines_p2(s)
	local distance, direction = s:match "%a %d+ %(#(%x%x%x%x%x)(%x)%)"
	local dirs = { ["0"] = "R", ["1"] = "D", ["2"] = "L", ["3"] = "U" }
	return dirs[direction], tonumber("0x" .. distance)
end

for _, data in ipairs {
	make_grid(input),
	make_grid(input, parse_lines_p2),
} do
	local grid, area = data[1], data[2]

	print "scan"
	for _, row in pairs(grid) do
		local enclosed = scanline(row)
		area = area + enclosed
	end

	print(area)
end

-- printgrid(GRID, MIN_X, MAX_X, MIN_Y, MAX_Y)
