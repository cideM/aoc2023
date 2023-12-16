local G = {}
for line in io.lines() do
	local row = {}
	for c in line:gmatch(".") do
		table.insert(row, c)
	end
	table.insert(G, row)
end

local max_x, max_y = #G[1], #G

local function simulate(Q)
	Q = Q or {}
	local seen, visited = {}, {}
	while #Q > 0 do
		local cur = table.remove(Q, 1)
		local x, y, dx, dy = cur[1], cur[2], cur[3], cur[4]

		local key = table.concat({ x, y, dx, dy }, ";")
		if seen[key] or x < 1 or x > max_x or y < 1 or y > max_y then
			goto continue
		end

		visited[x .. ";" .. y] = true
		seen[key] = true

		local tile = G[y][x]

		if tile == "." then
			table.insert(Q, { x + dx, y + dy, dx, dy })
		elseif tile == "-" and (dx == 1 or dx == -1) then
			table.insert(Q, { x + dx, y + dy, dx, dy })
		elseif tile == "-" and (dy == 1 or dy == -1) then
			table.insert(Q, { x + 1, y, 1, 0 })
			table.insert(Q, { x - 1, y, -1, 0 })
		elseif tile == "|" and (dy == 1 or dy == -1) then
			table.insert(Q, { x + dx, y + dy, dx, dy })
		elseif tile == "|" and (dx == 1 or dx == -1) then
			table.insert(Q, { x, y + 1, 0, 1 })
			table.insert(Q, { x, y - 1, 0, -1 })
		elseif tile == "/" then
			if dx == 1 then -- right -> up
				table.insert(Q, { x, y - 1, 0, -1 })
			elseif dx == -1 then -- left -> down
				table.insert(Q, { x, y + 1, 0, 1 })
			elseif dy == 1 then -- down -> left
				table.insert(Q, { x - 1, y, -1, 0 })
			elseif dy == -1 then -- up -> right
				table.insert(Q, { x + 1, y, 1, 0 })
			end
		elseif tile == [[\]] then
			if dx == 1 then -- right -> down
				table.insert(Q, { x, y + 1, 0, 1 })
			elseif dx == -1 then -- left -> up
				table.insert(Q, { x, y - 1, 0, -1 })
			elseif dy == 1 then -- down -> right
				table.insert(Q, { x + 1, y, 1, 0 })
			elseif dy == -1 then -- up -> left
				table.insert(Q, { x - 1, y, -1, 0 })
			end
		else
			assert(false, "unknown tile and dx dy")
		end
		::continue::
	end
	local score = 0
	for _ in pairs(visited) do
		score = score + 1
	end
	return score
end

local p2 = 0
for x = 1, max_x do
	p2 = math.max(p2, simulate({ { x, 1, 0, 1 } }))
	p2 = math.max(p2, simulate({ { x, max_y, 0, -1 } }))
end
for y = 1, max_y do
	p2 = math.max(p2, simulate({ { 1, y, 1, 0 } }))
	p2 = math.max(p2, simulate({ { max_x, y, -1, 0 } }))
end
print(simulate({ { 1, 1, 1, 0 } }), p2)
