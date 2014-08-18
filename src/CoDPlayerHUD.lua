require "Cocos2d"
require "Cocos2dConstants"

require 'CoDItem'

CoDPlayerHUD = {
	
}

function CoDPlayerHUD:new(gameScene)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.hpVal = 0
	self.mpVal = 0

	obj.itmList = {}
	obj.skillList = {}

	obj.layer = cc.Layer:create()
	obj.layer:setPosition(0, 0)
	obj.layer:retain()

	local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
	obj.hpLabel = cc.LabelTTF:create('HP:', "Arial", 20)
	obj.hpLabel:setPosition(origin.x + 30, origin.y + visibleSize.height - 30)
	obj.layer:addChild(obj.hpLabel)

	obj.hpVal = cc.LabelTTF:create('0', "Arial", 20)
	obj.hpVal:setPosition(origin.x + 65, origin.y + visibleSize.height - 30)
	obj.layer:addChild(obj.hpVal)

	obj.mpLabel = cc.LabelTTF:create('MP:', "Arial", 20)
	obj.mpLabel:setPosition(origin.x + 130, origin.y + visibleSize.height - 30)
	obj.layer:addChild(obj.mpLabel)

	obj.mpVal = cc.LabelTTF:create('0', "Arial", 20)
	obj.mpVal:setPosition(origin.x + 165, origin.y + visibleSize.height - 30)
	obj.layer:addChild(obj.mpVal)

	obj.atkBtn = cc.Sprite:create("attackBtn.png")
	obj.atkBtn:setPosition(origin.x + visibleSize.width - 70, origin.y +  65)
	obj.layer:addChild(obj.atkBtn)

	obj.itmBtnA = cc.Sprite:create('itemABG.png')
	obj.itmBtnA:setPosition(origin.x + visibleSize.width - 175, origin.y +  30)
	obj.layer:addChild(obj.itmBtnA)
	obj.itmIconA = cc.Sprite:create('item/hp.png')
	obj.itmIconA:setPosition(origin.x + visibleSize.width - 175, origin.y +  30)
	obj.layer:addChild(obj.itmIconA)
	obj.itmCntA = cc.LabelTTF:create('0', 'Arial', 12)
	obj.itmCntA:setPosition(origin.x + visibleSize.width - 185, origin.y +  15)
	obj.layer:addChild(obj.itmCntA)

	obj.itmBtnB = cc.Sprite:create('itemBBG.png')
	obj.itmBtnB:setPosition(origin.x + visibleSize.width - 125, origin.y +  30)
	obj.layer:addChild(obj.itmBtnB)
	obj.itmIconB = cc.Sprite:create('item/mp.png')
	obj.itmIconB:setPosition(origin.x + visibleSize.width - 125, origin.y +  30)
	obj.layer:addChild(obj.itmIconB)
	obj.itmCntB = cc.LabelTTF:create('0', 'Arial', 12)
	obj.itmCntB:setPosition(origin.x + visibleSize.width - 135, origin.y +  15)
	obj.layer:addChild(obj.itmCntB)

	obj.sklBtnA = cc.Sprite:create('skillABG.png')
	obj.sklBtnA:setPosition(origin.x + visibleSize.width - 40, origin.y +  175)
	obj.layer:addChild(obj.sklBtnA)

	obj.sklBtnB = cc.Sprite:create('skillBBG.png')
	obj.sklBtnB:setPosition(origin.x + visibleSize.width - 40, origin.y +  125)
	obj.layer:addChild(obj.sklBtnB)


	-- chat input.
	local editBoxSize = cc.size(200, 20)
	obj.chatInput = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create("white_edit.png"))
	obj.chatInput:setPosition(origin.x + 120, 60)
	obj.layer:addChild(obj.chatInput)

	obj.sendBtn = cc.Sprite:create('send.png')
	obj.sendBtn:setPosition(origin.x + 250, 60)
	obj.layer:addChild(obj.sendBtn)

	-- initialize touch event handler.
	local function onHUDButtonTouchBegan(touch, event)
        local target = event:getCurrentTarget()

        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        if cc.rectContainsPoint(rect, locationInNode) then
            target:setOpacity(180)
            return true
        end
        return false
    end


    local function onHUDButtonTouchEnd(touch, event)
        local target = event:getCurrentTarget()
        --print("sprite onTouchesEnded..")
        target:setOpacity(255)
        if target == obj.atkBtn then
        	gameScene:onPlayerAttack()
        end
        if target == obj.itmBtnA then
        	gameScene:onPlayerUseItemA()
        end
        if target == obj.itmBtnB then
        	gameScene:onPlayerUseItemB()
        end
        if target == obj.sklBtnA then
        	gameScene:onPlayerUseSkillA()
        end
        if target == obj.sklBtnB then
        	gameScene:onPlayerUseSkillB()
        end
        if target == obj.sendBtn then
        	gameScene:onPlayerChat(obj.chatInput:getText())
        end
    end

	local listenerAtk = cc.EventListenerTouchOneByOne:create()
	listenerAtk:setSwallowTouches(true)
	listenerAtk:registerScriptHandler(onHUDButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listenerAtk:registerScriptHandler(onHUDButtonTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = obj.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenerAtk, obj.atkBtn)

	local listenerItmA = cc.EventListenerTouchOneByOne:create()
	listenerItmA:setSwallowTouches(true)
	listenerItmA:registerScriptHandler(onHUDButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listenerItmA:registerScriptHandler(onHUDButtonTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = obj.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenerItmA, obj.itmBtnA)

	local listenerItmB = cc.EventListenerTouchOneByOne:create()
	listenerItmB:setSwallowTouches(true)
	listenerItmB:registerScriptHandler(onHUDButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listenerItmB:registerScriptHandler(onHUDButtonTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = obj.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenerItmB, obj.itmBtnB)

	local listenerSklA = cc.EventListenerTouchOneByOne:create()
	listenerSklA:setSwallowTouches(true)
	listenerSklA:registerScriptHandler(onHUDButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listenerSklA:registerScriptHandler(onHUDButtonTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = obj.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenerSklA, obj.sklBtnA)

	local listenerSklB = cc.EventListenerTouchOneByOne:create()
	listenerSklB:setSwallowTouches(true)
	listenerSklB:registerScriptHandler(onHUDButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listenerSklB:registerScriptHandler(onHUDButtonTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = obj.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenerSklB, obj.sklBtnB)

	local listenerSndB = cc.EventListenerTouchOneByOne:create()
	listenerSndB:setSwallowTouches(true)
	listenerSndB:registerScriptHandler(onHUDButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listenerSndB:registerScriptHandler(onHUDButtonTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = obj.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenerSndB, obj.sendBtn)

	return obj
end

function CoDPlayerHUD:getLayer()
	return self.layer
end

function CoDPlayerHUD:updateHP(val)
	self.hpVal:setString(string.format('%d', val))
end

function CoDPlayerHUD:updateMP(val)
	self.mpVal:setString(string.format('%d', val))
end

function CoDPlayerHUD:updateItem(hpcount, mpcount)
	self.itmCntA:setString(string.format('%d', hpcount))
	self.itmCntB:setString(string.format('%d', mpcount))
end

function CoDPlayerHUD:updateSkill(skillIdx, flag)

end