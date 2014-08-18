require "Cocos2d"
require "Cocos2dConstants"

require "CoDPlayer"
require "CoDPlayerHUD"
require "CoDMonster"
require "CoDItem"
require "CoDGameMap"
require "CoDCameraController"
require "CoDShortestPath"
require "os"

CoDGameScene = {
}

function CoDGameScene:new(gameDirector, playerdata)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
	
	obj._gDctr = gameDirector


	obj.gameScene = cc.Scene:create()
	obj.gameScene:retain()
	obj.layer = cc.Layer:create()
	obj.camCtrl = CoDCameraController:new()

	obj.layer:addChild(obj.camCtrl:getCameraNode())
	obj.camCtrl:getCameraNode():setPosition(visibleSize.width/2, visibleSize.height/2)


	local map = CoDGameMap:new('finalMap.tmx')
	obj.camCtrl:getTrackNode():addChild(map:getMapNode(), 0, 1)
	obj.camCtrl:setFullViewRect(0, 0, map:getMapSize().width, map:getMapSize().height)
	obj.gameMap = map

	obj.gameScene:addChild(obj.layer)

	obj.playerHUD = CoDPlayerHUD:new(obj)
	obj.layer:addChild(obj.playerHUD:getLayer(), 1000)


	-- add event listener to specified map.
	local function onPlayerTouchMapBegan(touch, event)
		local target = event:getCurrentTarget()

		local locationInMap = target:convertToNodeSpace(touch:getLocation())
		local s = target:getContentSize()
		local rect = cc.rect(0, 0, s.width, s.height)
		if cc.rectContainsPoint(rect,locationInMap) then
			obj:handlePlayerMove(locationInMap.x, locationInMap.y)
			return true
		end
		return false
	end
	local function onPlayerTouchMapEnded(touch, event)
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onPlayerTouchMapBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onPlayerTouchMapEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = obj.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, obj.gameMap:getMapNode())

	-- test


	-- contains a main player and lots of peer players.
	if playerdata.actorType == CoDPlayer.PLAYER_TYPE_LIDDELL then
		obj.mainPlayer = CoDPlayerLiddell:new(playerdata.playerID, playerdata.actorName)
	end
	obj.mainPlayer:setPosition(obj.gameMap:getMapPosition(playerdata.bornX, playerdata.bornY))
	obj.camCtrl:getTrackNode():addChild(obj.mainPlayer:getSprite())

	obj.playerLastGetTime = os.time()
	obj.playerLastFireBall = os.time()
	obj.playerLastDeadZone = os.time()
	obj.playerLastAtkTime = os.time()

	obj.peerPlayers = {}

	-- init time 
	obj.serverTime = playerdata.serverTime

	obj.monsters = {}
	obj.items = {}

	obj.playerOwnHPotion = {}
	obj.playerOwnMPotion = {}

	obj.winLogo = nil

	return obj
end

function CoDGameScene:getScene()
	return self.gameScene
end

function CoDGameScene:getLayer()
	return self.layer
end


function CoDGameScene:onPlayerAttack()
	if self.mainPlayer:isDead() then
		return
	end

	if os.time() - self.playerLastAtkTime > 0.5 then
		self.playerLastAtkTime = os.time()
		-- find nearest monster and attack
		local curDist = 1000000000
		local nearestMon = nil
		local px, py = self.gameMap:getTileIndex(self.mainPlayer:getPosition())
		for k, mon in pairs(self.monsters) do 
			local mx, my = self.gameMap:getTileIndex(mon:getPosition())
			local dist = math.abs(mx - px) + math.abs(my - py)
			if dist < curDist then
				curDist = dist
				nearestMon = mon
			end
		end
		if curDist < 2 then
			-- send attack info to server, play attack action.
			self.mainPlayer:attack(nearestMon:getPosition())
			self._gDctr:playerDoAttack(self.mainPlayer:getPlayerID(), nearestMon:getSeed())
		end
	end
end

function CoDGameScene:onPlayerUseItemA()
	if self.mainPlayer:isDead() then
		return
	end
	if #self.playerOwnHPotion ~= 0 then
		local itmSeed = self.playerOwnHPotion[1]
		self._gDctr:playerUseItem(self.mainPlayer:getPlayerID(), itmSeed)
	end
