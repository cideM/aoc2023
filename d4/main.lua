-- completed in 55m30s74

local P1, P2, CARDS = 0, 0, {}
for line in io.lines() do
	local id, delim_start, matches = tonumber(line:match("(%d+)")), line:find("|"), 0
	CARDS[id] = (CARDS[id] or 0) + 1

	-- Go through the numbers after the | and check if they can be found
	-- in the part of the line before |. For each match, add another
	-- card ID to the list of cards spawned by the current card.
	for d in line:gmatch("%d+", delim_start) do
		if line:sub(1, delim_start):match(" " .. d .. " ") then
			CARDS[id + 1 + matches] = (CARDS[id + 1 + matches] or 0) + CARDS[id]
			matches = matches + 1
		end
	end
	P1, P2 = P1 + (matches == 0 and 0 or 2 ^ (matches - 1)), P2 + CARDS[id]
end
print(P1, P2)
