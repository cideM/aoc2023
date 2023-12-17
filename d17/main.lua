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
		if not (self[pos].f_score < self[parent].f_score) then
			break
		end
		self[parent], self[pos] = self[pos], self[parent]
		pos = parent
	end
end

function Heap:sink(pos)
	local last = #self
	while true do
		local min = pos
		local child = pos * 2
		for c = child, child + 1 do
			if c <= last and self[c].f_score < self[min].f_score then
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

function Heap:has(value)
	for _, v in ipairs(self) do
		if v == value then
			return true
		end
	end
	return false
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
	min_run = min_run or 0
	max_run = max_run or 3
	local seen, Q = {}, Heap:new()
	Q:insert({ key = "1;1;1;0;0", f_score = 0 })
	Q:insert({ key = "1;1;0;1;0", f_score = 0 }) -- x y dx dy cost straight_line_run
	while #Q > 0 do
		local cur = Q:remove(1)
		local x, y, dx, dy, run = cur.key:match("(%-?%d+);(%-?%d+);(%-?%d+);(%-?%d+);(%-?%d+)")
		x, y, dx, dy, run = tonumber(x), tonumber(y), tonumber(dx), tonumber(dy), tonumber(run)
		local cost = cur.f_score

		if x == max_x and y == max_y and run >= min_run then
			return cost
		end

		if seen[cur.key] then
			goto continue
		end
		seen[cur.key] = true

		if run < max_run then
			local x2, y2 = x + dx, y + dy
			if x2 >= 1 and x2 <= max_x and y2 >= 1 and y2 <= max_y then
				Q:insert({
					key = table.concat({ x2, y2, dx, dy, run + 1 }, ";"),
					f_score = cost + G[y2][x2],
				})
			end

			if run < min_run then
				goto continue
			end
		end

		for _, dirs in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
			local dx2, dy2 = dirs[1], dirs[2]
			local x2, y2 = x + dx2, y + dy2
			if
				dx + dx2 ~= 0
				and dy + dy2 ~= 0
				and dx2 ~= dx
				and dy2 ~= dy
				and x2 >= 1
				and x2 <= max_x
				and y2 >= 1
				and y2 <= max_y
			then
				Q:insert({
					key = table.concat({ x2, y2, dx2, dy2, 1 }, ";"),
					f_score = cost + G[y2][x2],
				})
			end
		end

		::continue::
	end
end

print(solve())
print(solve(4, 10))
