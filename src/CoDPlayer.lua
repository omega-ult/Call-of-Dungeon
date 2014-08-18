require "Cocos2d"
require "Cocos2dConstants"

require "CoDShortestPath"


CoDPlayer = {
	PLAYER_TYPE_LIDDELL	= 0x0000,

	PLAYER_STATE_ALIVE		= 0x0100,
	PLAYER_STATE_OCCUPIED 	= 0x1019,
	PLAYER_STATE_STOP		= 0x1020,
	PLAYER_STATE_DEAD		= 0x0101,

	PLAYER_FACE_UP			= 0x1001,
	PLAYER_FACE_DOWN		= 0x1002,
	PLAYER_FACE_LEFT		= 0x1003,
	PLAYER_FACE_RIGHT		= 0x1004,

	PLAYER_ACTION_MOVE_SEQUENCE	= 0x1010,

	PLAYER_ACTION_MOVE_UP	= 0x1011,
	PLAYER_ACTION_MOVE_DOWN	= 0x1012,
	PLAYER_ACTION_MOVE_LEFT	= 0x1013,
	PLAYER_ACTION_MOVE_RIGHT= 0x1014,


	PLAYER_ACTION_ATTACK_UP		= 0x1021,
	PLAYER_ACTION_ATTACK_DOWN	= 0x1022,
	PLAYER_ACTION_ATTACK_LEFT	= 0x1023,
	PLAYER_ACTION_ATTACK_RIGHT	= 0x1024,


	PLAYER_ACTION_DIE		= 0x1fff,
}

function CoDPlayer:new(id, pname)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self


	local sprt = cc.Sprite:create()
	sprt:setAnchorPoint(0.5, 0)
	sprt:retain()
	obj.sprite = sprt

	obj.face = CoDPlayer.PLAYER_FACE_DOWN

	obj.dead = false

	obj.state = CoDPlayer.PLAYER_STATE_OCCUPIED
	obj.name = pname

	local nameLabel = cc.LabelTTF:create(pname, "Arial", 12)
	nameLabel:setAnchorPoint(0.5, 0.0)
	--local lbsize = nameLabel:getContentSize()
	nameLabel:setPosition(0, -20)
	obj.sprite:addChild(nameLabel)

	obj.chatLabel = cc.LabelTTF:create('', "Arial", 12)
	obj.chatLabel:setAnchorPoint(0.5, 0.0)
	obj.chatLabel:setPosition(0, 60)
	obj.sprite:addChild(obj.chatLabel)

	obj.stateLabel = cc.LabelTTF:create('',"Arial", 12)
	obj.stateLabel:setAnchorPoint(0.5, 0.0)
	obj.stateLabel:setPosition(0, 35)
	obj.sprite:addChild(obj.stateLabel)

	obj.velocity = 50
	obj.playerID = id

	obj.hp = 100
	obj.mp = 100

	obj.path = {}

	return obj
end

function CoDPlayer:showChat(txt)
	self.chatLabel:setString(txt)
	self.chatLabel:stopActionByTag(1)
	self.chatLabel:setPosition(0,45)
	local function resetText(sender, values)
		sender:setString('')
	end
	local actionSeq = {}
	local moveAct = cc.MoveTo:create(0.5, cc.p(0, 60))
	local delay = cc.DelayTime:create(2.0)
	local callback = cc.CallFunc:create(resetText, {})
	table.insert(actionSeq, moveAct)
	table.insert(actionSeq, delay)
	table.insert(actionSeq, callback)
	local seq = cc.Sequence:create(actionSeq)
	seq:setTag(1)
	self.chatLabel:runAction(seq)

end

function CoDPlayer:showDamage(val)
	self.stateLabel:setString(string.format('- %d', val))
	self.stateLabel:stopActionByTag(0)
	self.stateLabel:setPosition(0,35)
	local function resetText(sender, values)
		sender:setString('')
	end
	local actionSeq = {}
	local moveAct = cc.MoveTo:create(0.5, cc.p(0, 45))
	local delay = cc.DelayTime:create(2.0)
	local callback = cc.CallFunc:create(resetText, {})
	table.insert(actionSeq, moveAct)
	table.insert(actionSeq, delay)
	table.insert(actionSeq, callback)
	local seq = cc.Sequence:create(actionSeq)
	seq:setTag(0)
	self.stateLabel:runAction(seq)

