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

local lines = {}
for line in io.lines() do
	table.insert(lines, line)
end

local workflows = {}
for _, line in ipairs(lines) do
	if line:match ":" then
		local name, rest, fallback = line:match "(%a+){(.+),(%a+)}"
		local t = {}
		for part in rest:gmatch "[xmas].%d+:%a+" do
			local key, op, value, target = part:match "([xmas])(.)(%d+):(%a+)"
			table.insert(
				t,
				{ key = key, op = op, value = value, target = target }
			)
		end
		table.insert(t, fallback)
		workflows[name] = t
	end
end

-- t: object (~ part in the description)
-- name: name of the workflow, such as "in", "qs"
-- i: n-th rule in the workflow "name"
local function solve_p1(t, name, i)
	local step = workflows[name][i]

	-- We've reached the last rule in the workflow
	if step == "R" then
		return 0
	elseif step == "A" then
		return t.x + t.m + t.a + t.s
	elseif type(step) == "string" then
		return solve_p1(t, step, 1)
	end

	local r1 = { t[step.key], t[step.key] }
	local r2 = step.op == "<" and { 1, step.value - 1 }
		or { step.value + 1, 4000 }

	-- No match so try the next rule, i + 1
	if #intersection(r1, r2) <= 0 then
		return solve_p1(t, name, i + 1)
	end

	-- Match and we're done (either accepted or rejected)
	if step.target == "A" then
		return t.x + t.m + t.a + t.s
	elseif step.target == "R" then
		return 0
	end

	-- Match, advance to the next workflow
	return solve_p1(t, step.target, 1)
end

local p1 = 0
for _, line in ipairs(lines) do
	if line:match "=" then
		local t = load("return " .. line)()
		p1 = p1 + solve_p1(t, "in", 1)
	end
end
print(p1)

local function copy(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end

-- t: object (~ part in the description)
-- name: name of the workflow, such as "in", "qs"
local function solve_p2(t, name)
	local results, cur = {}, copy(t)

	for _, step in ipairs(workflows[name]) do
		if type(step) == "table" then
			local r1 = cur[step.key]
			local r2 = step.op == "<" and { 1, step.value - 1 }
				or { step.value + 1, 4000 }

			local inter, rest = intersection(r1, r2)
			if #rest > 0 then
				-- Normally the intersection of
				-- |-----------------|
				--      |-----|
				-- would return 1 intersected range and 2 ranges that did
				-- not intersect. But the ranges we get from the workflow
				-- rules always include the entire range of possible values
				-- on one side, so we will only ever get 1 range that did not
				-- intersect.
				rest = rest[1]
			end

			-- No match, try next rule
			if #inter <= 0 then
				goto continue
			end

			-- Take care of the matching part by either sending it to
			-- results or to the next workflow
			if step.target == "A" then
				local clone = copy(cur)
				clone[step.key] = inter
				table.insert(results, clone)
			elseif step.target ~= "A" and step.target ~= "R" then
				-- Try next workflow
				local clone = copy(cur)
				clone[step.key] = inter
				local results2 = solve_p2(clone, step.target)
				table.move(results2, 1, #results2, #results + 1, results)
			end

			-- Take care of the non-matching part by trying the next step with
			-- it, if it's not empty
			if #rest > 0 then
				cur[step.key] = rest
			else
				return results
			end

			::continue::
		elseif step == "A" then
			-- Last rule in workflow
			table.insert(results, copy(cur))
		elseif step == "R" then
			-- Last rule in workflow
			return results
		else
			-- Last rule in workflow
			local results2 = solve_p2(copy(cur), step)
			table.move(results2, 1, #results2, #results + 1, results)
		end
	end
	return results
end

local results = solve_p2(
	{ x = { 1, 4000 }, m = { 1, 4000 }, a = { 1, 4000 }, s = { 1, 4000 } },
	"in"
)

local function score(t)
	return (t.x[2] - t.x[1] + 1)
		* (t.m[2] - t.m[1] + 1)
		* (t.a[2] - t.a[1] + 1)
		* (t.s[2] - t.s[1] + 1)
end

local p2 = score(results[1])
for _, result in ipairs { table.unpack(results, 2) } do
	p2 = p2 + score(result)
end
print(p2)
