local GRID, COLS, S = {}, 0, { -1, -1 }

for line in io.lines() do
	local row = {}
	for c in line:gmatch "." do
		table.insert(row, c)
		if c == "S" then
			S = { #row, #GRID + 1 }
		end
	end
	COLS = 0 and #row or COLS
	table.insert(GRID, row)
end

local function key(t)
	local x, y = table.unpack(t)
	return x .. ";" .. y
end

local function wrap(i, t)
	return ((i - 1) % t) + 1
end

local function get_tile(x, y)
	-- return (GRID[y] or {})[x]
	return GRID[wrap(y, COLS)][wrap(x, COLS)]
end

local queue = { S }
local visited = {}
local dists = { [key(S)] = 0 }
while #queue > 0 do
	local cur = table.remove(queue, 1)
	if visited[key(cur)] then
		goto continue
	end

	visited[key(cur)] = true

	local cur_dist = dists[key(cur)]
	for _, dxdy in ipairs { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } } do
		local x2, y2 = cur[1] + dxdy[1], cur[2] + dxdy[2]
		if
			x2 >= 1
			and x2 <= 131
			and y2 >= 1
			and y2 <= 131
			and not visited[key { x2, y2 }]
			and get_tile(x2, y2) == "."
		then
			dists[key { x2, y2 }] = cur_dist + 1
			table.insert(queue, { x2, y2 })
		end
	end

	::continue::
end

local p1 = 0
for k in pairs(visited) do
	if dists[k] <= 64 and dists[k] % 2 == 0 then
		p1 = p1 + 1
	end
end
print("p1", p1)

local even_corners = 0
for k in pairs(visited) do
	if dists[k] > 65 and dists[k] % 2 == 0 then
		even_corners = even_corners + 1
	end
end

local odd_corners = 0
for k in pairs(visited) do
	if dists[k] > 65 and dists[k] % 2 == 1 then
		odd_corners = odd_corners + 1
	end
end

local odd_all = 0
for k in pairs(visited) do
	if dists[k] % 2 == 1 then
		odd_all = odd_all + 1
	end
end

local even_all = 0
for k in pairs(visited) do
	if dists[k] % 2 == 0 then
		even_all = even_all + 1
	end
end

local n = math.ceil((26501365 - (131 / 2)) / 131)
local even = n * n
local odd = (n + 1) * (n + 1)

print(
	odd * odd_all
		+ even * even_all
		- ((n + 1) * odd_corners)
		+ (n * even_corners)
)
