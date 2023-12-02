for line in io.lines() do
	local max = {}
	for _, color in ipairs({ "green", "red", "blue" }) do
		for match in line:gmatch("(%d+) " .. color) do
			max[color] = math.max(max[color] or 0, tonumber(match))
		end
	end
	P2 = (P2 or 0) + max.green * max.blue * max.red

	if max.green <= 13 and max.red <= 12 and max.blue <= 14 then
		P1 = (P1 or 0) + tonumber(line:match("%d+"))
	end
end
print(P1, P2)
