require "Cocos2d"
require "Cocos2dConstants"


CoDGameScene_One = {
	
}

function CoDGameScene_One:new()
	local ret = ret or {}
	setmetatable(ret, self)
	self.__index = self

	local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
	
	ret.gameScene = cc.Scene:create()
	ret.layer = cc.Layer:create()
	local bgpic = cc.Sprite:create("farm.jpg")
	bgpic:setPosition(origin.x + visibleSize.width / 2 + 80, origin.y + visibleSize.height / 2)
	ret.layer:addChild(bgpic)
	ret.gameScene:addChild(ret.layer)

--[[
	-- create button for login
	local lgBtn = cc.Sprite:create("menu1.png")
	ret.loginBtn = lgBtn
	ret.loginBtn:setPosition(origin.x + visibleSize.width / 2 + 120, origin.y + visibleSize.height / 2 - 65)
	ret.layer:addChild(ret.loginBtn)

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
	ret.layer:addChild(accLabel)
	-- create edit box for account input
	local editBoxSize = cc.size(visibleSize.width / 3, 30)
	local accInput = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create("green_edit.png"))
	ret.accountInput = accInput
	ret.accountInput:setPosition(origin.x + visibleSize.width / 2 + 10, origin.y + visibleSize.height / 2 - 50)
	ret.accountInput:setFontSize(25)
	ret.accountInput:setFontColor(cc.c3b(255,255,255))
	--ret.accountInput:setPlaceHolder("Username:")
	--ret.accountInput:setPlaceholderFontColor(cc.c3b(255,255,255))
	ret.accountInput:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	-- Handler
	--ret.accountInput:registerScriptEditBoxHandler(editBoxTextEventHandle)
	ret.layer:addChild(ret.accountInput)



	local pwdLabel = cc.LabelTTF:create('Password',"Arial", 20)
	pwdLabel:setPosition(origin.x + visibleSize.width / 2-120, origin.y + visibleSize.height / 2-80)
	ret.layer:addChild(pwdLabel)
	-- create edit box for password input
	local pwdInput = cc.EditBox:create(editBoxSize, cc.Scale9Sprite:create("green_edit.png"))
	ret.passwordInput = pwdInput
	ret.passwordInput:setPosition(origin.x + visibleSize.width / 2 + 10, origin.y + visibleSize.height / 2 - 80)
    ret.passwordInput:setFontColor(cc.c3b(255,255,255))
    ret.passwordInput:setMaxLength(10)
    ret.passwordInput:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    ret.passwordInput:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	--ret.passwordInput:registerScriptEditBoxHandler(editBoxTextEventHandle)
    ret.layer:addChild(ret.passwordInput)
]]



	return ret
end

function CoDGameScene_One:getScene()
	return self.gameScene
end

function CoDGameScene_One:getLayer()
	return self.layer
end

function CoDGameScene_One:getLoginButton()
	return self.loginBtn
end

function CoDGameScene_One:getAccountInput()
	return self.accountInput:getText()
end

function CoDGameScene_One:getPasswordInput()
	return self.passwordInput:getText()
end

function CoDGameScene_One:enterLoggingState()
end