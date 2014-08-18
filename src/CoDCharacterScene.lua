require "Cocos2d"
require "Cocos2dConstants"

require "CoDPlayer"


CoDCharacterScene = {
	
}

function CoDCharacterScene:new(gameDirector)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj._gDctr = gameDirector

	obj.characterList = {}

	local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
		
	obj.chrtScene = cc.Scene:create()
	obj.chrtScene:retain()
	obj.layer = cc.Layer:create()
	local bgpic = cc.Sprite:create("farm.jpg")
	bgpic:setPosition(origin.x + visibleSize.width / 2 + 80, origin.y + visibleSize.height / 2)
	obj.layer:addChild(bgpic)
	obj.chrtScene:addChild(obj.layer)

	local bg1 = cc.Scale9Sprite:create("charcterBg.png")
	obj.slot1 = bg1
	bg1:setOpacity(180)
	bg1:setPosition(origin.x + visibleSize.width/2 - 120, origin.y + visibleSize.height / 2 + 20)

	local bg2 = cc.Scale9Sprite:create("charcterBg.png")
	obj.slot2 = bg2
	bg2:setOpacity(180)
	bg2:setPosition(origin.x + visibleSize.width/2 , origin.y + visibleSize.height / 2 + 20)
	
	local bg3 = cc.Scale9Sprite:create("charcterBg.png")
	obj.slot3 = bg3
	bg3:setOpacity(180)
	bg3:setPosition(origin.x + visibleSize.width/2 + 120, origin.y + visibleSize.height / 2 + 20)
	
	obj.layer:addChild(bg1)
	obj.layer:addChild(bg2)
	obj.layer:addChild(bg3)

	-- initialize touch event handler.
	local function onLoginButtonTouchBegan(touch, event)
        local target = event:getCurrentTarget()

        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if cc.rectContainsPoint(rect, locationInNode) then
      		target:setOpacity(255)
            return true
        end
        return false
    end


    local function onLoginButtonTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        if obj.slot1 == target then
        	if obj.characterList[1] ~= nil then
        		obj._gDctr:tryEnter(obj.characterList[1].id)
        	end
        elseif obj.slot2 == target then
        	if obj.characterList[2] ~= nil then
        		obj._gDctr:tryEnter(obj.characterList[2].id)
        	end
        elseif obj.slot3 == target then
        	if obj.characterList[3] ~= nil then
        		obj._gDctr:tryEnter(obj.characterList[3].id)
        	end
        end
        target:setOpacity(180)
    end

	local eventDispatcher = obj.layer:getEventDispatcher()
	local listener1 = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener1:registerScriptHandler(onLoginButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener1:registerScriptHandler(onLoginButtonTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, bg1)

	local listener2 = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener2:registerScriptHandler(onLoginButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener2:registerScriptHandler(onLoginButtonTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener2, bg2)

	local listener3 = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener3:registerScriptHandler(onLoginButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener3:registerScriptHandler(onLoginButtonTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener3, bg3)

	local lbBg1 = cc.Scale9Sprite:create("charcterBg.png")
	lbBg1:setScale(1.0, 0.2)
	lbBg1:setPosition(origin.x + visibleSize.width/2 - 120, origin.y + visibleSize.height / 2 - 60)

	local lbBg2 = cc.Scale9Sprite:create("charcterBg.png")
	lbBg2:setScale(1.0, 0.2)
	lbBg2:setPosition(origin.x + visibleSize.width/2 , origin.y + visibleSize.height / 2 - 60)

	local lbBg3 = cc.Scale9Sprite:create("charcterBg.png")
	lbBg3:setScale(1.0, 0.2)
	lbBg3:setPosition(origin.x + visibleSize.width/2 + 120, origin.y + visibleSize.height / 2 - 60)


	obj.layer:addChild(lbBg1)
	obj.layer:addChild(lbBg2)
	obj.layer:addChild(lbBg3)



	return obj
end

function CoDCharacterScene:getScene()
	return self.chrtScene
end

function CoDCharacterScene:loadCharacter(clist)
	if #clist.cdata == 0 then
		return
	end

	local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()

	for i = 1, #clist.cdata do
		if i > 3 then
			break
		end
		local data = clist.cdata[i]
		local pX = origin.x + visibleSize.width/2 +(i-2) * 120	-- the location x for placing the char.
		local picPath = ''
		if data.type == CoDPlayer.PLAYER_TYPE_LIDDELL then
			picPath = 'character/Liddell/rest/0.png'
		end
		local sp = cc.Sprite:create(picPath)
		sp:setPosition(pX, origin.y + visibleSize.height / 2 + 20)
		self.layer:addChild(sp)
		local nameLabel = cc.Label:createWithTTF(data.nick, 'fonts/Marker Felt.ttf', 20, cc.size(50, 20), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		nameLabel:setAnchorPoint(0.5, 0.0)
		nameLabel:setPosition(pX, visibleSize.height / 2 - 35)
		self.layer:addChild(nameLabel)

		table.insert(self.characterList, data)
	end
	

end