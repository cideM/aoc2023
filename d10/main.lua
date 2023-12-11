local function key(x, y)
	return string.format("%d;%d", x, y)
end

local function unkey(s)
	local x, y = s:match("(%d+);(%d+)")
	return tonumber(x), tonumber(y)
end

-- 1. Parse the input and build the grid
local S, GRID = nil, {}
do
	local y = 1
	for line in io.lines() do
		local x = 1
		for c in line:gmatch(".") do
			-- stylua: ignore
			if c == "S" then S = key(x, y) end
			GRID[key(x, y)], x = c, x + 1
		end
		y = y + 1
	end
end
assert(S, "S wasn't found")

-- 2. Replace S with a pipe using a map of patterns (~ regular expressions)
--    to the actual value of S. The patterns are left, up, right, down
do
	-- stylua: ignore
	local S_to_pipe = {["^%-..|$"] = "7", ["^..%-J$"] = "F", ["^%-|..$"] = "J",
		["^.77.$"] = "L", ["^F7..$"] = "J", ["^.7.|$"] = "F", ["^.7.J$"] = "F",
		["^%-F..$"] = "J", ["^L.J.$"] = "-", ["^L7..$"] = "J", ["^%-.7.$"] = "-",
		["^..J|$"] = "F", ["^.|.|$"] = "|", ["^..7J$"] = "F", ["^%-..J$"] = "7",
		["^.|.J$"] = "|", ["^.|.L$"] = "|", ["^.J.|$"] = "F", ["^.|7.$"] = "L",
		["^.J.L$"] = "F", ["^.7.L$"] = "F", ["^.|%-.$"] = "L", ["^L..|$"] = "7",
		["^.7%-.$"] = "L", ["^.F%-.$"] = "L", ["^F..L$"] = "7", ["^.|J.$"] = "L",
		["^..JL$"] = "F", ["^FF..$"] = "J", ["^..%-|$"] = "F", ["^L|..$"] = "J",
		["^L..L$"] = "7", ["^F.J.$"] = "-", ["^F.7.$"] = "-", ["^LF..$"] = "J",
		["^..%-L$"] = "F", ["^F|..$"] = "J", ["^.FJ.$"] = "L", ["^.7J.$"] = "L",
		["^F..J$"] = "7", ["^%-7..$"] = "J", ["^..JJ$"] = "F", ["^.J.J$"] = "F",
		["^L.7.$"] = "-", ["^F..|$"] = "7", ["^..7|$"] = "F", ["^%-..L$"] = "7",
		["^F.%-.$"] = "-", ["^%-.J.$"] = "-", ["^L..J$"] = "7", ["^L.%-.$"] = "-",
		["^.F7.$"] = "L", ["^%-.%-.$"] = "-", ["^..7L$"] = "F"}

	local x, y = unkey(S)
	-- Convert the left, up, right, down pipes into a single
	-- string that we pattern match against.
	local adjacent = table.concat({
		GRID[key(x - 1, y)] or "?",
		GRID[key(x, y - 1)] or "?",
		GRID[key(x + 1, y)] or "?",
		GRID[key(x, y + 1)] or "?",
	})
	for k, v in pairs(S_to_pipe) do
		if adjacent:match(k) then
			GRID[S] = v
		end
	end
end
assert(GRID[S] ~= "S", "S wasn't replaced")

