-- completed in 55m30s74

local P1, P2, CARDS = 0, 0, {}
for line in io.lines() do
	local id, delim_start, matches = tonumber(line:match("(%d+)")), line:find("|"), 0
	CARDS[id] = (CARDS[id] or 0) + 1

	-- Go through the numbers after the | and check if they can be found
	-- in the part of the line before |.
	for d in line:gmatch("%d+", delim_start) do
		if line:sub(1, delim_start):match(" " .. d .. " ") then
			-- Each card adds at least 1 (itself) to the total
			-- number of cards. If card 1 spawns 2 cards,
			-- then cards 2 and 3 both occur twice (original +
			-- one copy). If card 2 spawns 2 cards, and itself
			-- appears twice, then cards 3 and 4 both appear 3
			-- times: once as originals, and twice as copies.
			CARDS[id + 1 + matches] = (CARDS[id + 1 + matches] or 0) + CARDS[id]
			matches = matches + 1
		end
	end
	P1, P2 = P1 + (matches == 0 and 0 or 2 ^ (matches - 1)), P2 + CARDS[id]
end
print(P1, P2)
