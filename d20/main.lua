local function gcd(a, b)
	return b == 0 and a or gcd(b, a % b)
end

local function lcm(m, n)
	return (m ~= 0 and n ~= 0) and m * n / gcd(m, n) or 0
end

local function conjunction_is(state, module_name, want)
	for _, v in pairs(state[module_name]) do
		if v ~= want then
			return false
		end
	end
	return true
end

local function parse_line(s)
	local left, right = s:match "([^%-%s]+) %-> (.+)"
	local receivers = {}
	for word in right:gmatch "%a+" do
		table.insert(receivers, word)
	end
	local module_type = "broadcaster"
	if left:sub(1, 1) == "&" then
		module_type = "conjunction"
	elseif left:sub(1, 1) == "%" then
		module_type = "flip_flop"
	end
	return left:gsub("%%", ""):gsub("&", ""), module_type, receivers
end

local incoming, outgoing, state, types = {}, {}, {}, {}
for line in io.lines() do
	local module_name, module_type, receivers = parse_line(line)
	types[module_name] = module_type
	outgoing[module_name] = receivers
	for _, recv in ipairs(receivers) do
		incoming[recv] = incoming[recv] or {}
		table.insert(incoming[recv], module_name)

		if types[recv] == "conjunction" then
			state[recv] = state[recv] or {}
			state[recv][module_name] = state[recv][module_name] or 0
		end
	end
	if module_type == "flip_flop" then
		state[module_name] = false
	elseif module_type == "conjunction" then
		state[module_name] = state[module_name] or {}
		for _, sends_me_signals in ipairs(incoming[module_name] or {}) do
			state[module_name][sends_me_signals] = 0
		end
	end
end

local lo, hi = 0, 0

local watched = {
	xm = {},
	dt = {},
	vt = {},
	gr = {},
}

for i = 1, 10000 do
	local queue = { { "button", "broadcaster", 0 } }
	while #queue > 0 do
		for k in pairs(watched) do
			if conjunction_is(state, k, 1) then
				table.insert(watched[k], i)
			end
		end

		local cur = table.remove(queue, 1)
		local from, to, pulse = table.unpack(cur)
		if pulse == 1 then
			hi = hi + 1
		else
			lo = lo + 1
		end

		local module_type = types[to]
		if module_type == "broadcaster" then
			for _, recv in ipairs(outgoing[to]) do
				table.insert(queue, { to, recv, 0 })
			end
		elseif module_type == "flip_flop" and pulse == 0 then
			if state[to] == false then
				state[to] = true
				for _, recv in ipairs(outgoing[to]) do
					table.insert(queue, { to, recv, 1 })
				end
			else
				state[to] = false
				for _, recv in ipairs(outgoing[to]) do
					table.insert(queue, { to, recv, 0 })
				end
			end
		elseif module_type == "conjunction" then
			state[to][from] = pulse
			local all_hi = true
			for _, remembered_pulse in pairs(state[to]) do
				if remembered_pulse ~= 1 then
					all_hi = false
					break
				end
			end
			for _, recv in ipairs(outgoing[to]) do
				table.insert(queue, { to, recv, all_hi and 0 or 1 })
			end
		end
	end
end

local p2 = 0
for _, v in pairs(watched) do
	local seen = {}
	local unique = {}
	for _, vv in ipairs(v) do
		if not seen[vv] then
			seen[vv] = true
			table.insert(unique, vv)
		end
	end
	p2 = p2 == 0 and unique[1] or lcm(p2, unique[1])
end

print(lo * hi, p2)
