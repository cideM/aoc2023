local l1, l2, TIMES, DISTS, P1, P2 = io.read("l"), io.read("l"), {}, {}, 0, 0
for n in l1:gmatch("%d+") do
	table.insert(TIMES, tonumber(n))
end
for n in l2:gmatch("%d+") do
	local dist, count = tonumber(n), 0
	table.insert(DISTS, dist)
	for t = 1, TIMES[#DISTS] do
		count = count + ((TIMES[#DISTS] - t) * t > dist and 1 or 0)
	end
	P1 = P1 == 0 and count or P1 * count
end
TIMES, DISTS = { tonumber(table.concat(TIMES)) }, { tonumber(table.concat(DISTS)) }
for t = 1, TIMES[#DISTS] do
	P2 = P2 + ((TIMES[#DISTS] - t) * t > DISTS[1] and 1 or 0)
end
print(P1, P2)
