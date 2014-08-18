require "Cocos2d"
require "Cocos2dConstants"


CoDLoginScene = {
	
}

function CoDLoginScene:new(gameDirector)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj._gDctr = gameDirector

	local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
	
	obj.loginScene = cc.Scene:create()
	obj.loginScene:retain()
	obj.layer = cc.Layer:create()
	local bgpic = cc.Sprite:create("farm.jpg")
	bgpic:setPosition(origin.x + visibleSize.width / 2 + 80, origin.y + visibleSize.height / 2)
	obj.layer:addChild(bgpic)
	obj.loginScene:addChild(obj.layer )


	-- create button for login
	local lgBtn = cc.Sprite:create("menu1.png")
	obj.loginBtn = lgBtn
	obj.loginBtn:setPosition(origin.x + visibleSize.width / 2 + 120, origin.y + visibleSize.height / 2 - 65)
	obj.layer:addChild(obj.loginBtn)

	local logo = cc.Sprite:create('logo.png')
	obj.logo = logo
	obj.logo:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height / 2 + 55)
	obj.layer:addChild(obj.logo)

	--local function editBoxTextEventHandle(strEventName,pSender)
		--local edit = pSender
		--local strFmt 
		--if strEventName == "began" then
		--	strFmt = string.format("editBox %p DidBegin !", edit)
		--	print(strFmt)
		--elseif strEventName == "ended" then
		--	strFmt = string.format("editBox %p DidEnd !", edit)
		--	print(strFmt)
		--elseif strEventName == "return" then
		--	strFmt = string.format("editBox %p was returned !",edit)
		--	if edit == EditName then
		--		TTFShowEditReturn:setString("Name EditBox return !")
		--	elseif edit == EditPassword then
		--		TTFShowEditReturn:setString("Password EditBox return !")
		--	elseif edit == EditEmail then
		--		TTFShowEditReturn:setString("Email EditBox return !")
		--	end
		--	print(strFmt)
		--elseif strEventName == "changed" then
		--	strFmt = string.format("editBox %p TextChanged, text: %s ", edit, edit:getText())
		--	print(strFmt)
		--end
	--end

	local accLabel = cc.LabelTTF:create('Account',"Arial", 20)
	accLabel:setPosition(origin.x + visibleSize.width / 2-120, origin.y + visibleSize.height / 2-50)
	obj.layer:addChild(accLabel)
	-- create edit box for account input
	local editBoxSize = cc.size(160, 30)
	local accInput = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create("green_edit.png"))
	obj.accountInput = accInput
	obj.accountInput:setPosition(origin.x + visibleSize.width / 2 + 10, origin.y + visibleSize.height / 2 - 50)
	obj.accountInput:setFontSize(25)
	obj.accountInput:setFontColor(cc.c3b(255,255,255))
	--obj.accountInput:setPlaceHolder("Username:")
	--obj.accountInput:setPlaceholderFontColor(cc.c3b(255,255,255))
	obj.accountInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	obj.accountInput:setText('netease0')
	-- Handler
	--obj.accountInput:registerScriptEditBoxHandler(editBoxTextEventHandle)
	obj.layer:addChild(obj.accountInput)



	local pwdLabel = cc.LabelTTF:create('Password',"Arial", 20)
	pwdLabel:setPosition(origin.x + visibleSize.width / 2-120, origin.y + visibleSize.height / 2-80)
	obj.layer:addChild(pwdLabel)
	-- create edit box for password input
	local pwdInput = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create("green_edit.png"))
	obj.passwordInput = pwdInput
	obj.passwordInput:setPosition(origin.x + visibleSize.width / 2 + 10, origin.y + visibleSize.height / 2 - 80)
    obj.passwordInput:setFontColor(cc.c3b(255,255,255))
    obj.passwordInput:setMaxLength(10)
    obj.passwordInput:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    obj.passwordInput:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    obj.passwordInput:setText('163')
	--obj.passwordInput:registerScriptEditBoxHandler(editBoxTextEventHandle)
    obj.layer:addChild(obj.passwordInput)


	-- initialize touch event handler.
	local function onLoginButtonTouchBegan(touch, event)
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


    local function onLoginButtonTouchEnded(touch, event)
        local target = event:getCurrentTarget()
        --print("sprite onTouchesEnded..")
        target:setOpacity(255)
        gameDirector:login(obj.accountInput:getText(), obj.passwordInput:getText())
    end

	local listener = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener:registerScriptHandler(onLoginButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onLoginButtonTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = obj.layer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, obj.loginBtn)



	return obj
end

function CoDLoginScene:getScene()
	return self.loginScene
end

function CoDLoginScene:getLayer()
	return self.layer
end


function CoDLoginScene:getAccountInput()
	return self.accountInput:getText()
end

function CoDLoginScene:getPasswordInput()
	return self.passwordInput:getText()
end

function CoDLoginScene:enterLoggingState()

end