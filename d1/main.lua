local function gfind(s, pat, init, plain)
	init = init or 1
	if init > #s or s == "" then
		return nil
	end

	local function iterator()
		local first, last, match = s:find(pat, init, plain)
		if match then
			init = last + 1
			return { first = first, last = last, match = match }
		end
		return nil
	end

	return iterator
end

local function extract_digits(s)
	local matches = {}
	for m in gfind(s, "(%d)") do
		table.insert(matches, m)
	end

	for i, pat in ipairs({
		"(zero)",
		"(one)",
		"(two)",
		"(three)",
		"(four)",
		"(five)",
		"(six)",
		"(seven)",
		"(eight)",
		"(nine)",
	}) do
		for match in gfind(s, pat) do
			table.insert(matches, { first = match.first, last = match.last, match = i - 1 })
		end
	end

	table.sort(matches, function(a, b)
		return a.first < b.first
	end)

	return matches[1].match, matches[#matches].match
end

local p1, p2 = 0, 0
for line in io.lines() do
	p1 = p1 + tonumber(string.format("%d%d", string.match(line, "%d"), string.match(line:reverse(), "%d")))
	p2 = p2 + tonumber(string.format("%d%d", extract_digits(line)))
end
print(p1, p2)
