local function key(x, y)
	return x .. ";" .. y
end

local Graph = {}

function Graph:new(o)
	o = o or {}
	self.__index = self
	setmetatable(o, self)
	return o
end

function Graph:get_edges(a)
	local edges = {}
	for other_node_key in pairs(self[a] or {}) do
		for weight in pairs(self[a][other_node_key]) do
			table.insert(edges, { key = other_node_key, weight = weight })
		end
	end
	return edges
end

function Graph:remove_node(a)
	self[a] = nil
	for k in pairs(self) do
		if self[k][a] then
			self[k][a] = nil
		end
	end
end

function Graph:add_edge(a, b, weight)
	if not self[a] then
		self[a] = {}
	end
	if not self[a][b] then
		self[a][b] = {}
	end
	self[a][b][weight] = true
end

function Graph:remove_edge(a, b, weight)
	self[a][b][weight] = nil
end

function Graph:longest(a, b, seen)
	seen = seen or {}
	if a == b then
		return { { a, 0 } }
	end

	local longest_dist, longest_path = 0, nil
	for _, edge in ipairs(self:get_edges(a)) do
		if not seen[edge.key] then
			local copy = {}
			for k, v in pairs(seen) do
				copy[k] = v
			end
			copy[edge.key] = true
			local path = { { a, edge.weight } }
			local next = self:longest(edge.key, b, copy)
			if next then
				local score = edge.weight
				for _, step in ipairs(next) do
					table.insert(path, step)
					score = score + step[2]
				end
				if score > longest_dist then
					longest_dist = score
					longest_path = path
				end
			end
		end
	end

	return longest_path
end

function Graph:compact()
	local queue = {}
	for n in pairs(self) do
		table.insert(queue, n)
	end

	while #queue > 0 do
		local n = table.remove(queue, 1)
		if not self[n] then
			goto continue
		end

		local edges = self:get_edges(n)

		if #edges == 2 then
			local a, b = table.unpack(edges)
			local new_weight = math.max(a.weight, b.weight)
			if self[a.key] and self[a.key][n] then
				self:remove_edge(a.key, n, a.weight)
			end
			if self[b.key] and self[b.key][n] then
				self:remove_edge(b.key, n, b.weight)
			end
			self:add_edge(a.key, b.key, new_weight + 1)
			self:add_edge(b.key, a.key, new_weight + 1)
			table.insert(queue, 1, a.key)
			table.insert(queue, 1, b.key)
			self:remove_node(n)
		end
		::continue::
	end
end

local function build_graph(g, next_tiles)
	local graph = Graph:new()
	for y, row in ipairs(g) do
		for x, cell in ipairs(row) do
			if cell ~= "#" then
				for _, dxdy in ipairs(next_tiles[cell]) do
					local x2, y2 = x + dxdy[1], y + dxdy[2]
					local tile = (g[y2] or {})[x2]
					if tile and tile ~= "#" then
						graph:add_edge(key(x, y), key(x2, y2), 1)
					end
				end
			end
		end
	end
	return graph
end

local function distance(path)
	local dist = 0
	for _, step in ipairs(path) do
		dist = dist + step[2]
	end
	return dist
end

local GRID, START, GOAL = {}, {}, {}
for line in io.lines() do
	local row = {}
	for c in line:gmatch "." do
		table.insert(row, c)
		if #GRID == 0 and c == "." then
			START = { #row, 1 }
		end
	end
	table.insert(GRID, row)
end
for x, c in ipairs(GRID[#GRID]) do
	if c == "." then
		GOAL = { x, #GRID }
	end
end

local next_tiles_p1 = {
	["."] = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } },
	[">"] = { { 1, 0 } },
	["v"] = { { 0, 1 } },
	["<"] = { { -1, 0 } },
	["^"] = { { 0, -1 } },
}

local next_tiles_p2 = {
	["."] = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } },
	[">"] = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } },
	["v"] = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } },
	["<"] = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } },
	["^"] = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } },
}

local key_start, key_goal = key(table.unpack(START)), key(table.unpack(GOAL))
for _, tile_plan in ipairs { next_tiles_p1, next_tiles_p2 } do
	local graph = build_graph(GRID, tile_plan)
	graph:compact()
	print(distance(graph:longest(key_start, key_goal)))
end