end

function CoDGameScene:onPlayerUseItemB()
	if self.mainPlayer:isDead() then
		return
	end
	if #self.playerOwnMPotion ~= 0 then
		local itmSeed = self.playerOwnMPotion[1]
		self._gDctr:playerUseItem(self.mainPlayer:getPlayerID(), itmSeed)
	end
end

function CoDGameScene:onPlayerUseSkillA()
	if self.mainPlayer:isDead() then
		return
	end
	if self.mainPlayer:getMP() < 40 then 
		self.mainPlayer:showChat('I need more mana')
		return 
	end
	if os.time() - self.playerLastDeadZone > 1 then
		local x, y = self.mainPlayer:getPosition()
		self.mainPlayer:attack(x, y - 20)
		self.playerLastDeadZone = os.time()
		self._gDctr:playerPerformDeadZone(self.mainPlayer:getPlayerID())
	end
end

function CoDGameScene:onPlayerUseSkillB()
	if self.mainPlayer:isDead() then
		return
	end
	if self.mainPlayer:getMP() < 20 then 
		self.mainPlayer:showChat('I need more mana')
		return 
	end
	if os.time() - self.playerLastFireBall > 3 then
		self.playerLastFireBall = os.time()
		-- find nearest monster and attack
		local curDist = 1000000000
		local nearestMon = nil
		local px, py = self.gameMap:getTileIndex(self.mainPlayer:getPosition())
		for k, mon in pairs(self.monsters) do 
			local mx, my = self.gameMap:getTileIndex(mon:getPosition())
			local dist = math.abs(mx - px) + math.abs(my - py)
			if dist < curDist then
				curDist = dist
				nearestMon = mon
			end
		end
		if curDist < 10 then
			self._gDctr:playerPerformFireBall(self.mainPlayer:getPlayerID(), nearestMon:getSeed())
			self.mainPlayer:attack(nearestMon:getPosition())
		end
	end
end

function CoDGameScene:onPlayerChat(msg)
	if msg == '' then
		return
	end
	self._gDctr:playerChat(self.mainPlayer:getPlayerID(), msg)
end

function CoDGameScene:onPlayerTryGetItem()
	if self.mainPlayer:isDead() then
		return
	end
	local px, py = self.gameMap:getTileIndex(self.mainPlayer:getPosition())
	for k, v in pairs(self.items) do
		local ix, iy = self.gameMap:getTileIndex(v:getPosition())
		if ix == px and iy == py then
			self._gDctr:playerGetItem(self.mainPlayer:getPlayerID(), k)
			break
		end
	end
end

-- get the path to 
function CoDGameScene:handlePlayerMove(x, y)
	if self.mainPlayer:isDead() then 
		return 
	end
	local midx, midy = self.gameMap:getTileIndex(x,y)
	--cclog('%d, %d', midx, midy)
	local x0, y0 = self.gameMap:getTileIndex(self.mainPlayer:getPosition())
	local path = findShortestPath(x0, y0, midx, midy, self.gameMap:getAvailablePath())
	local pathInMap = {}
	if path ~= nil then
		for i=#path, 1, -1 do
			local px, py = self.gameMap:getMapPosition(path[i].x, path[i].y)
			table.insert(pathInMap, {x = px, y = py})
		end
		self.mainPlayer:move(pathInMap)
	end

end

function CoDGameScene:handleNewPlayerEnter(newActorData)
	local newActor = nil
	if newActorData.actorType == CoDPlayer.PLAYER_TYPE_LIDDELL then
		newActor = CoDPlayerLiddell:new(newActorData.playerID, newActorData.actorName)
	else 
		return 
	end
	self.camCtrl:getTrackNode():addChild(newActor:getSprite())
	newActor:setPosition(self.gameMap:getMapPosition(newActorData.bornX, newActorData.bornY))
	newActor:setHP(newActorData.HP)
	newActor:setMP(newActorData.MP)

	self.peerPlayers[newActorData.playerID] = newActor
end

function CoDGameScene:handlePlayerChat(data)
	local p = nil
	if data.playerID == self.mainPlayer:getPlayerID() then
		p = self.mainPlayer
	else
		for pk, pv in pairs(self.peerPlayers) do
			local pp = pv
			if pp:getPlayerID() == data.playerID then
				p = pp
				break
			end
		end
	end
	if p ~= nil then
		p:showChat(data.msg)
	end
