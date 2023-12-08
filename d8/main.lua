local DIRECTION, MAP, CONVERT, P2 = {}, {}, { R = 2, L = 1 }, 0
for line in io.lines() do
	if line:match("^%u+$") then
		for c in line:gmatch("%u") do
			table.insert(DIRECTION, c)
		end
	end

	if line:match("=") then
		local from, l, r = line:match("([%u%d]+) = %(([%u%d]+), ([%u%d]+)%)")
		MAP[from] = { l, r }
	end
end

local function gcd(a, b)
	return b == 0 and a or gcd(b, a % b)
end

local function lcm(m, n)
	return (m ~= 0 and n ~= 0) and m * n / gcd(m, n) or 0
end

local function solve(cur, insp)
	local cur_next = MAP[cur][CONVERT[DIRECTION[insp % #DIRECTION == 0 and #DIRECTION or insp % #DIRECTION]]]
	return cur:match("Z$") and 0 or (1 + solve(cur_next, insp + 1))
end

for k in pairs(MAP) do
	if k:match("A$") then
		P2 = P2 == 0 and solve(k, 1) or lcm(P2, solve(k, 1))
	end
end
print(solve("AAA", 1), P2)
