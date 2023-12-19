local Heap = {}

function Heap:new()
	local o = {}
	self.__index = self
	setmetatable(o, self)
	return o
end

function Heap:bubbleup(pos)
	while pos > 1 do
		local parent = math.floor(pos / 2)
		if not (self[pos].score < self[parent].score) then
			break
		end
		self[parent], self[pos] = self[pos], self[parent]
		pos = parent
	end
end

function Heap:sink(pos)
	local last = #self
	while true do
		local min, child = pos, pos * 2
		for c = child, child + 1 do
			if c <= last and self[c].score < self[min].score then
				min = c
			end
		end

		if min == pos then
			break
		end
		self[pos], self[min] = self[min], self[pos]
		pos = min
	end
end

function Heap:insert(value)
	local pos = #self + 1
	self[pos] = value
	self:bubbleup(pos)
end

function Heap:remove(pos)
	local last = #self
	if pos == last then
		local v = self[last]
		self[last] = nil
		return v
	end

	local v = self[pos]
	self[pos], self[last] = self[last], self[pos]
	self[last] = nil
	self:bubbleup(pos)
	self:sink(pos)
	return v
end

local CHAR_TO_DIR = { L = { -1, 0 }, U = { 0, -1 }, R = { 1, 0 }, D = { 0, 1 } }
local CHAR_TO_SYMBOL = { L = "<", U = "^", R = ">", D = "v" }
local CORNERS = {
	[">^"] = "J",
	["^>"] = "F",
	[">v"] = "7",
	["v>"] = "L",
	["v<"] = "J",
	["<v"] = "F",
	["<^"] = "L",
	["^<"] = "7",
}

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

	local perimeter, rows, loop = 0, {}, {}

	do
		local x, y = 1, 1
		for _, line in ipairs(lines) do
			local char, steps = parse_line(line)
			steps = tonumber(steps)
			local dir = CHAR_TO_DIR[char]

			perimeter = perimeter + steps

			-- We compress horizontal steps. If steps = 1000 then we only insert two steps,
			-- where the first covers 999 distance and the second 1. That way we still
			-- get proper corners for replacing symbols later. We don't compress vertical
			-- steps so everything ends up in the correct row.
			local compressed = {}
			if (char == "L" or char == "R") and steps > 1 then
				compressed = { steps - 1, 1 }
			else
				for _ = 1, steps do
					table.insert(compressed, 1)
				end
			end

			for _, step in ipairs(compressed) do
				local x2, y2 = x + dir[1] * step, y + dir[2] * step
				if not rows[y2] then
					rows[y2] = Heap:new()
				end
				local point = { { x + dir[1], x2 }, CHAR_TO_SYMBOL[char] }
				rows[y2]:insert { score = point[1][1], point = point }
				table.insert(loop, point)
				x, y = x2, y2
			end
		end
	end

	-- Go through the loop once more and replace corners with
	-- connector symbols, which are used for the scanlines function
	-- later.
	do
		for i, p in ipairs(loop) do
			local prev = loop[(((i - 1) - 1) % #loop) + 1]
			local corner = prev[2] .. p[2]
			if CORNERS[corner] then
				prev[2] = CORNERS[corner]
			end
		end
	end

	-- We no longer need the heap, only the raw data in its
	-- sorted form. So get the values out of each heap (~ row)
	for y, row in pairs(rows) do
		local points = {}
		while #row > 0 do
			table.insert(points, row:remove(1).point)
		end
		rows[y] = points
	end

	-- Insert "." tiles between non-adjacent cells. Each such
	-- tile will have the distance it covers as a value.
	for y, row in pairs(rows) do
		local r2 = { table.remove(row, 1) }
		for _, point in ipairs(row) do
			local x_range = point[1]
			local start = math.min(x_range[1], x_range[2])

			local previous_x_range = r2[#r2][1]
			local previous_end =
				math.max(previous_x_range[1], previous_x_range[2])

			if start - previous_end == 1 then
				table.insert(r2, point)
			else
				table.insert(r2, { previous_end + 1, ".", start - 1 })
				table.insert(r2, point)
			end
		end
		rows[y] = r2
	end

	return { rows, perimeter }
end

local CONNECTOR_TO_INT = { L = 1, J = 1, ["7"] = -1, F = -1 }
local function scanline(row)
	local inside, last_wall, score = false, nil, 0

	for _, cell in ipairs(row) do
		local tile, is_dot = cell[2], cell[2] == "."
		if tile == ">" or tile == "<" or (is_dot and not inside) then
			goto continue
		elseif tile == "v" or tile == "^" then
			inside = not inside
		elseif is_dot and inside then
			score = score + (cell[3] - cell[1] + 1)
		elseif
			last_wall
			and CONNECTOR_TO_INT[tile] + CONNECTOR_TO_INT[last_wall] == 0
		then
			-- The reason for converting connectors to int is that we only flip
			-- inside/outside when we encounter something like:
			-- L___________
			--             7
			-- I'm using underscore to make it clearer that the L and 7 point in
			-- opposite directions. Hence we give up symbols 1 and down symbols -1
			-- so they cancel each other out.
			inside = not inside
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

for _, data in ipairs { make_grid(input), make_grid(input, parse_lines_p2) } do
	local grid, area = data[1], data[2]
	for _, row in pairs(grid) do
		area = area + scanline(row)
	end
	print(area)
end