end

function CoDGameScene:handlePlayerExit(id)
	if self.peerPlayers[id] ~= nil then
		cclog('player %d exit', id)
		self.camCtrl:getTrackNode():removeChild(self.peerPlayers[id]:getSprite())
		self.peerPlayers[id] = nil
	end
end

function CoDGameScene:handlePlayerStateNotification(stateData)
	for dk, dv in pairs(stateData) do
		local data = dv
		for pk, pv in pairs(self.peerPlayers) do
			-- how to handle time?
			if pk == data.PlayerID then
			local px, py = self.gameMap:getMapPosition(data.posX, data.posY)
			local path = {x = px, y = py}
				pv:move({path})
			end
		end
		if data.PlayerID == self.mainPlayer:getPlayerID() then
			self.mainPlayer:setHP(data.hp)
			self.mainPlayer:setMP(data.mp)
		end
	end
end

function CoDGameScene:handleMonsterStateNotification(stateData)
	for dk, dv in pairs(stateData) do
		local data = dv
		if self.monsters[data.seed] == nil then
			-- add a new monster then animate 'born'
			local newMon = nil
			if data.type == CoDMonster.MONSTER_TYPE_A then
				newMon = CoDMonsterA:new(data.seed)
			elseif data.type == CoDMonster.MONSTER_TYPE_B then
				newMon = CoDMonsterB:new(data.seed)
			end
			if newMon ~= nil then
				newMon:setPosition(self.gameMap:getMapPosition(data.posX, data.posY))
				self.camCtrl:getTrackNode():addChild(newMon:getSprite())
				-- hp?
				self.monsters[data.seed] = newMon
			end
		else 
			local px, py = self.gameMap:getMapPosition(data.posX, data.posY)
			local path = {x = px, y = py}
			self.monsters[data.seed]:move({path})
			-- hp?
		end
	end
	-- remove those unexisted mons.
	local existed = {}
	local removeKey = {}
	for dk, dv in pairs(stateData) do
		local data = dv
		for mk, mv in pairs(self.monsters) do
			if mk == data.seed then
				existed[data.seed] = mv
				self.monsters[mk] = nil
				break
			end
		end
	end
--	for rk, rv in pairs(removeKey) do 
--	end
	for mk, mv in pairs(self.monsters) do
		--cclog('here')
		self.camCtrl:getTrackNode():removeChild(mv:getSprite())
		mv:getSprite():release()
	end
	self.monsters = existed
end

function CoDGameScene:handleItemStateNotification(stateData)
	for dk, dv in pairs(stateData) do
		local data = dv
		if self.items[data.seed] == nil then
			-- add a new item.
			local itm = nil
			if data.type == CoDItem.ITEM_TYPE_HEALTH_POTION then
				itm = CoDHealthPotion:new(data.seed)
			elseif data.type == CoDItem.ITEM_TYPE_MANA_POTION then
				itm = CoDManaPotion:new(data.seed)
			end
			if itm ~= nil then
				itm:setPosition(self.gameMap:getMapPosition(data.posX, data.posY))
				self.camCtrl:getTrackNode():addChild(itm:getSprite())
				self.items[data.seed] = itm
			end
		else
			local px, py = self.gameMap:getMapPosition(data.posX, data.posY)
			self.items[data.seed]:setPosition(self.gameMap:getMapPosition(data.posX, data.posY))
		end
	end
	-- remove those unexisted items.
	local existed = {}
	--local removeKey = {}
	for dk, dv in pairs(stateData) do
		local data = dv
		for mk, mv in pairs(self.items) do
			if mk == data.seed then
				existed[data.seed] = mv
				self.items[data.seed] = nil
				break
			end
		end
	end
	for ik, iv in pairs(self.items) do
		self.camCtrl:getTrackNode():removeChild(iv:getSprite())
		iv:getSprite():release()
	end
	self.items = existed
end


function CoDGameScene:handleMonsterAction(data)
	if self.monsters[data.seed] ~= nil then

		-- play monster animation.
	end
end