end

function CoDPlayer:showHealth(hp, mp)
	if hp == 0 and mp ~= 0 then
		self.stateLabel:setString(string.format('+ %d MP', mp))
	elseif hp ~= 0 and mp == 0 then
		self.stateLabel:setString(string.format('+ %d HP', hp))
	else
		self.stateLabel:setString(string.format('+ %d HP, + %d MP', hp, mp))
	end

	self.stateLabel:stopActionByTag(0)
	self.stateLabel:setPosition(0,35)
	local function resetText(sender, values)
		sender:setString('')
	end
	local actionSeq = {}
	local moveAct = cc.MoveTo:create(0.5, cc.p(0, 45))
	local delay = cc.DelayTime:create(2.0)
	local callback = cc.CallFunc:create(resetText, {})
	table.insert(actionSeq, moveAct)
	table.insert(actionSeq, delay)
	table.insert(actionSeq, callback)
	local seq = cc.Sequence:create(actionSeq)
	seq:setTag(0)
	self.stateLabel:runAction(seq)

end


function CoDPlayer:getPlayerID()
	return self.id
end

function CoDPlayer:isDead()
	return self.dead
end

function CoDPlayer:setDead(flag)
	self.dead = flag
end

function CoDPlayer:getPosition()
	return self.sprite:getPosition()
end

function CoDPlayer:setPosition(x, y)
	self.sprite:setPosition(x, y)
end


function CoDPlayer:receiveDamage(value)
	-- run action.
	self:showDamage(value)
end

function CoDPlayer:attack(x, y)
end

function CoDPlayer:doAction(actionID)
	if actionID == CoDPlayer.PLAYER_ACTION_DIE then 
		cclog('i die')
	end
end

function CoDPlayer:setHP(hp)
	self.hp = hp
end

function CoDPlayer:getHP()
	return self.hp
end

function CoDPlayer:setMP(mp)
	self.mp = mp
end

function CoDPlayer:getMP()
	return self.mp
end

function CoDPlayer:getSprite()
	return self.sprite
end

function CoDPlayer:getPlayerName()
	return self.name
end

function CoDPlayer:getPlayerID()
	return self.playerID
end

CoDPlayerLiddell = {
	
}
setmetatable(CoDPlayerLiddell, CoDPlayer)

