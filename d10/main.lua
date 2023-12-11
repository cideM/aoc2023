-- part 1 42m 34s 16ms
local GRID, LOOP, CACHE = {}, {}, {}

local function key(x, y)
	return string.format("%d;%d", x, y)
end

local function unkey(s)
	local x, y = s:match("(%d+);(%d+)")
	return tonumber(x), tonumber(y)
end

-- 1. Parse the input and build the grid
local S = nil
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

-- 2. Replace S with a pipe
do
	-- stylua: ignore
	local S_to_pipe = {["^%-..|$"] = "7", ["^..%-J$"] = "F", ["^%-|..$"] = "J",
		["^.77.$"] = "L", ["^F7..$"] = "J", ["^.7.|$"] = "F", ["^.7.J$"] = "F",
		["^%-F..$"] = "J", ["^L.J.$"] = "-", ["^L7..$"] = "J", ["^%-.7.$"] = "-",
		["^..J|$"] = "F", ["^.|.|$"] = "F", ["^..7J$"] = "F", ["^%-..J$"] = "7",
		["^.|.J$"] = "F", ["^.|.L$"] = "F", ["^.J.|$"] = "F", ["^.|7.$"] = "L",
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

-- Calculate the distance from S for each pipe in the loop
do
	local distances, queue, max = { [S] = 0 }, { S }, math.mininteger
	while #queue > 0 do
		local cur = table.remove(queue, 1)
		for _, other in ipairs(adjacent(cur)) do
			if not distances[other] then
				table.insert(queue, other)
				distances[other] =  distances[cur] + 1
				max = math.max(max, distances[other])
			end
		end
	end
	print("P1", max)
end

os.exit()

local loop_end = nil
local max = math.mininteger
for k, v in pairs(dists) do
	if v > max then
		max = v
		loop_end = k
	end
end

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

local steps, len, vec = {}, 0, { 0, 1 }
local min_x = math.maxinteger
for k in pairs(LOOP) do
	local x, y = unkey(k)
	if GRID[k] == "|" then
		if x < min_x then
			min_x = x
			steps = { k }
			vec = { 0, 1 }
		end
	end
	if GRID[k] == "F" then
		if x < min_x then
			min_x = x
			steps = { k }
			vec = { -1, 0 }
		end
	end
	if GRID[k] == "L" then
		if x < min_x then
			min_x = x
			steps = { k }
			vec = { 0, 1 }
		end
	end
	if GRID[k] == "J" then
		if x < min_x then
			min_x = x
			steps = { k }
			vec = { 0, 1 }
		end
	end
	len = len + 1
end

local function rotate_left(vec2)
	local x, y = table.unpack(vec2)
	return { y, -1 * x }
end

local function rotate_right(vec2)
	local x, y = table.unpack(vec2)
	return { -1 * y, x }
end

while #steps <= len do
	local cur = steps[#steps]
	local x, y = unkey(cur)
	local v = assert(GRID[cur], cur)
	local vecs = table.concat(vec, ",")
	local orig_vec = vec
	if v == "J" then
		if vecs == "1,0" then
			vec = rotate_left(vec)
		elseif vecs == "0,1" then
			vec = rotate_right(vec)
		end
	elseif v == "7" then
		if vecs == "1,0" then
			vec = rotate_right(vec)
		elseif vecs == "0,-1" then
			vec = rotate_left(vec)
		end
	elseif v == "F" then
		if vecs == "-1,0" then
			vec = rotate_left(vec)
		elseif vecs == "0,-1" then
			vec = rotate_right(vec)
		end
	elseif v == "L" then
		if vecs == "-1,0" then
			vec = rotate_right(vec)
		elseif vecs == "0,1" then
			vec = rotate_left(vec)
		end
	end
	LOOP[cur] = { orig_vec, vec }
	table.insert(steps, key(x + vec[1], y + vec[2]))
end

local Q, seen = {}, {}
for _, step in ipairs(steps) do
	local x, y = unkey(step)
	for _, v in ipairs(LOOP[step]) do
		local vec2 = rotate_left(v)
		local x2, y2 = x + vec2[1], y + vec2[2]
		local kk = key(x2, y2)
		if not LOOP[kk] and GRID[kk] and not seen[kk] then
			table.insert(Q, kk)
			seen[kk] = true
		end
	end
end

while #Q > 0 do
	local cur = table.remove(Q, 1)
	CACHE[cur] = true
	local x, y = unkey(cur)
	for _, vec2 in ipairs({ { -1, 0 }, { 0, -1 }, { 1, 0 }, { 0, 1 } }) do
		local x2, y2 = x + vec2[1], y + vec2[2]
		local kk = key(x2, y2)
		if not LOOP[kk] and not CACHE[kk] then
			table.insert(Q, kk)
		end
	end
end
local p2 = 0
for _ in pairs(CACHE) do
	p2 = p2 + 1
end
print("P2", p2)