function CoDGameScene:handlePlayerHurt(data)
	-- play hurt action, show values.
	if data.playerID == self.mainPlayer:getPlayerID() then
		self.mainPlayer:showDamage(data.damage)
	else
		for pk, pv in pairs(self.peerPlayers) do
			local p = pv
			if p:getPlayerID() == data.playerID then
				p:showDamage(data.damage)
				break
			end
		end
	end

end

function CoDGameScene:handlePlayerReceiveItem(data)
	if data.playerID == self.mainPlayer:getPlayerID() then
		if data.itemType == CoDItem.ITEM_TYPE_HEALTH_POTION then
			table.insert(self.playerOwnHPotion, data.itemSeed)
		elseif data.itemType == CoDItem.ITEM_TYPE_MANA_POTION then
			table.insert(self.playerOwnMPotion, data.itemSeed)
		end
		self.playerHUD:updateItem(#self.playerOwnHPotion, #self.playerOwnMPotion)	
	end
end

function CoDGameScene:handleMonsterHurt(data)
	if self.monsters[data.seed] ~= nil then
		local mon = self.monsters[data.seed]
		-- mon do action
		mon:showDamage(data.damage)
	end
end


function CoDGameScene:handlePlayerDie(playerID)
	local p = nil
	if playerID == self.mainPlayer:getPlayerID() then
		p = self.mainPlayer
	else
		for pk, pv in pairs(self.peerPlayers) do
			local pp = pv
			if pp:getPlayerID() == playerID then
				p = pp
				break
			end
		end
	end
	if p ~= nil then
		p:doAction(CoDPlayer.PLAYER_ACTION_DIE)
		p:showChat('I Die...')
		p:setDead(true)
	end

end

function CoDGameScene:handleMonsterDie(monsterSeed)
--	local m = self.monsters[monsterSeed]
--	if m ~= nil then
--		self.camCtrl:getTrackNode():removeChild(m:getSprite())
--		m:getSprite():release()
--		table.remove(self.monsters, monsterSeed)
--	end
end

function CoDGameScene:handlePlayerReceiveEffect(data)
	--cclog('here')
	local p = nil
	if data.playerID == self.mainPlayer:getPlayerID() then
		p = self.mainPlayer
		-- find item pos.
		local itmPos = nil
		for i = 1, #self.playerOwnHPotion do
			if self.playerOwnHPotion[i] == data.itemSeed then
				itmPos = i
				break
			end 
		end
		if itmPos ~= nil then
			table.remove(self.playerOwnHPotion, itmPos)
		else
			for i = 1, #self.playerOwnMPotion do
				if self.playerOwnMPotion[i] == data.itemSeed then
					itmPos = i
					break
				end
			end
			if itmPos ~= nil then
				table.remove(self.playerOwnMPotion, itmPos)
			end
		end
	else
		for pk, pv in pairs(self.peerPlayers) do
			local pp = pv
			if pp:getPlayerID() == data.playerID then
				p = pp
				break
			end
		end
	end
	if p ~= nil then
		p:showHealth(data.hpEffect, data.mpEffect)
	end
	self.playerHUD:updateItem(#self.playerOwnHPotion, #self.playerOwnMPotion)	
end

function CoDGameScene:handleFireBallPerformed(data)
	local sx, sy = self.gameMap:getMapPosition(data.playerX, data.playerY)
	local ex, ey = self.gameMap:getMapPosition(data.monX, data.monY)
	local sprite = cc.Sprite:create()
	sprite:setPosition(sx, sy+20)
	sprite:setAnchorPoint(0.5,0.5)
	sprite:setScale(0.5, 0.5)
	local moveAct = cc.MoveTo:create(0.1, cc.p(ex, ey))
	sprite:runAction(moveAct)
	local animFrames = {}
	for i = 1, 24 do
		local str = string.format('skill/FireBall/FireBall_%0.2d.png', i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,192,192))
		animFrames[i] = frame
	end
	local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.1)
	local animate = cc.Animate:create(animation)

	local function stopAnimate(sender, valuse)
		sender:removeFromParent()
	end
	local callBack = cc.CallFunc:create(stopAnimate, {})

	local actionSeq = {}
	table.insert(actionSeq, animate)
	table.insert(actionSeq, callBack)
	local seq = cc.Sequence:create(actionSeq)
	sprite:runAction(seq)
	self.camCtrl:getTrackNode():addChild(sprite, 1000000)

