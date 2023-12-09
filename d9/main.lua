-- Solved in 24m58s19
local function extrapolate(seq)
	if table.concat(seq):match("^0+$") then
		return 0, 0
	else
		local diffs = {}
		for i = 2, #seq, 1 do
			table.insert(diffs, seq[i] - seq[i - 1])
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
	P1, P2 = P1 + back, P2 + front
end
print(P1, P2)
