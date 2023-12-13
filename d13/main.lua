local G = { {} }
for line in io.lines() do
	if not line:match("[.#]") then
		table.insert(G, {})
	else
		local row = {}
		for c in line:gmatch("[.#]") do
			table.insert(row, c)
		end
		table.insert(G[#G], row)
	end
end

local function transpose(t)
	local t2 = {}
	for _, row in ipairs(t) do
		for x, cell in ipairs(row) do
			if not t2[x] then
				t2[x] = {}
			end
			table.insert(t2[x], cell)
		end
	end
	return t2
end

local function center(g)
	local max_cols, results = #g[1], {}
	for x = 1, max_cols - 1 do
		local diffs = 0
		for y in ipairs(g) do
			local a, b = x, x + 1
			while a >= 1 and b <= max_cols do
				diffs, a, b = diffs + (g[y][a] ~= g[y][b] and 1 or 0), a - 1, b + 1
			end
		end
		table.insert(results, { x, diffs })
	end
	return results
end

local P1, P2 = 0, 0
for _, g in ipairs(G) do
	local results = center(g)
	for _, r in ipairs(center(transpose(g))) do
		r[1] = r[1] * 100
		table.insert(results, r)
	end
	for _, r in ipairs(results) do
		P1, P2 = P1 + (r[2] == 0 and r[1] or 0), P2 + (r[2] == 1 and r[1] or 0)
	end
end
print(P1, P2)