end

function CoDGameScene:handleDeadZonePerformed(data)
	--cclog('here')
	local p = nil
	if data.playerID == self.mainPlayer:getPlayerID() then
		p = self.mainPlayer
	else
		for pk, pv in pairs(self.peerPlayers) do
			local pp = pv
			if pp:getPlayerID() == data.playerID then
				p = pp
				break
			end
		end
	end
	if p ~= nil then
		local x, y = p:getPosition()
		local sprite = cc.Sprite:create()
		sprite:setPosition(x, y)
		sprite:setAnchorPoint(0.5,0.22)
		sprite:setScale(0.5, 0.5)
		local animFrames = {}
		for i = 1, 18 do
			local str = string.format('skill/DeadZone/DeadZone0001 (%d).png', i)
			local frame = cc.SpriteFrame:create(str, cc.rect(0,0,500,708))
			animFrames[i] = frame
		end
		local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.07)
		local animate = cc.Animate:create(animation)

		local function stopAnimate(sender, valuse)
			sender:removeFromParent()
		end
		local callBack = cc.CallFunc:create(stopAnimate, {})

		local actionSeq = {}
		table.insert(actionSeq, animate)
		table.insert(actionSeq, callBack)
		local seq = cc.Sequence:create(actionSeq)
		sprite:runAction(seq)
		self.camCtrl:getTrackNode():addChild(sprite, 1000000)
	end
end

function CoDGameScene:update()
	local pposx, ppoxy = self.mainPlayer:getPosition()
	self.camCtrl:setViewTarget(pposx, ppoxy)

	-- sort characters and monsters. using their 
	local baseZ = self.gameMap:getZOrder()
	local spriteList = {}
	local sprt = {}
	sprt.sprite = self.mainPlayer:getSprite()
	local x, y = self.mainPlayer:getPosition()
	sprt.z = y
	table.insert(spriteList, sprt)
	for _k, _v in pairs(self.peerPlayers) do
		local psprt = {}
		local x, y = _v:getPosition()
		psprt.sprite = _v:getSprite()
		psprt.z = y
		table.insert(spriteList, psprt)
	end
	for _k, _v in pairs(self.monsters) do
		local msprt = {}
		local x, y = _v:getPosition()
		msprt.sprite = _v:getSprite()
		msprt.z = y
		table.insert(spriteList, msprt)
	end
	for _k, _v in pairs(self.items) do
		local isprt = {}
		local x, y = _v:getPosition()
		isprt.sprite = _v:getSprite()
		isprt.z = y
		table.insert(spriteList, isprt)
	end

	local sortFunc = function(a, b) return a.z > b.z end
	table.sort(spriteList,  sortFunc)
	for i = 1, #spriteList do
		local s = spriteList[i]
		s.sprite:setLocalZOrder(i)
	end

	local curTime = os.time()
	if curTime - self.playerLastGetTime > 1.0 then
		self.playerLastGetTime = curTime
		self:onPlayerTryGetItem()
	end

	-- update hud
	self.playerHUD:updateHP(self.mainPlayer:getHP())
	self.playerHUD:updateMP(self.mainPlayer:getMP())
end

function CoDGameScene:handleGameWin()
	if self.winLogo == nil then
		local visibleSize = cc.Director:getInstance():getVisibleSize()
	   	local origin = cc.Director:getInstance():getVisibleOrigin()
		self.winLogo = cc.Sprite:create('WinLogo.png')
		self.winLogo:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height/2)
		self.layer:addChild(self.winLogo, 1000)
	end
end

function CoDGameScene:syncServer()
	-- send character data to server.
	local mplayerdata = {}
	mplayerdata.playerID = self.mainPlayer:getPlayerID()
 	mplayerdata.action = 0 -- -- - - -- -for modification
 	local mapIdxx, mapIdxy = self.gameMap:getTileIndex(self.mainPlayer:getPosition())
 	mplayerdata.posX = mapIdxx
 	mplayerdata.posY = mapIdxy
	self._gDctr:syncPlayerState(mplayerdata)
end