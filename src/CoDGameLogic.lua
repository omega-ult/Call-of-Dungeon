require "Cocos2d"
require "Cocos2dConstants"


-- test
require 'CoDNetClient'
require 'CoDNetMessage'
require 'CoDLoginScene'

GAME_SCENE_LOGIN = 0
GAME_SCENE_GAMING = 1


--local gameLobby = gameLobby
CoDGameDirector = {
}

function CoDGameDirector:new()
	local ret = ret or {}
	setmetatable(ret, self)
	self.__index = self

	ret._gameScene = GAME_SCENE_LOGIN
	ret._netClient = CoDNetClient:new()

	ret._loginScene = CoDLogin:new()


	ret._isLoggedIn = false
	return ret
end

function CoDGameDirector:initialize()
	self._netClient:connect("127.0.0.1", 10305)
	self._netClient:noDelay(true)


	if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(self._loginScene:getScene())
	else
		cc.Director:getInstance():runWithScene(self._loginScene:getScene())
	end

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
        self:login()
    end

	local listener = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
	listener:registerScriptHandler(onLoginButtonTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onLoginButtonTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = self._loginScene:getLayer():getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._loginScene:getLoginButton())

	self._gameScene = GAME_SCENE_LOGIN
end

function CoDGameDirector:login()
	if self._isLoggedIn == false then
		-- test 
		local msgtest = CoDNetMSG_PlayerLogin:new()
		local acc = self._loginScene:getAccountInput()
		local pwd = self._loginScene:getPasswordInput()
		local pkgMsg = msgtest:packMessage(acc,pwd)
		self._netClient:send(pkgMsg)
	end
end


function CoDGameDirector:update()
	self._netClient:process()
	local msg = self._netClient:recv()
	while msg ~= '' do
		local hmsg, str = CoDNetMessage.parseMessage(msg)
		if hmsg == CoDNetMessage.MSG_SC_WELCOME then
			self:onServerWelcome(str)
		else
		end
		msg = self._netClient:recv()
	end

end

function CoDGameDirector:onServerWelcome(msg)
	local _rmsg = CoDNetMSG_ServerWelcome:new()
	_rmsg:unpackMessage(msg)
	cclog(_rmsg.welcomeMsg)

end

gameDirector = CoDGameDirector:new()
gameDirector:initialize()

local function tick()
	gameDirector:update()
end
cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
