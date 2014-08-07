require "Cocos2d"
require "Cocos2dConstants"

local gameLogic = GameLogic:getInstance()
cclog("game logic"..gameLogic:boooooo())



local structLib = require "struct"

-- test
require 'CoDNetClient'


local ntwk = CoDNetClient:new()
ntwk:connect("127.0.0.1", 10305)


local function tick()
	ntwk:process()
end
cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)
