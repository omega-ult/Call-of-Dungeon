require "Cocos2d"
require "Cocos2dConstants"

CoDMonster = {
	MONSTER_TYPE_A			= 0x0001,
	MONSTER_TYPE_B			= 0x0002,

	MONSTER_FACE_UP			= 0x1001,
	MONSTER_FACE_DOWN		= 0x1002,
	MONSTER_FACE_LEFT		= 0x1003,
	MONSTER_FACE_RIGHT		= 0x1004,

	MONSTER_ACTION_MOVE		= 0x1050,
	MONSTER_ACTION_ATTACK	= 0x1051,
	MONSTER_ACTION_DIE		= 0x10ff,
}


function CoDMonster:new(seed)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	local sprt = cc.Sprite:create()
	sprt:setAnchorPoint(0.5, 0)
	sprt:retain()
	obj.sprite = sprt
	


	obj.stateLabel = cc.LabelTTF:create('',"Arial", 12)
	obj.stateLabel:setAnchorPoint(0.5, 0.0)
	obj.stateLabel:setPosition(0, 35)
	obj.sprite:addChild(obj.stateLabel)

	obj.face = CoDMonster.MONSTER_FACE_DOWN

	obj.seed = seed

	obj.velocity = 50
	--local nameLabel = cc.Label:createWithTTF(pname, 'fonts/Marker Felt.ttf', 12, cc.size(50, 20), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	--nameLabel:setAnchorPoint(0.5, 0.0)
	----local lbsize = nameLabel:getContentSize()
	--nameLabel:setPosition(0, -20)
	--obj.sprite:addChild(nameLabel)



	return obj
end


function CoDMonster:showDamage(val)
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

function CoDMonster:showHealth(val)
	self.stateLabel:setString(string.format('+ %d', val))
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


function CoDMonster:getPosition()
	return self.sprite:getPosition()
end

function CoDMonster:setPosition(x, y)
	self.sprite:setPosition(x, y)
end

function CoDMonster:getSeed()
	return self.seed
end

function CoDMonster:getSprite()
	return self.sprite
end

function CoDMonster:doAction(actionID)

end


function CoDMonster:move(path)
	if path == nil then 
		return
	end
	if #path == 0 then
		return
	end

	local function changeFace(sender, values)
		--cclog('%d, %d', values[1], values[2])
	end

	local actionSeq = {}
	for i = 1, #path, 1 do
		local moveAct = cc.MoveTo:create(24/self.velocity, cc.p(path[i].x, path[i].y))
		local callback = cc.CallFunc:create(changeFace, {path[i].x, path[i].y})
		table.insert(actionSeq, moveAct)
		table.insert(actionSeq, callback)
	end
	local seq = cc.Sequence:create(actionSeq)
	seq:setTag(CoDMonster.MONSTER_ACTION_MOVE)
	self.sprite:stopActionByTag(CoDMonster.MONSTER_ACTION_MOVE)
	self.sprite:runAction(seq)

end



CoDMonsterA = {
	
}
setmetatable(CoDMonsterA, CoDMonster)

function CoDMonsterA:new(seed)
	local obj = {} 
	obj = CoDMonster:new(seed) 	-- super
	setmetatable(obj, CoDMonsterA) 
	self.__index = self

	local animFrames = {}

	for i = 3, 5 do
		local str = string.format('character/MonsterA/MonA_0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,32,32))
		animFrames[i] = frame
	end

	local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.2)
	local animate = cc.Animate:create(animation)

	obj.sprite:setAnchorPoint(0.5, 0)
	--obj.sprite:setScale(0.5, 0.5)
	obj.sprite:runAction(cc.RepeatForever:create(animate))

	return obj
end

CoDMonsterB = {
	
}
setmetatable(CoDMonsterB, CoDMonster)

function CoDMonsterB:new(seed)
	local obj = {} 
	obj = CoDMonster:new(seed) 	-- super
	setmetatable(obj, CoDMonsterB) 
	self.__index = self


	local animFrames = {}

	for i = 3, 5 do
		local str = string.format('character/MonsterB/MonB_0%d.png',i)
		local frame = cc.SpriteFrame:create(str, cc.rect(0,0,32,32))
		animFrames[i] = frame
	end

	local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.2)
	local animate = cc.Animate:create(animation)

	obj.sprite:setAnchorPoint(0.5, 0)
	--obj.sprite:setScale(0.5, 0.5)
	obj.sprite:runAction(cc.RepeatForever:create(animate))

	return obj
end