function CoDPlayerLiddell:new(id, pname)
	local obj = {} 
	obj = CoDPlayer:new(id, pname, motionHandler) 	-- super
	setmetatable(obj, CoDPlayerLiddell) 
	self.__index = self

	local animCache = cc.AnimationCache:getInstance()

	local runDownFrames = {}
	for i = 3, 6 do
		local str = string.format('character/Liddell/run_down/0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,36,44))
		table.insert(runDownFrames,frame)
	end
	local runDownAnim = cc.Animation:createWithSpriteFrames(runDownFrames, 0.2)
	animCache:addAnimation(runDownAnim, 'Liddell_run_down')

	local runLeftFrames = {}
	for i = 3, 6 do
		local str = string.format('character/Liddell/run_left/0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,32,48))
		table.insert(runLeftFrames, frame)
	end
	local runLeftAnim = cc.Animation:createWithSpriteFrames(runLeftFrames, 0.2)
	animCache:addAnimation(runLeftAnim, 'Liddell_run_left')

	local runUpFrames = {}
	for i = 3, 6 do
		local str = string.format('character/Liddell/run_up/0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,38,48))
		table.insert(runUpFrames, frame)
	end
	local runUpAnim = cc.Animation:createWithSpriteFrames(runUpFrames, 0.2)
	animCache:addAnimation(runUpAnim, 'Liddell_run_up')
	
	local runRightFrames = {}
	for i = 3, 6 do
		local str = string.format('character/Liddell/run_right/0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,32,48))
		table.insert(runRightFrames, frame)
	end
	local runRightAnim = cc.Animation:createWithSpriteFrames(runRightFrames, 0.2)
	animCache:addAnimation(runRightAnim, 'Liddell_run_right')

	--- atk

	local atkDownFrames = {}
	for i = 3, 6 do
		local str = string.format('character/Liddell/atk_down/0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,38,48))
		table.insert(atkDownFrames,frame)
	end
	local atkDownAnim = cc.Animation:createWithSpriteFrames(atkDownFrames, 0.2)
	animCache:addAnimation(atkDownAnim, 'Liddell_atk_down')

	local atkLeftFrames = {}
	for i = 3, 6 do
		local str = string.format('character/Liddell/atk_left/0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,34,49))
		table.insert(atkLeftFrames, frame)
	end
	local atkLeftAnim = cc.Animation:createWithSpriteFrames(atkLeftFrames, 0.2)
	animCache:addAnimation(atkLeftAnim, 'Liddell_atk_left')

	local atkUpFrames = {}
	for i = 3, 6 do
		local str = string.format('character/Liddell/atk_up/0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,39,48))
		table.insert(atkUpFrames, frame)
	end
	local atkUpAnim = cc.Animation:createWithSpriteFrames(atkUpFrames, 0.2)
	animCache:addAnimation(atkUpAnim, 'Liddell_atk_up')
	
	local atkRightFrames = {}
	for i = 3, 6 do
		local str = string.format('character/Liddell/atk_right/0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,34,49))
		table.insert(atkRightFrames, frame)
	end
	local atkRightAnim = cc.Animation:createWithSpriteFrames(atkRightFrames, 0.2)
	animCache:addAnimation(atkRightAnim, 'Liddell_atk_right')

	--- rest
	local rstDown = cc.SpriteFrame:create('character/Liddell/rest/0.png', cc.rect(0,0,36,48))
	local rstDownAnim = cc.Animation:createWithSpriteFrames({rstDown}, 0.2)
	animCache:addAnimation(rstDownAnim, 'Liddell_rst_down')

	local rstLeft = cc.SpriteFrame:create('character/Liddell/rest/1.png', cc.rect(0,0,30,48))
	local rstLeftAnim = cc.Animation:createWithSpriteFrames({rstLeft}, 0.2)
	animCache:addAnimation(rstLeftAnim, 'Liddell_rst_left')

	local rstUp = cc.SpriteFrame:create('character/Liddell/rest/2.png', cc.rect(0,0,36,48))	
	local rstUpAnim = cc.Animation:createWithSpriteFrames({rstUp}, 0.2)
	animCache:addAnimation(rstUpAnim, 'Liddell_rst_up')

	local rstRight = cc.SpriteFrame:create('character/Liddell/rest/3.png', cc.rect(0,0,30,48))
	local rstRightAnim = cc.Animation:createWithSpriteFrames({rstRight}, 0.2)
	animCache:addAnimation(rstRightAnim, 'Liddell_rst_right')





	--local restAct = cc.Animate:create(animCache:getAnimation('Liddell_rst_down'))
	--restAct:setTag(CoDPlayer.PLAYER_STATE_OCCUPIED)
	obj.sprite:setAnchorPoint(0.5, 0)
	obj.sprite:setPosition(50, 50)
	--obj.sprite:runAction(cc.RepeatForever:create(restAct))
	obj:stop()
	return obj
end

function CoDPlayerLiddell:playRunAnimation(px, py, nx, ny)
	local newFace = nil
	if math.abs(nx-px) > math.abs(ny-py) then
		if nx > px then
			newFace = CoDPlayer.PLAYER_FACE_RIGHT
		else
			newFace = CoDPlayer.PLAYER_FACE_LEFT
		end
	else 
		if ny > py then
			newFace = CoDPlayer.PLAYER_FACE_UP
		else
			newFace = CoDPlayer.PLAYER_FACE_DOWN
		end
	end

	if self.face == newFace  and self.state == CoDPlayer.PLAYER_STATE_OCCUPIED then
		return
	end
	local animCache = cc.AnimationCache:getInstance()
	local anim = nil
	if newFace == CoDPlayer.PLAYER_FACE_LEFT then
		anim = animCache:getAnimation('Liddell_run_left')
	elseif newFace == CoDPlayer.PLAYER_FACE_UP then
		anim = animCache:getAnimation('Liddell_run_up')
	elseif newFace == CoDPlayer.PLAYER_FACE_RIGHT then
		anim = animCache:getAnimation('Liddell_run_right')
	else
		anim = animCache:getAnimation('Liddell_run_down')
	end
	self.face = newFace
	local runAnim = cc.Animate:create(anim)
	local runAct = cc.RepeatForever:create(runAnim)
	runAct:setTag(CoDPlayer.PLAYER_STATE_OCCUPIED)
	self.sprite:stopActionByTag(CoDPlayer.PLAYER_STATE_OCCUPIED)
	self.sprite:runAction(runAct)
	self.state = CoDPlayer.PLAYER_STATE_OCCUPIED
end

function CoDPlayerLiddell:stop()
	local animCache = cc.AnimationCache:getInstance()
	local anim = nil
	if self.face == CoDPlayer.PLAYER_FACE_LEFT then
		anim = animCache:getAnimation('Liddell_rst_left')
	elseif self.face == CoDPlayer.PLAYER_FACE_UP then
		anim = animCache:getAnimation('Liddell_rst_up')
	elseif self.face == CoDPlayer.PLAYER_FACE_RIGHT then
		anim = animCache:getAnimation('Liddell_rst_right')
	else
		anim = animCache:getAnimation('Liddell_rst_down')
	end
	local runAnim = cc.Animate:create(anim)
	local runAct = cc.RepeatForever:create(runAnim)
	runAct:setTag(CoDPlayer.PLAYER_STATE_OCCUPIED)
	self.sprite:stopActionByTag(CoDPlayer.PLAYER_STATE_OCCUPIED)
	self.sprite:runAction(runAct)
	self.state = CoDPlayer.PLAYER_STATE_STOP
end

function CoDPlayerLiddell:attack(nx, ny)
	local animCache = cc.AnimationCache:getInstance()
	local px, py = self:getPosition()
	local newFace = nil
	if math.abs(nx-px) > math.abs(ny-py) then
		if nx > px then
			newFace = CoDPlayer.PLAYER_FACE_RIGHT
		else
			newFace = CoDPlayer.PLAYER_FACE_LEFT
		end
	else 
		if ny > py then
			newFace = CoDPlayer.PLAYER_FACE_UP
		else
			newFace = CoDPlayer.PLAYER_FACE_DOWN
		end
	end
	self.face = newFace
	if self.face == CoDPlayer.PLAYER_FACE_LEFT then
		anim = animCache:getAnimation('Liddell_atk_left')
	elseif self.face == CoDPlayer.PLAYER_FACE_UP then
		anim = animCache:getAnimation('Liddell_atk_up')
	elseif self.face == CoDPlayer.PLAYER_FACE_RIGHT then
		anim = animCache:getAnimation('Liddell_atk_right')
	else
		anim = animCache:getAnimation('Liddell_atk_down')
	end
	self.sprite:stopActionByTag(CoDPlayer.PLAYER_STATE_OCCUPIED)
	local actionSeq = {}
	local atkAnim = cc.Animate:create(anim)
	table.insert(actionSeq, atkAnim)
	local stopCallback = cc.CallFunc:create(
		function ()
			self:stop()
		end)
	table.insert(actionSeq, stopCallback)
	local seq = cc.Sequence:create(actionSeq)
	seq:setTag(CoDPlayer.PLAYER_STATE_OCCUPIED)
	self.sprite:runAction(seq)
end

function CoDPlayerLiddell:move(path)
	if path == nil then 
		return
	end
	if #path == 0 then 
		return 
	end


	local actionSeq = {}
	local preX, preY = self:getPosition()
	for i = 1, #path, 1 do
		local nxtX, nxtY = path[i].x, path[i].y
		local x1, y1, x2, y2
		x1 = preX
		x2 = nxtX
		y1 = preY
		y2 = nxtY
		local slice = cc.Sequence:create(
			cc.CallFunc:create(function()
				self:playRunAnimation(x1, y1, x2, y2)
			end),
			cc.MoveTo:create(24/self.velocity, cc.p(nxtX, nxtY))
			)
		preX, preY = nxtX, nxtY
		table.insert(actionSeq, slice)
	end
	local stopCallback = cc.CallFunc:create(
		function ()
			self:stop()
		end)
	table.insert(actionSeq, stopCallback)
	local seq = cc.Sequence:create(actionSeq)
	seq:setTag(CoDPlayer.PLAYER_ACTION_MOVE_SEQUENCE)
	self.sprite:stopActionByTag(CoDPlayer.PLAYER_ACTION_MOVE_SEQUENCE)
	self.sprite:runAction(seq)


end
