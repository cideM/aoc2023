-- completed in 55m30s74

local P1, P2, CARDS, CACHE = 0, 0, {}, {}
for line in io.lines() do
	local id, delim_start, win_ids = tonumber(line:match("(%d+)")), line:find("|"), {}
	assert(id)

	-- Go through the numbers after the | and check if they can be found
	-- in the part of the line before |. For each match, add another
	-- card ID to the list of cards spawned by the current card.
	for d in line:gmatch("%d+", delim_start) do
		if line:sub(1, delim_start):match(" " .. d .. " ") then
			table.insert(win_ids, id + #win_ids + 1)
		end
	end
	CARDS[id] = win_ids
	P1 = P1 + (#win_ids == 0 and 0 or 2 ^ (#win_ids - 1))
end

local function resolve(id)
	if CACHE[id] then
		return CACHE[id]
	end

	local added = #CARDS[id]
	for _, other in ipairs(CARDS[id]) do
		added = added + resolve(other)
	end

	CACHE[id] = added
	return CACHE[id]
end

-- Go through the cards backwards, since cards can only spawn cards below
-- themselves. Meaning, the last card can't spawn anything (indeed it never
-- has any winners). For each card spawned by a card, recursively evaluate
-- how many cards would be spawned in turn. Remember the number of cards
-- spawned by each card in CACHE, so we don't need to do work twice.
P2 = #CARDS
for id = #CARDS, 1, -1 do
	P2 = P2 + resolve(id)
end

print(P1, P2)
