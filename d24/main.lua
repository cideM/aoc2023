-- Couldn't do part two without https://www.reddit.com/r/adventofcode/comments/18q40he/2023_day_24_part_2_a_straightforward_nonsolver/

local function same_dir(v1, v2)
	return v1[1] * v2[1] >= 0 and v1[2] * v2[2] >= 0
end

local function intersect(s1, s2)
	local xo1, xo2, yo1, yo2 = s1.pos[1], s2.pos[1], s1.pos[2], s2.pos[2]
	local m1 = s1.vel[2] / s1.vel[1]
	local m2 = s2.vel[2] / s2.vel[1]
	local x = (m1 * xo1 - yo1 - m2 * xo2 + yo2) / (m1 - m2)
	if x == x and x ~= math.huge and x ~= -1 * math.huge then
		return x, m1 * (x - xo1) + yo1
	end
end

local stones = {}
for line in io.lines() do
	local px, py, pz, vx, vy, vz =
		line:match "(%-?%d+),%s*(%-?%d+),%s*(%-?%d+)%s*@%s*(%-?%d+),%s*(%-?%d+),%s*(%-?%d+)"
	px, py, pz, vx, vy, vz =
		tonumber(px),
		tonumber(py),
		tonumber(pz),
		tonumber(vx),
		tonumber(vy),
		tonumber(vz)
	table.insert(stones, { pos = { px, py, pz }, vel = { vx, vy, vz } })
end

local p1 = 0
local min, max = 200000000000000, 400000000000000
for i, s1 in ipairs(stones) do
	for _, s2 in ipairs { table.unpack(stones, i + 1) } do
		local x, y = intersect(s1, s2)
		if x then
			local dx, dy = x - s1.pos[1], y - s1.pos[2]
			local dx2, dy2 = x - s2.pos[1], y - s2.pos[2]
			if
				same_dir(s1.vel, { dx, dy })
				and same_dir(s2.vel, { dx2, dy2 })
				and x >= min
				and x <= max
				and y >= min
				and y <= max
			then
				p1 = p1 + 1
			end
		end
	end
end
print(p1)

local function gaussian_elimination(matrix)
	local rows = #matrix
	local cols = #matrix[1] - 1 -- Last column is for the constants

	-- Forward elimination
	for k = 1, rows do
		for i = k + 1, rows do
			local factor = matrix[i][k] / matrix[k][k]
			for j = k, cols + 1 do
				matrix[i][j] = matrix[i][j] - factor * matrix[k][j]
			end
		end
	end

	-- Back substitution
	local solution = {}
	for i = rows, 1, -1 do
		local sum = 0
		for j = i + 1, cols do
			sum = sum + matrix[i][j] * (solution[j] or 0)
		end
		solution[i] = (matrix[i][cols + 1] - sum) / matrix[i][i]
	end

	return solution
end

local stones_start, stones_len = 100, 4

local matrix_xy = {}

for i = stones_start, stones_start + stones_len do
	local s1, s2 = stones[i - 1], stones[i]
	-- (dy'-dy) X + (dx-dx') Y + (y-y') DX + (x'-x) DY = x' dy' - y' dx' - x dy + y dx
	local row = {
		(s2.vel[2] - s1.vel[2]),
		(s1.vel[1] - s2.vel[1]),
		(s1.pos[2] - s2.pos[2]),
		(s2.pos[1] - s1.pos[1]),
		(s2.pos[1] * s2.vel[2])
			- (s2.pos[2] * s2.vel[1])
			- (s1.pos[1] * s1.vel[2])
			+ (s1.pos[2] * s1.vel[1]),
	}
	table.insert(matrix_xy, row)
end

local x, y = table.unpack(gaussian_elimination(matrix_xy))

local matrix_z = {}

for i = stones_start, stones_start + stones_len do
	local s1, s2 = stones[i - 1], stones[i]
	-- (dy'-dy) Z + (dz-dz') Y + (y-y') DZ + (z'-z) DY = z' dy' - y' dz' - z dy + y dz
	local row = {
		(s2.vel[2] - s1.vel[2]),
		(s1.vel[3] - s2.vel[3]),
		(s1.pos[2] - s2.pos[2]),
		(s2.pos[3] - s1.pos[3]),
		(s2.pos[3] * s2.vel[2])
			- (s2.pos[2] * s2.vel[3])
			- (s1.pos[3] * s1.vel[2])
			+ (s1.pos[2] * s1.vel[3]),
	}
	table.insert(matrix_z, row)
end

local z = table.unpack(gaussian_elimination(matrix_z))
print(string.format("%18.0f", x + y + z))
