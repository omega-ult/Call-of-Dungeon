require "Cocos2d"
require "Cocos2dConstants"


-- test
require 'CoDNetClient'
require 'CoDNetMessage'
require 'CoDLoginScene'
require 'CoDGameScene'
require 'CoDCharacterScene'

GAME_SCENE_LOGIN = 0
GAME_SCENE_CHARACTER = 1
GAME_SCENE_GAMING = 2


--local gameLobby = gameLobby
CoDGameDirector = {
}

function CoDGameDirector:new()
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj._gameState = GAME_SCENE_LOGIN
	obj._netClient = CoDNetClient:new()

	obj._loginScene = CoDLoginScene:new(obj)
	obj._gameScene = nil
	obj._characterScene = nil
	return obj
end

function CoDGameDirector:initialize()
	self._netClient:connect("127.0.0.1", 10305)
	self._netClient:noDelay(true)


	if cc.Director:getInstance():getRunningScene() then
		cc.Director:getInstance():replaceScene(self._loginScene:getScene())
	else
		cc.Director:getInstance():runWithScene(self._loginScene:getScene())
	end

	self._gameState = GAME_SCENE_LOGIN
end


function CoDGameDirector:update()
	self._netClient:process()
	local msg = self._netClient:recv()
	while msg ~= '' do
		local hmsg, str = CoDNetMessage.parseMessage(msg)
		if self._gameState == GAME_SCENE_LOGIN then
			-- game login scene.
			if hmsg == CoDNetMessage.MSG_SC_WELCOME then
				self:onServerWelcome(str)
			elseif hmsg == CoDNetMessage.MSG_SC_LOGIN_CONFIRM then
				self:onLoginConfirm(str)
			end
		elseif self._gameState == GAME_SCENE_CHARACTER then
			-- character scene
			if hmsg == CoDNetMessage.MSG_SC_CHARACTER_DATA then
				self:onReceiveCharacterData(str)
			elseif hmsg == CoDNetMessage.MSG_SC_ENTER_CONFIRM then
				self:onEnterConfirm(str)
			end
		elseif self._gameState == GAME_SCENE_GAMING then
			-- gaming scene 
			if hmsg == CoDNetMessage.MSG_SC_NEW_PLAYER_ENTER then
				self:onNewPlayerEnter(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_EXIT then
				self:onPlayerExit(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_STATE then
				self:onNotifyPlayerState(str)
			elseif hmsg == CoDNetMessage.MSG_SC_MONSTER_STATE then
				self:onNotifyMonsterState(str)
			elseif hmsg == CoDNetMessage.MSG_SC_ITEM_STATE then
				self:onNotifyItemState(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_RECEIVE_ITEM then
				self:onPlayerReceiveItem(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_RECEIVE_EFFECT then
				self:onPlayerReceiveEffect(str)
			elseif hmsg == CoDNetMessage.MSG_SC_MONSTER_DO_ACTION then
				self:onMonsterDoAction(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_HURT then
				self:onPlayerHurt(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_DIE then
				self:onPlayerDie(str)
			elseif hmsg == CoDNetMessage.MSG_SC_CHAT then
				self:onPlayerReceiveChat(str)
			elseif hmsg == CoDNetMessage.MSG_SC_MONSTER_HURT then
				self:onMonsterHurt(str)		
			elseif hmsg == CoDNetMessage.MSG_SC_MONSTER_DIE then
				self:onMonsterDie(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_PERFORM_FIRE_BALL then
				self:onPlayerFireBallPerformed(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_PERFORM_DEAD_ZONE then
				self:onPlayerDeadZonePerformed(str)
			elseif hmsg == CoDNetMessage.MSG_SC_PLAYER_WIN then
				self:onPlayerWin()
			end

		end
		msg = self._netClient:recv()
	end

	if self._gameState == GAME_SCENE_GAMING then
		self._gameScene:update()
	end
end

function CoDGameDirector:syncState()
	if self._gameState == GAME_SCENE_GAMING then
		self._gameScene:syncServer()
	end
end

---------------------------------------------------------------
-- called by game scenes
function CoDGameDirector:login(acc, pwd)
	if self._gameState == GAME_SCENE_LOGIN then
		-- test 
		local msgtest = CoDNetMSG_PlayerLogin:new()
		local acc = self._loginScene:getAccountInput()
		local pwd = self._loginScene:getPasswordInput()
		local pkgMsg = msgtest:packMessage(acc,pwd)
		-- test only
		--local pkgMsg = msgtest:packMessage('netease0', '163')
		self._netClient:send(pkgMsg)
		self._loginScene:enterLoggingState()
	end
end

function CoDGameDirector:tryEnter(actorID)
	if self._gameState == GAME_SCENE_CHARACTER then
		local _msg = CoDNetMSG_TryEnter:new(actorID)
		self._netClient:send(_msg.msg)
	end
end

function CoDGameDirector:playerDoAttack(playerID, monsterSeed)
	if self._gameState == GAME_SCENE_GAMING then
		local _msg = CoDNetMSG_PlayerAttack:new(playerID, monsterSeed)
		self._netClient:send(_msg.msg)
	end
end

function CoDGameDirector:playerGetItem(playerID, itemSeed)
	if self._gameState == GAME_SCENE_GAMING then
		local _msg = CoDNetMSG_PlayerGetItem:new(playerID, itemSeed)
		self._netClient:send(_msg.msg)
	end
end

function CoDGameDirector:playerChat(playerID, msg)
	if self._gameState == GAME_SCENE_GAMING then
		local _msg = CoDNetMSG_PlayerChat:new(playerID, msg)
		self._netClient:send(_msg.msg)
	end

end

function CoDGameDirector:playerUseItem(playerID, itemSeed)
	if self._gameState == GAME_SCENE_GAMING then
		local _msg = CoDNetMSG_PlayerUseItem:new(playerID, itemSeed)
		self._netClient:send(_msg.msg)
	end
end

function CoDGameDirector:playerPerformFireBall(playerID, monSeed)
	if self._gameState == GAME_SCENE_GAMING then
		local _msg = CoDNetMSG_PlayerUseFireBall:new(playerID, monSeed)
		self._netClient:send(_msg.msg)
	end
end


function CoDGameDirector:playerPerformDeadZone(playerID)
	if self._gameState == GAME_SCENE_GAMING then
		local _msg = CoDNetMSG_PlayerUseDeadZone:new(playerID)
		self._netClient:send(_msg.msg)
	end
end



function CoDGameDirector:syncPlayerState(data)
	if self._gameState == GAME_SCENE_GAMING then
		local _msg = CoDNetMSG_PlayerStateReport:new(data)
		self._netClient:send(_msg.msg)
	end
end




--------------------------------------------------------------------
-- called by self, mostly on receiving data.
function CoDGameDirector:onLoginConfirm(msg)
	local _rmsg = CoDNetMSG_PlayerLoginConfirm:new(msg)
	self.pHID = _rmsg.pHID

	self._gameState = GAME_SCENE_CHARACTER
	cclog(_rmsg.msg)
	-- should change to character scene.
	self._characterScene = CoDCharacterScene:new(self)
	cc.Director:getInstance():replaceScene(self._characterScene:getScene())

end

function CoDGameDirector:onServerWelcome(msg)
	local _rmsg = CoDNetMSG_ServerWelcome:new()
	_rmsg:unpackMessage(msg)
	cclog(_rmsg.welcomeMsg)
end

function CoDGameDirector:onReceiveCharacterData(msg)
	local _data = CoDNetMSG_CharacterData:new(msg)
	self._characterScene:loadCharacter(_data)
end

function CoDGameDirector:onEnterConfirm(msg)
	cclog('enter confirmed.')
	local _data = CoDNetMSG_PlayerEnterConfirmData:new(msg)
	self._gameScene = CoDGameScene:new(self, _data)
	self._gameScene:update()
	self._gameState = GAME_SCENE_GAMING
	cc.Director:getInstance():replaceScene(self._gameScene:getScene())

end

function CoDGameDirector:onNewPlayerEnter(msg)
	local _data = CoDNetMSG_NewPlayerEnter:new(msg)
	self._gameScene:handleNewPlayerEnter(_data)
end

function CoDGameDirector:onPlayerExit(msg)
	local _data = CoDNetMSG_PlayerExit:new(msg)
	self._gameScene:handlePlayerExit(_data.playerID)
end

function CoDGameDirector:onNotifyPlayerState(msg)
	local _data = CoDNetMSG_PlayerStateNotification:new(msg)
	self._gameScene:handlePlayerStateNotification(_data.cdata)
end

function CoDGameDirector:onNotifyMonsterState(msg)
	local _data = CoDNetMSG_MonsterStateNotification:new(msg)
	self._gameScene:handleMonsterStateNotification(_data.cdata)
end

function CoDGameDirector:onNotifyItemState(msg)
	local _data = CoDNetMSG_ItemStateNotification:new(msg)
	self._gameScene:handleItemStateNotification(_data.cdata)
end

function CoDGameDirector:onMonsterDoAction(msg)
	local _data = CoDNetMSG_MonsterDoAction:new(msg)
	self._gameScene:handleMonsterAction(_data)
end

function CoDGameDirector:onPlayerHurt(msg)
	local _data = CoDNetMSG_PlayerHurt:new(msg)
	self._gameScene:handlePlayerHurt(_data)
end

function CoDGameDirector:onMonsterHurt(msg)
	local _data = CoDNetMSG_MonsterHurt:new(msg)
	self._gameScene:handleMonsterHurt(_data)
end

function CoDGameDirector:onPlayerDie(msg)
	local _data = CoDNetMSG_PlayerDie:new(msg)
	self._gameScene:handlePlayerDie(_data.playerID)
end

function CoDGameDirector:onPlayerReceiveItem(msg)
	local _data = CoDNetMSG_PlayerReceiveItem:new(msg)
	self._gameScene:handlePlayerReceiveItem(_data)
end

function CoDGameDirector:onMonsterDie(msg)
	local _data = CoDNetMSG_MonsterDie:new(msg)
	self._gameScene:handleMonsterDie(_data.seed)
end

function CoDGameDirector:onPlayerReceiveChat(msg)
	local _data = CoDNetMSG_ReceivePlayerChat:new(msg)
	self._gameScene:handlePlayerChat(_data)
end

function CoDGameDirector:onPlayerReceiveEffect(msg)
	local _data = CoDNetMSG_PlayerReceiveEffect:new(msg)
	self._gameScene:handlePlayerReceiveEffect(_data)
end

function CoDGameDirector:onPlayerFireBallPerformed(msg)
	local _data = CoDNetMessage_PlayerFireBallPerformed:new(msg)
	self._gameScene:handleFireBallPerformed(_data)
end

function CoDGameDirector:onPlayerDeadZonePerformed(msg)
	local _data = CoDNetMessage_PlayerDeadZonePerformed:new(msg)
	self._gameScene:handleDeadZonePerformed(_data)
end

function CoDGameDirector:onPlayerWin()
	if self._gameState == GAME_SCENE_GAMING then
		self._gameScene:handleGameWin()
	end
end

-- Game entry------------------------------------------------------------------
gameDirector = CoDGameDirector:new()
gameDirector:initialize()

local function updateSceneTick()
	gameDirector:update()
end
cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateSceneTick, 0, false)

local function syncServerTick()
	gameDirector:syncState()
end
cc.Director:getInstance():getScheduler():scheduleScriptFunc(syncServerTick, 0.1, false)