local function adjacent(k)
	-- Convert each pipe into the vectors that convert the current
	-- position into the two possible neighbours.
	-- stylua: ignore
	local m = {["|"] = {{ 0, 1 }, { 0,-1 }}, ["F"] = {{ 0, 1 }, { 1, 0 }},
		       ["J"] = {{ 0,-1 }, {-1, 0 }}, ["-"] = {{-1, 0 }, { 1, 0 }},
		       ["7"] = {{-1, 0 }, { 0, 1 }}, ["L"] = {{ 0,-1 }, { 1, 0 }}}

	local out = {}
	local x, y = unkey(k)
	for _, vector in ipairs(m[GRID[k]]) do
		local neighbour = GRID[key(x + vector[1], y + vector[2])]
		if neighbour and neighbour ~= "." then
			table.insert(out, key(x + vector[1], y + vector[2]))
		end
	end
	assert(#out == 2, "should have 2 neighbours: ", k)
	return out
end

-- Calculate the distance from S for each pipe in the loop. The maximum number
-- is the solution to part 1. But while doing this we'll also keep track of
-- some data for part 2:
-- * Find the top edge. We'll then start walking the loop from that edge in a
--   fixed direction so we can be sure that we're walking clockwise.
-- * Track the loop length and which grid coordinates are loop tiles
local TOP_EDGE, LOOP_LEN, LOOP = key(math.maxinteger, math.maxinteger), 0, {}
do
	local distances, queue, max = { [S] = 0 }, { S }, math.mininteger
	while #queue > 0 do
		local cur = table.remove(queue, 1)
		LOOP[cur] = true
		LOOP_LEN = LOOP_LEN + 1
		for _, other in ipairs(adjacent(cur)) do
			local _, y = unkey(other)
			local _, top_y = unkey(TOP_EDGE)
			if y < top_y then
				TOP_EDGE = other
			end

			if not distances[other] then
				table.insert(queue, other)
				distances[other] = distances[cur] + 1
				max = math.max(max, distances[other])
			end
		end
	end
	print(max)
end

local function rotate_left(vec2)
	local x, y = table.unpack(vec2)
	return { y, -1 * x }
end

local function rotate_right(vec2)
	local x, y = table.unpack(vec2)
	return { -1 * y, x }
end

-- stylua: ignore
local direction_changes = {["J1,0"] = rotate_left, ["J0,1"] = rotate_right,
	["71,0"] = rotate_right, ["70,-1"] = rotate_left, ["F-1,0"] = rotate_left,
	["F0,-1"] = rotate_right, ["L-1,0"] = rotate_right, ["L0,1"] = rotate_left}

-- The remaining code walks the loop clockwise. At each step we look to our
-- right (towards the enclosure) and keep track of the tiles on our right.
-- Why plural? Because at each step we possibly change direction. So we
-- look to our right before changing direction, and after changing direction
-- but *before* making the next step. If only look to your right before or
-- after you will miss some tiles.
-- Doing this gives us a list of tiles that are immediately on our right hand
-- side. We can then use a flood fill algorithm to recursively mark these
-- tiles on our right as enclosed. Once we've visited every node once
-- (recursively!) we've arrived at the total number of enclosed tiles.

local position, vector, to_my_right, steps = TOP_EDGE, { 1, 0 }, {}, 0
while steps <= LOOP_LEN do
	local fn = direction_changes[GRID[position] .. table.concat(vector, ",")]
	local before, after = vector, fn and fn(vector) or vector

	local x, y = unkey(position)
	local dx, dy = table.unpack(rotate_right(before))
	to_my_right[key(x + dx, y + dy)] = true

	local dx2, dy2 = table.unpack(rotate_right(after))
	to_my_right[key(x + dx2, y + dy2)] = true

	position, vector, steps = key(x + after[1], y + after[2]), after, steps + 1
end

local queue, seen, p2 = {}, {}, 0
for k in pairs(to_my_right) do
	table.insert(queue, k)
end

while #queue > 0 do
	local cur = table.remove(queue, 1)
	if LOOP[cur] or seen[cur] then
		goto continue
	end

	p2, seen[cur] = p2 + 1, true
	local x, y = unkey(cur)
	for _, vec in ipairs({ { -1, 0 }, { 0, -1 }, { 1, 0 }, { 0, 1 } }) do
		local k = key(x + vec[1], y + vec[2])
		if not LOOP[k] and not seen[k] then
			table.insert(queue, k)
		end
	end
	::continue::
end
print(p2)
