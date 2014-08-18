require "Cocos2d"
require "Cocos2dConstants"



CoDGameMap = {
	
}


function CoDGameMap:new(mapfile)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self


	obj.path = {}
	local map = cc.TMXTiledMap:create(mapfile)
	local children = map:getChildren()

	for k, child in ipairs(children) do
		child:getTexture():setAntiAliasTexParameters()
	end
	map:retain()

	-- init path layer.
	local pathLyr = map:getLayer('Path')
	if pathLyr ~= nil then
		-- write to file
		--local pathFile = io.open('path.txt', 'w')
		pathLyr:setVisible(false)
		local s = pathLyr:getLayerSize()
		-- w/h
		--pathFile:write(tostring(s.width)..'\n')
		--pathFile:write(tostring(s.height)..'\n')
		for y = 0, s.height - 1, 1 do
			obj.path[y] = {}
			for x = 0, s.width - 1, 1 do
		    	local tile = pathLyr:getTileAt(cc.p(x, y))
		    	if tile ~= nil then
		    		obj.path[y][x] = true
		    		--pathFile:write(tostring(1))
		    	else
		    		--pathFile:write(tostring(0))
		    	end
		    end
			--pathFile:write('\n')
		end
		--pathFile:close()
	end
	-- init born position
	obj.bornPoint = {x = 0, y = 0}
	local bornLyr = map:getLayer('BornPoint')
	if bornLyr ~= nil then
		bornLyr:setVisible(false)
		local s = bornLyr:getLayerSize()
		for x = 0, s.width - 1, 1 do
			local find = false
		    for y = 0, s.height - 1, 1 do
		    	local tile = bornLyr:getTileAt(cc.p(x, y))
		    	-- reach the first one and close.
		    	if tile ~= nil then
		    		obj.bornPoint.x = x
		    		obj.bornPoint.y = y
		    		find = true
		    		break
		    	end
		    end
		    if find then
		    	break
		    end
		end
	end
	--local bornFile = io.open('born.txt', 'w')
	--bornFile:write(tostring(obj.bornPoint.x))
	--bornFile:write('\n')
	--bornFile:write(tostring(obj.bornPoint.y))
	--bornFile:close()

	--local monFile = io.open('monster.txt', 'w')
	-- init monster position
	local monLyr = map:getLayer('Monster')
	if monLyr ~= nil then
		monLyr:setVisible(false)
		local s = monLyr:getLayerSize()
		for x = 0, s.width -1, 1 do
			for y = 0, s.height-1, 1 do
				local tile = monLyr:getTileAt(cc.p(x,y))
				if tile ~= nil then
					--monFile:write(string.format('%d,%d ',x, y))
				end
			end
		end
	end
	--monFile:close()

	--local chestFile = io.open('chest.txt', 'w')
	local chLyr = map:getLayer('Chest')
	if chLyr ~= nil then
		chLyr:setVisible(false)
		local s = chLyr:getLayerSize()
		for x = 0, s.width -1, 1 do
			for y = 0, s.height-1, 1 do
				local tile = chLyr:getTileAt(cc.p(x,y))
				if tile ~= nil then
					--chestFile:write(string.format('%d,%d ',x, y))
				end
			end
		end
	end
	--chestFile:close()


	obj.tmxMap = map

	obj.zOrder = map:getGlobalZOrder()

	return obj
end

function CoDGameMap:getZOrder()
	return self.zOrder
end

function CoDGameMap:getMapNode()
	return self.tmxMap
end

function CoDGameMap:getMapSize()
	return self.tmxMap:getContentSize()
end

function CoDGameMap:getTileSize()
	return self.tmxMap:getTileSize()
end

-- get tile index using position value
function CoDGameMap:getTileIndex(x, y)
	local xid = math.floor(x/self.tmxMap:getTileSize().width)
	local yid = math.ceil(y/self.tmxMap:getTileSize().height)
	return xid, self.tmxMap:getMapSize().height-yid
end

-- get path data.
function CoDGameMap:getAvailablePath()
	return self.path
end

function CoDGameMap:getBornPoint()
	return self.bornPoint
end

-- use map's index x and y (both zero based) to retrieve actual position.
function CoDGameMap:getMapPosition(idxx,idxy)
	local x = self.tmxMap:getTileSize().width * idxx + self.tmxMap:getTileSize().width/2
	local y = (self.tmxMap:getMapSize().height - idxy) * self.tmxMap:getTileSize().height - self.tmxMap:getTileSize().height/2
	return x, y
end