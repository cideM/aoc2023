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

local G = {}
for line in io.lines() do
	local row = {}
	for c in line:gmatch(".") do
		table.insert(row, tonumber(c))
	end
	table.insert(G, row)
end

local max_x, max_y = #G[1], #G

local function solve(min_run, max_run)
	min_run, max_run = min_run or 0, max_run or 3
	local seen, Q = {}, Heap:new()
	Q:insert({ data = { 1, 1, 1, 0, 0 }, score = 0 }) -- x y dx dy run cost
	Q:insert({ data = { 1, 1, 0, 1, 0 }, score = 0 })
	while #Q > 0 do
		local cur = Q:remove(1)
		local x, y, dx, dy, run = cur.data[1], cur.data[2], cur.data[3], cur.data[4], cur.data[5]

		if x == max_x and y == max_y and run >= min_run then
			return cur.score
		end

		if seen[table.concat(cur.data, ";")] then
			goto continue
		end
		seen[table.concat(cur.data, ";")] = true

		if run < max_run then
			local x2, y2 = x + dx, y + dy
			if (G[y2] or {})[x2] ~= nil then
				Q:insert({ data = { x2, y2, dx, dy, run + 1 }, score = cur.score + G[y2][x2] })
			end

			if run < min_run then
				goto continue
			end
		end

		for _, dirs in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
			local dx2, dy2 = dirs[1], dirs[2]
			local x2, y2 = x + dx2, y + dy2
			if dx + dx2 ~= 0 and dy + dy2 ~= 0 and dx2 ~= dx and dy2 ~= dy and (G[y2] or {})[x2] ~= nil then
				Q:insert({ data = { x2, y2, dx2, dy2, 1 }, score = cur.score + G[y2][x2] })
			end
		end

		::continue::
	end
end

print(solve())
print(solve(4, 10))
