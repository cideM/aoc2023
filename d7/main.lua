local function kv(list)
	local t = {}
	for i, v in ipairs(list) do
		t[v] = i
	end
	return t
end

local kind_order, card_order_joker, card_order_no_joker, upgrade, CARDS =
	kv({ "5", "4;1", "3;2", "3;1;1", "2;2;1", "2;1;1;1", "1;1;1;1;1" }),
	kv({ "A", "K", "Q", "T", "9", "8", "7", "6", "5", "4", "3", "2", "J" }),
	kv({ "A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2" }),
	{
		["5J5"] = "5",
		["4J4;1"] = "5",
		["1J4;1"] = "5",
		["3J3;2"] = "5",
		["2J3;2"] = "5",
		["3J3;1;1"] = "4;1",
		["1J3;1;1"] = "4;1",
		["2J2;2;1"] = "4;1",
		["1J2;2;1"] = "3;2",
		["2J2;1;1;1"] = "3;1;1",
		["1J2;1;1;1"] = "3;1;1",
		["1J1;1;1;1;1"] = "2;1;1;1",
	},
	{}

for line in io.lines() do
	local hand, bid = line:match("([%u%d]+) (%d+)")
	local counts, list = {}, {}
	for c in hand:gmatch(".") do
		counts[c] = (counts[c] or 0) + 1
	end
	for _, v in pairs(counts) do
		table.insert(list, v)
	end
	table.sort(list, function(a, b)
		return a > b
	end)
	local k = table.concat(list, ";")
	table.insert(CARDS, {
		hand = hand,
		bid = tonumber(bid),
		kind_order_p1 = kind_order[k],
		kind_order_p2 = kind_order[upgrade[string.format("%dJ%s", counts.J or 10, k)] or k],
	})
end

local function cmp_card(a, b, order)
	local i = 1
	for ca in a:gmatch(".") do
		local cb = b:sub(i, i)
		if ca ~= cb then
			return order[ca] > order[cb]
		end
		i = i + 1
	end
	return false
end

local P1, P2 = 0, 0
table.sort(CARDS, function(a, b)
	local o1, o2 = a.kind_order_p1, b.kind_order_p1
	if o1 ~= o2 then
		return o1 > o2
	else
		return cmp_card(a.hand, b.hand, card_order_no_joker)
	end
end)
for i, card in ipairs(CARDS) do
	P1 = card.bid * i + P1
end

table.sort(CARDS, function(a, b)
	local o1, o2 = a.kind_order_p2, b.kind_order_p2
	if o1 ~= o2 then
		return o1 > o2
	else
		return cmp_card(a.hand, b.hand, card_order_joker)
	end
end)
for i, card in ipairs(CARDS) do
	P2 = card.bid * i + P2
end
print(P1, P2)
