-- Solved in 24m58s19
local function extrapolate(seq)
	local every_is_zero = table.concat(seq):match("^0+$")

	if every_is_zero then
		return 0, 0
	else
		local diffs = {}
		for i = 2, #seq, 1 do
			local a, b = seq[i - 1], seq[i]
			table.insert(diffs, b - a)
		end
		local front, back = extrapolate(diffs)
		return seq[1] - front, seq[#seq] + back
	end
end

local P1, P2 = 0, 0
for line in io.lines() do
	local seq = {}
	for d in line:gmatch("%-?%d+") do
		table.insert(seq, tonumber(d))
	end
	local front, back = extrapolate(seq)
	P1 = P1 + back
	P2 = P2 + front
end
print(P1, P2)
