-- A start path finding.


PathHeap = {}
function PathHeap:new()
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.pathes = {}

	return obj
end
function PathHeap:push(path)
	local i = #self.pathes
	if i == 0 then
		self.pathes[1] = path
		return
	end
	local parentP = i
	local childP = i + 1
	self.pathes[childP] = path
	while self.pathes[parentP].dist > path.dist do
		local p = self.pathes[parentP]
		self.pathes[parentP] = path
		self.pathes[childP] = p
		childP = parentP
		parentP = math.floor(parentP/2)
		if parentP == 0 then
			break
		end
	end
end
function PathHeap:pop()
	if #self.pathes == 0 then
		return nil
	end
	local ret = self.pathes[1]
	local tail = self.pathes[#self.pathes]
	self.pathes[#self.pathes] = nil
	if #self.pathes == 0 then
		return ret
	end
	local p = 1
	self.pathes[p] = tail
	local lchild = p * 2
	local rchild = p * 2 + 1
	while self.pathes[lchild] ~= nil do
		local exchld = lchild
		if self.pathes[rchild] ~= nil then
			if self.pathes[lchild].dist > self.pathes[rchild].dist then
				exchld = rchild
			end
		end
		local pth = self.pathes[p]
		local cth = self.pathes[exchld]
		if pth.dist > cth.dist then
			self.pathes[p] = cth
			self.pathes[exchld] = pth
			p = exchld
			lchild = exchld * 2
			rchild = exchld * 2 + 1
		else
			break
		end
	end
	return ret
end
function PathHeap:isEmpty()
	return #self.pathes == 0
end

function  PathHeap:getPathes()
	return self.pathes
end

function findShortestPath(x0, y0, x1, y1, pathMap)
	if pathMap[y1][x1] == nil then
		return nil
	end
	local openList = PathHeap:new()
	local closeList = {}
	--for i = 1, #pathMap, 1 do
	--	local path = {x = pathMap[i].x, y = pathMap.y, dist = 10000}
	--	openList:push(path)
	--end

	-- return the cost from p0 to p1
	local function funcG(x0, y0, x1, y1)
		return math.abs(x1 - x0) + math.abs(y1 - y0)
	end
	-- return the evaluated cost from p0 to p1
	local function funcH(x0, y0, x1, y1)
		return funcG(x0, y0, x1, y1)
	end

	local function getNextPoints(x0, y0, pathMap)
		local p = {}
		if pathMap[y0-1] ~= nil then
			if pathMap[y0-1][x0] ~= nil then
				table.insert(p, { y = y0-1, x = x0})
			end
			if pathMap[y0][x0-1] ~= nil then
				table.insert(p, { y = y0, x = x0-1})
			end
		end
		if pathMap[y0+1] ~= nil then
			if pathMap[y0+1][x0] ~= nil then
				table.insert(p, { y = y0+1, x = x0})
			end
			if pathMap[y0][x0+1] ~= nil then
				table.insert(p, { y = y0, x = x0+1})
			end
		end
		return p
	end
	local startP = {x = x0, y = y0, dist = funcG(x0, y0, x1, y1) + funcH(x0, y0, x1, y1), parent = nil}
	openList:push(startP)

	local path = {}
	while not openList:isEmpty() do
		local pos = openList:pop()
		if pos.x == x1 and pos.y == y1 then
			local pthp = pos
			while pthp.parent ~= nil do
				table.insert(path, {x = pthp.x, y = pthp.y})
				pthp = pthp.parent
			end
		else
			local key = string.format("%d,%d", pos.x, pos.y)
			closeList[key] = pos
			local p = getNextPoints(pos.x, pos.y, pathMap)
			for i = 1, #p, 1 do
				local nxtP = p[i]
				local nxtKey  = string.format("%d,%d", nxtP.x, nxtP.y)
				if closeList[nxtKey] == nil then
					openList:push({x = nxtP.x, y = nxtP.y, dist = funcG(nxtP.x, nxtP.y, x1, y1) + funcH(nxtP.x, nxtP.y, x1, y1), parent = pos})
					closeList[nxtKey] = nxtP
				end
			end
		end
	end

	return path
end