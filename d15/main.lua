local function hash(s)
	local x = 0
	for c in s:gmatch(".") do
		x = ((x + string.byte(c)) * 17) % 256
	end
	return x
end

local function set(t, i, k, v)
	if not t[i] then
		t[i] = { { k, v } }
		return
	end
	for j, lens in ipairs(t[i]) do
		if lens[1] == k then
			t[i][j] = { k, v }
			return
		end
	end
	table.insert(t[i], { k, v })
end

local function remove(t, i, k)
	if t[i] then
		for j, lens in ipairs(t[i]) do
			if lens[1] == k then
				table.remove(t[i], j)
				return
			end
		end
	end
end

local input, P1, P2, BOXES = io.read("a"), 0, 0, {}
for w in input:gmatch("([^%,\n]+),?") do
	P1 = P1 + hash(w)
	if w:match("=") then
		local label, value = w:match("(%a+)=(%d+)")
		set(BOXES, hash(label), label, value)
	else
		local label = w:match("(%a+)-")
		remove(BOXES, hash(label), label)
	end
end

for i, box in pairs(BOXES) do
	for j, v in ipairs(box) do
		local power = (1 + i) * j * v[2]
		P2 = P2 + power
	end
end
print(P1, P2)
