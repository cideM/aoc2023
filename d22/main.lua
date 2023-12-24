local function intersection(r1, r2)
	local intersected = {
		math.max(r1[1], r2[1]),
		math.min(r1[2], r2[2]),
	}

	if intersected[1] > intersected[2] then
		return {}, { r1 }
	end

	if intersected[1] <= intersected[2] then
		local rest = {}
		if r1[1] <= intersected[1] - 1 then
			table.insert(rest, { r1[1], intersected[1] - 1 })
		end
		if r1[2] >= intersected[2] + 1 then
			table.insert(rest, { intersected[2] + 1, r1[2] })
		end
		return intersected, rest
	end

	return {}, { r1 }
end

local Block = {}

function Block:new(t)
	t = t or {}
	self.__index = self
	setmetatable(t, self)
	self.__tostring = function(b)
		local xr, yr, zr = table.unpack(b.coords)
		return "x["
			.. table.concat(xr, "..")
			.. "] y["
			.. table.concat(yr, "..")
			.. "] z["
			.. table.concat(zr, "..")
			.. "]"
	end
	return t
end

function Block:blocked_by(block2)
	local zr1, zr2 = self.coords[3], block2.coords[3]
	local blocked_vertically = zr1[1] - zr2[2] == 1
	if not blocked_vertically then
		return false
	end

	local xr1, yr1 = table.unpack(self.coords)
	local xr2, yr2 = table.unpack(block2.coords)

	local x_overlap = intersection(xr1, xr2)
	if #x_overlap == 0 then
		return false
	end

	local y_overlap = intersection(yr1, yr2)
	local xy_overlap = #x_overlap > 0 and #y_overlap > 0

	return blocked_vertically and xy_overlap
end

local function fall(block, lower)
	local can_move = function()
		if block.coords[3][1] <= 1 then
			return false
		end

		for _, b in ipairs(lower) do
			if block:blocked_by(b) then
				return false
			end
		end
		return true
	end

	while can_move() do
		block.coords[3][1], block.coords[3][2] =
			block.coords[3][1] - 1, block.coords[3][2] - 1
	end
end

local blocks = {}

for line in io.lines() do
	local x1, y1, z1, x2, y2, z2 =
		line:match "(%d+),(%d+),(%d+)~(%d+),(%d+),(%d+)"
	x1, y1, z1, x2, y2, z2 =
		tonumber(x1),
		tonumber(y1),
		tonumber(z1),
		tonumber(x2),
		tonumber(y2),
		tonumber(z2)
	local xr = { x1, x2 }
	local yr = { y1, y2 }
	local zr = { z1, z2 }
	table.insert(blocks, Block:new { coords = { xr, yr, zr } })
end

table.sort(blocks, function(a, b)
	return a.coords[3][2] < b.coords[3][2]
end)

for i, b in ipairs(blocks) do
	fall(b, { table.unpack(blocks, 1, i - 1) })
end

table.sort(blocks, function(a, b)
	return a.coords[3][2] < b.coords[3][2]
end)

local graph = {}
for i = #blocks, 1, -1 do
	local a = blocks[i]

	local key = tostring(a)
	graph[key] = graph[key] or {}
	graph[key].supports = graph[key].supports or {}
	graph[key].supported_by = graph[key].supported_by or {}

	for _, b in ipairs { table.unpack(blocks, 1, i - 1) } do
		local other_key = tostring(b)
		graph[other_key] = graph[other_key] or {}
		graph[other_key].supports = graph[other_key].supports or {}
		graph[other_key].supported_by = graph[other_key].supported_by or {}

		if a:blocked_by(b) then
			table.insert(graph[other_key].supports, key)
			table.insert(graph[key].supported_by, tostring(b))
		end
	end
end

-- For part 1 we go through each node and check if
-- * it doesn't support anything
-- * everything it supports is also supported by something else
local p1 = 0
for _, t in pairs(graph) do
	if #t.supports == 0 then
		p1 = p1 + 1
		goto continue
	end

	local all_redundant_supports = true
	for _, other in ipairs(t.supports) do
		if #graph[other].supported_by == 1 then
			all_redundant_supports = false
		end
	end
	if all_redundant_supports then
		p1 = p1 + 1
	end
	::continue::
end
print(p1)

local function remove_node(g, n)
	g[n] = nil
	for k, t in pairs(g) do
		for i, nn in ipairs(t.supports) do
			if nn == n then
				table.remove(g[k].supports, i)
			end
		end
		for i, nn in ipairs(t.supported_by) do
			if nn == n then
				table.remove(g[k].supported_by, i)
			end
		end
	end
end

-- For part 2 we go through the graph and remove each node and then check
-- how many of the other nodes it supports are now left dangling in the
-- air. Those we then also remove from the graph, recursively (but here
-- implemented with a queue).
local p2 = 0
for k in pairs(graph) do
	local g = {}
	for kk, v in pairs(graph) do
		g[kk] = {
			supports = {},
			supported_by = {},
		}
		table.move(v.supports, 1, #v.supports, 1, g[kk].supports)
		table.move(v.supported_by, 1, #v.supported_by, 1, g[kk].supported_by)
	end

	local q = { k }
	while #q > 0 do
		local cur = table.remove(q, 1)
		local supports = g[cur].supports
		remove_node(g, cur)
		for _, other in ipairs(supports) do
			if #g[other].supported_by == 0 then
				p2 = p2 + 1
				table.insert(q, other)
			end
		end
	end
end
print(p2)
