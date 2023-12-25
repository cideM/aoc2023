--[[
This is not very clean and not a general solution. This script creates a
file "d25/graph.dot" which you can convert to an .svg file with `dot -Tsvg
d25/graph.dot > output.svg`.  Open it in your browser and you'll quickly see
the three wires connecting the two groups. Hover over the lines to see which
components they connect. Then you just cut those, meaning they don't make it
into the graph. Then do a depth-first traversal on each node, keeping track
of the ones you've already seen. This should then give you your two groups.
--]]

local cut_pairs = {
	{ "jjn", "nhg" },
	{ "xnn", "txf" },
	{ "tmc", "lms" },
}
local cut = {}
for _, p in ipairs(cut_pairs) do
	table.sort(p, function(a, b)
		return a < b
	end)
	cut[table.concat(p, ";")] = true
end

local GRAPH, NODES = {}, {}

local f = assert(io.open("d25/graph.dot", "w"))
f:write "graph {\n"
f:write [[	graph [pad="0.5", nodesep="1", ranksep="2"];
]]

for line in io.lines() do
	local left, rest = line:match "(%a+):%s+(.+)"
	GRAPH[left] = GRAPH[left] or {}
	NODES[left] = true

	for word in rest:gmatch "%a+" do
		local pair = { left, word }
		table.sort(pair, function(a, b)
			return a < b
		end)
		if not cut[table.concat(pair, ";")] then
			f:write(string.format("\t%s -- %s;\n", word, word))
			GRAPH[word] = GRAPH[word] or {}
			GRAPH[left][word] = true
			GRAPH[word][left] = true
		end

		NODES[word] = true
	end
end

f:write "}\n"

local function dfs(n, seen)
	if not seen[n] then
		seen[n] = true
		local v = 1
		for child in pairs(GRAPH[n]) do
			v = v + (dfs(child, seen) or 0)
		end
		return v
	end
end

local queue = {}
for n in pairs(NODES) do
	table.insert(queue, n)
end
table.sort(queue, function(a, b)
	return a < b
end)

local seen, subgraph_sizes = {}, {}

while #queue > 0 do
	local cur = table.remove(queue, 1)
	if seen[cur] then
		goto continue
	end
	table.insert(subgraph_sizes, dfs(cur, seen))
	seen[cur] = true
	::continue::
end
print(subgraph_sizes[1] * subgraph_sizes[2])
