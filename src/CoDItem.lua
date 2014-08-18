require "Cocos2d"
require "Cocos2dConstants"

CoDItem = {
	ITEM_TYPE_HEALTH_POTION		= 0x0001,
	ITEM_TYPE_MANA_POTION		= 0x0002,
}


function CoDItem:new(seed, type)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.seed = seed
	obj.type = type

	obj.sprite = nil
	

	return obj
end

function CoDItem:getIcon()

end

function CoDItem:getType()
	return self.type
end

function CoDItem:getPosition()
	return self.sprite:getPosition()
end

function CoDItem:setPosition(x, y)
	self.sprite:setPosition(x, y)
end

function CoDItem:getSeed()
	return self.seed
end

function CoDItem:getSprite()
	return self.sprite
end

CoDHealthPotion = {
	
}
setmetatable(CoDHealthPotion, CoDItem)

function CoDHealthPotion:new(seed)
	local obj = {} 
	obj = CoDItem:new(seed, ITEM_TYPE_HEALTH_POTION) 	-- super
	setmetatable(obj, CoDHealthPotion) 
	self.__index = self

	local sprt = cc.Sprite:create('item/hp.png')
	sprt:setAnchorPoint(0.5, 0.5)
	sprt:retain()
	obj.sprite = sprt

	return obj
end


CoDManaPotion = {
	
}
setmetatable(CoDManaPotion, CoDItem)

function CoDManaPotion:new(seed)
	local obj = {} 
	obj = CoDItem:new(seed, ITEM_TYPE_MANA_POTION) 	-- super
	setmetatable(obj, CoDManaPotion) 
	self.__index = self

	local sprt = cc.Sprite:create('item/mp.png')
	sprt:setAnchorPoint(0.5, 0.5)
	sprt:retain()
	obj.sprite = sprt

	return obj
end
