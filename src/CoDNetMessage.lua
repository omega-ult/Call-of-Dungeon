--[[
Define the messages format between client and server.
]]


local struct = require 'struct'
require 'bit'

CoDNetMessage = {
	MSG_HEADER_SIZE = 2,

	MSG_CS_CONNECT  = 0x0000,
	MSG_SC_WELCOME  = 0x0001,
	MSG_CS_DISCONNECT = 0xffff,

	MSG_CS_LOGIN	= 0x1001,
	MSG_SC_LOGIN_CONFIRM	= 0x1002,
	MSG_CS_TRY_ENTER 		= 0x1003,
	MSG_SC_ENTER_CONFIRM	= 0x1004,
	MSG_SC_CHARACTER_DATA	= 0x20ff,
	MSG_SC_NEW_PLAYER_ENTER	= 0x2002,
	MSG_SC_PLAYER_EXIT		= 0x2003,

	MSG_SC_PLAYER_STATE		= 0x3001,
	MSG_SC_MONSTER_STATE	= 0x3002,
	MSG_SC_ITEM_STATE		= 0x3003,

	MSG_CS_PLAYER_STATE_REPORT		= 0x3101,

	MSG_SC_PLAYER_DO_ACTION		= 0x4001,
	MSG_SC_MONSTER_DO_ACTION 	= 0x4000,

	MSG_CS_PLAYER_DO_ATTACK		= 0x4002,
	MSG_CS_PLAYER_GET_ITEM		= 0x4003,
	MSG_SC_PLAYER_RECEIVE_ITEM	= 0x4004,
	MSG_CS_PLAYER_USE_ITEM		= 0x4005,
	MSG_SC_PLAYER_RECEIVE_EFFECT	= 0x4006,

	MSG_CS_PLAYER_USE_FIRE_BALL  = 0x4100,
	MSG_CS_PLAYER_USE_DEAD_ZONE	= 0x4101,
	MSG_SC_PLAYER_PERFORM_FIRE_BALL  = 0x4fff,
	MSG_SC_PLAYER_PERFORM_DEAD_ZONE = 0x4ffe,

	MSG_CS_CHAT		= 0x5003,
	MSG_SC_CHAT		= 0x5003,

	MSG_SC_PLAYER_HURT	= 0x6001,
	MSG_SC_MONSTER_HURT	= 0x6002,

	MSG_SC_PLAYER_DIE	= 0x6003,
	MSG_SC_MONSTER_DIE	= 0x6004,

	MSG_SC_PLAYER_WIN	= 0x9999,

	-- this function peel off the header from specified message and return the
	-- header, content.
	parseMessage = function(msg)
		if string.len(msg) < 2 then
			return nil
		end
		local msgHeader = struct.unpack('<H', string.sub(msg, 1, CoDNetMessage.MSG_HEADER_SIZE))

		local msgContent = string.sub(msg, 3, #msg)
		return msgHeader, msgContent
	end
}

CoDNetMSG_ServerWelcome = {}
function CoDNetMSG_ServerWelcome:new()
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_WELCOME

	--[[
	packing struct 
	{
		uint32  playerHandle
		uint16  msgLength
		char*   msgStr
	} -- '<I4<Hcn' 
	]] 
	return obj
end

-- the input string should not contains the message header.
function CoDNetMSG_ServerWelcome:unpackMessage(str)
	local curPos = 1
	local strFmt = 'c%d'
	local msgLength = 0
	local msgStr = ''
	msgLength, curPos = struct.unpack('<H', str, curPos)
	--cclog(string.format('%d',string.len(str)))
	msgStr, curPos = struct.unpack(string.format(strFmt, msgLength), str, curPos)

	self.welcomeMsg = msgStr
end

CoDNetMSG_PlayerLogin = {}
function CoDNetMSG_PlayerLogin:new()
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_CS_LOGIN
	--[[
	packing struct 
	{
		ushort  accLength
		char*   accStr
		ushort  pwdLength
		char*   pwdStr
	} -- '<Hcn<Hcn' 
	]] 
	return obj
end

-- this function will pack message header automatically
function CoDNetMSG_PlayerLogin:packMessage(account, pwd)
	self.account = account
	self.password = pwd
	local header = struct.pack('<H', self.msgID)
	local fmt = '<Hc%d<Hc%d'
	fmt = string.format(fmt, #account, #pwd)
	local packStr = struct.pack(fmt, #account, account, #pwd, pwd)
	return header..packStr
	--return struct.pack('')
end

-- the input string should not contains the message header.
function CoDNetMSG_PlayerLogin:unpackMessage(str)
	local curPos = 1
	local strFmt = 'c%d'
	local accLength = 0
	local accStr = ''
	local pwdLength = 0
	local pwdStr = ''
	accLength, curPos = struct.unpack('<H', str, curPos)
	accStr, curPos = struct.unpack(string.format(strFmt, accLength), str, curPos)

	pwdLength, curPos = struct.unpack('<H', str, curPos)
	pwdStr, curPos = struct.unpack(string.format(strFmt, pwdLength), str, curPos)

	self.account = accStr
	self.password = pwdStr
end

CoDNetMSG_PlayerLoginConfirm = {}
function CoDNetMSG_PlayerLoginConfirm:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_LOGIN_CONFIRM
	--[[
	packing struct 
	{
		uint32  pHID
		ushor   msgLen
		char*   msgStr
	} -- '<I<Hcn' 
	]] 
	local curPos = 1
	local strFmt = 'c%d'
	local msgLen = 0

	obj.pHID, curPos = struct.unpack('<I', str, curPos)
	msgLen, curPos = struct.unpack('<H', str, curPos)

	obj.msg, curPos = struct.unpack(string.format(strFmt, msgLen), str, curPos)

	return obj
end

CoDNetMSG_CharacterData = {}
function CoDNetMSG_CharacterData:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	
	obj.msgID = CoDNetMessage.MSG_SC_CHARACTER_DATA

	--	# format like:
	--	#{
	--	#	ushort actorCount
	--	#	{
	--	#		uint32 actorID
	--	#		ushort nameLen
	--	#		char*  name
	--	#		ushort actorType
	--	#	}...
	--	#}
	--	# '<H[<I<H%ds<H]'
	local curPos = 1
	local strFmt = 'c%d'
	obj.cdata = {}
	local ccnt, curPos = struct.unpack('<H', str, curPos)
	for i = 1, ccnt do
		local actor = {}
		actor.id, curPos = struct.unpack('<I', str, curPos)
		local nlen = 0
		nlen, curPos = struct.unpack('<H', str, curPos)
		actor.nick, curPos = struct.unpack(string.format(strFmt, nlen), str, curPos)
		actor.type, curPos = struct.unpack('<H', str, curPos)
		table.insert(obj.cdata, actor)
	end

	return obj
end

CoDNetMSG_TryEnter = {}
function CoDNetMSG_TryEnter:new(actorID)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_CS_TRY_ENTER
	--[[
	packing struct 
	{
		uint32  actorID
	} -- '<I' 
	]] 

	obj.actorID = actorID
	local header = struct.pack('<H', obj.msgID)
	obj.msg = header..struct.pack('<I', obj.actorID)

	return obj
end

CoDNetMSG_PlayerEnterConfirmData = {}
function CoDNetMSG_PlayerEnterConfirmData:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_ENTER_CONFIRM
	--[[
	packing struct 
	{
	#	double serverTime
	#	uint32 playerID
	#	uint32 actorID
	#	ushort nameLen
	#	char*  name
	#	ushort actorType
	#	ushort posX
	#	ushort posY
	#	uint32 HP
	#	uint32 MP
	} -- '<I<Hcn<H<H<H<I<I' 
	]] 
	local curPos = 1
	local strFmt = 'c%d'
	local nameLen = 0

	obj.serverTime, curPos = struct.unpack('d', str, curPos)
	obj.playerID, curPos = struct.unpack('<I', str, curPos)
	obj.actorID, curPos = struct.unpack('<I', str, curPos)
	nameLen, curPos = struct.unpack('<H', str, curPos)
	obj.actorName, curPos = struct.unpack(string.format(strFmt, nameLen), str, curPos)
	obj.actorType, curPos = struct.unpack('<H', str, curPos)
	obj.bornX, curPos = struct.unpack('<H', str, curPos)
	obj.bornY, curPos = struct.unpack('<H', str, curPos)
	obj.HP, curPos = struct.unpack('<I', str, curPos)
	obj.MP, curPos = struct.unpack('<I', str, curPos)

	return obj
end

CoDNetMSG_NewPlayerEnter = {}
function CoDNetMSG_NewPlayerEnter:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_NEW_PLAYER_ENTER
	--[[
	packing struct 
	{
	#	uint32 playerID
	#	uint32 actorID
	#	ushort nameLen
	#	char*  name
	#	ushort actorType
	#	ushort posX
	#	ushort posY
	#	ushort state
	} 
	]] 
	local curPos = 1
	local strFmt = 'c%d'
	local nameLen = 0

	obj.playerID, curPos = struct.unpack('<I', str, curPos)
	obj.actorID, curPos = struct.unpack('<I', str, curPos)
	nameLen, curPos = struct.unpack('<H', str, curPos)
	obj.actorName, curPos = struct.unpack(string.format(strFmt, nameLen), str, curPos)
	obj.actorType, curPos = struct.unpack('<H', str, curPos)
	obj.bornX, curPos = struct.unpack('<H', str, curPos)
	obj.bornY, curPos = struct.unpack('<H', str, curPos)
	obj.state, curPos = struct.unpack('<H', str, curPos)

	return obj
end

CoDNetMSG_PlayerExit = {}
function CoDNetMSG_PlayerExit:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_PLAYER_EXIT
	--format like:{ uint32 playerID }
	obj.playerID = struct.unpack('<I', str)

	return obj
end


CoDNetMSG_PlayerStateNotification = {}
function CoDNetMSG_PlayerStateNotification:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_PLAYER_STATE
	--# format like:
	--#{
	--#	ushort playerCount
	--#	{
	--#		double time
	--#		uint32 playerID
	--#		ushort posX
	--#		ushort posY
	--#		ushort state
	--#		uint32 hp
	--#		uint32 mp
	--#	}...
	--#}
	obj.cdata = {}
	local curPos = 1
	local ccnt = 0
	ccnt, curPos = struct.unpack('<H', str, curPos)
	for i = 1, ccnt do
		local data = {}
		data.time, curPos = struct.unpack('d', str, curPos)
		data.PlayerID, curPos = struct.unpack('<I', str, curPos)
		data.posX, curPos = struct.unpack('<H', str, curPos)
		data.posY, curPos = struct.unpack('<H', str, curPos)
		data.state, curPos = struct.unpack('<H', str, curPos)
		data.hp, curPos = struct.unpack('<I', str, curPos)
		data.mp, curPos = struct.unpack('<I', str, curPos)
		table.insert(obj.cdata, data)
	end
	return obj
end

CoDNetMSG_MonsterStateNotification = {}
function CoDNetMSG_MonsterStateNotification:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_MONSTER_STATE
	--# format like:
	--#{
	--#	ushort monCount
	--#	{
	--#		double time
	--#		uint32 seed
	--#		ushort type
	--#		uint32 hp
	--#		ushort posX
	--#		ushort posY
	--#	}
	--#
	--#} 
	--# '<H[d<I<H<I<H<H]'
	obj.cdata = {}
	local curPos = 1
	local ccnt = 0
	ccnt, curPos = struct.unpack('<H', str, curPos)
	for i = 1, ccnt do
		local data = {}
		data.time, curPos = struct.unpack('d', str, curPos)
		data.seed, curPos = struct.unpack('<I', str, curPos)
		data.type, curPos = struct.unpack('<H', str, curPos)
		data.hp, curPos = struct.unpack('<I', str, curPos)
		data.posX, curPos = struct.unpack('<H', str, curPos)
		data.posY, curPos = struct.unpack('<H', str, curPos)
		table.insert(obj.cdata, data)
	end
	return obj
end


CoDNetMSG_ItemStateNotification = {}
function CoDNetMSG_ItemStateNotification:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	-- # format 
	-- #{
	-- #	ushort itemCount
	-- #	{
	-- #		double time 
	-- #		uint32 seed
	-- #		ushort type 
	-- #		uint32 posX
	-- #		uint32 posY
	-- #	}
	-- #}
	obj.cdata = {}
	local curPos = 1
	local ccnt = 0
	ccnt, curPos = struct.unpack('<H', str, curPos)
	for i = 1, ccnt do
		local data = {}
		data.time, curPos = struct.unpack('d', str, curPos)
		data.seed, curPos = struct.unpack('<I', str, curPos)
		data.type, curPos = struct.unpack('<H', str, curPos)
		data.posX, curPos = struct.unpack('<H', str, curPos)
		data.posY, curPos = struct.unpack('<H', str, curPos)
		table.insert(obj.cdata, data)
	end


	return obj
end


-- will be sent to server.
CoDNetMSG_PlayerStateReport = {}
function CoDNetMSG_PlayerStateReport:new(data)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_CS_PLAYER_STATE_REPORT
	--# format like:
	--#{
	--#		uint32 playerID
	--#		ushort action
	--#		ushort posX
	--#		ushort posY
	--#}
	--# '<H[<I<H<H<H]'
	local header = struct.pack('<H', obj.msgID)
	local fmt = '<I<H<H<H'
	local packStr = struct.pack(fmt, data.playerID, data.action, data.posX, data.posY)

	obj.msg = header..packStr
	return obj
end


CoDNetMSG_MonsterDoAction = {}
function CoDNetMSG_MonsterDoAction:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_MONSTER_DO_ACTION

	--# format like:
	--#{
	--#		uint32 monsterSeed
	--#		ushort actionID
	--#}
	--# '<H<I<H'
	local curPos = 1
	obj.seed, curPos = struct.unpack('<I', str, curPos)
	obj.action, curPos = struct.unpack('<H', str, curPos)

	return obj
end

CoDNetMSG_PlayerHurt = {}
function CoDNetMSG_PlayerHurt:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_PLAYER_HURT

	--# format like:
	--#{
	--#	uint32 monsterSeed
	--#	uint32 playerID
	--#	uint32 damage
	--#}
	--# '<H<I<I'
	local curPos = 1
	obj.seed, curPos = struct.unpack('<I', str, curPos)
	obj.playerID, curPos = struct.unpack('<I', str, curPos)
	obj.damage, curPos = struct.unpack('<I', str, curPos)

	return obj
end

CoDNetMSG_MonsterHurt = {}
function CoDNetMSG_MonsterHurt:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_MONSTER_HURT
	--# format like:
	--#{
	--#	uint32 monsterSeed
	--#	uint32 damage
	--#}
	--# '<H<I<I'
	local curPos = 1
	obj.seed, curPos = struct.unpack('<I', str, curPos)
	obj.damage, curPos = struct.unpack('<I', str, curPos)

	return obj
end


CoDNetMSG_PlayerDie = {}
function CoDNetMSG_PlayerDie:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	--	# format like:
	--	#{
	--	#	uint32 playerID
	--	#}
	obj.playerID = struct.unpack('<I', str, 1)
	return obj
end

CoDNetMSG_MonsterDie = {}
function CoDNetMSG_MonsterDie:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	--	# format like:
	--	#{
	--	#	uint32 seed
	--	#}
	obj.seed = struct.unpack('<I', str, 1)
	return obj
end

CoDNetMSG_PlayerAttack = {}
function CoDNetMSG_PlayerAttack:new(playerID, monsterSeed)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_CS_PLAYER_DO_ATTACK
	obj.playerID = playerID
	obj.monsterSeed = monsterSeed
	local header = struct.pack('<H', obj.msgID)

	--	# format like:
	--	#{
	--	#	uint32 monsterSeed
	--	#	ushort actionID
	--	#}
	obj.msg = header..struct.pack('<I', obj.playerID)..struct.pack('<I', obj.monsterSeed)

	return obj
end

CoDNetMSG_PlayerGetItem = {}
function CoDNetMSG_PlayerGetItem:new(playerID, itemSeed)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	--[[
	{
		uint32 playerID
		uint32 itemSeed
	}
	]]

	obj.msgID = CoDNetMessage.MSG_CS_PLAYER_GET_ITEM
	local header = struct.pack('<H', obj.msgID)
	obj.playerID = playerID
	obj.itemSeed = itemSeed
	obj.msg = header..struct.pack('<I', obj.playerID)..struct.pack('<I', obj.itemSeed)

	return obj
end

CoDNetMSG_PlayerReceiveItem = {}
function CoDNetMSG_PlayerReceiveItem:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	--[[
	{
		uint32 playerID
		uint32 itemSeed
		ushort itemType
	}
	]]
	obj.msgID = CoDNetMessage.MSG_SC_PLAYER_RECEIVE_ITEM

	local curPos = 1
	obj.playerID, curPos = struct.unpack('<I', str, curPos)
	obj.itemSeed, curPos = struct.unpack('<I', str, curPos)
	obj.itemType, curPos = struct.unpack('<H', str, curPos)


	return obj
end
 
 CoDNetMSG_PlayerChat = {}
 function CoDNetMSG_PlayerChat:new(playerID, str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.playerID = playerID
	obj.str = str
	obj.msgID = CoDNetMessage.MSG_CS_CHAT

	--[[
	packing struct 
	{
		uint32  playerID
		uint16  msgLength
		char*   msgStr
	} -- '<I<Hcn' 
	]] 
	local header = struct.pack('<H', obj.msgID)
	local fmt = '<I<Hc%d'
	fmt = string.format(fmt, #str)
	local packStr = struct.pack(fmt, playerID, #str, str)
	obj.msg = header..packStr

	return obj
end

CoDNetMSG_ReceivePlayerChat = {}
function CoDNetMSG_ReceivePlayerChat:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_CHAT

	--[[
	packing struct 
	{
		uint32  playerID
		uint16  msgLength
		char*   msgStr
	} -- '<I<Hcn' 
	]] 
	local curPos = 1
	local strFmt = 'c%d'
	local msgLen = 0
	obj.playerID, curPos = struct.unpack('<I', str, curPos)
	msgLen, curPos = struct.unpack('<H', str, curPos)

	obj.msg, curPos = struct.unpack(string.format(strFmt, msgLen), str, curPos)

	return obj
end

CoDNetMSG_PlayerUseItem = {}
function CoDNetMSG_PlayerUseItem:new(playerID, itemSeed)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_CS_PLAYER_USE_ITEM
	--	#--[[
	--	#{
	--	#	uint32 playerID
	--	#	uint32 itemSeed
	--	#}
	local header = struct.pack('<H', obj.msgID)
	obj.playerID = playerID
	obj.itemSeed = itemSeed
	obj.msg = header..struct.pack('<I', obj.playerID)..struct.pack('<I', obj.itemSeed)

	return obj
end

CoDNetMSG_PlayerReceiveEffect = {}
function CoDNetMSG_PlayerReceiveEffect:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_PLAYER_RECEIVE_EFFECT

	--[[
	packing struct 
	{
		#	uint32 playerID
		#	uint32 itemSeed
		#	uint32 HpEffect
		#	uint32 MpEffect
	} -- 
	]] 
	local curPos = 1
	obj.playerID, curPos = struct.unpack('<I', str, curPos)
	obj.itemSeed, curPos = struct.unpack('<I', str, curPos)
	obj.hpEffect, curPos = struct.unpack('<I', str, curPos)
	obj.mpEffect, curPos = struct.unpack('<I', str, curPos)

	return obj
end

CoDNetMSG_PlayerUseFireBall = {}
function CoDNetMSG_PlayerUseFireBall:new(playerID, monSeed)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_CS_PLAYER_USE_FIRE_BALL
	--	#--[[
	--	#{
	--	#	uint32 playerID
	--  # 	uint32 monSeed
	--	#}
	local header = struct.pack('<H', obj.msgID)
	obj.playerID = playerID
	obj.monsterSeed = monSeed
	obj.msg = header..struct.pack('<I', obj.playerID)..struct.pack('<I', obj.monsterSeed)

	return obj
end

CoDNetMessage_PlayerFireBallPerformed = {}
function CoDNetMessage_PlayerFireBallPerformed:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_PLAYER_PERFORM_FIRE_BALL
	--	#--[[
	--	#{
	--	#	ushort playerX
	--	#	ushort playerY
	--	#	ushort monX
	--	#	ushort monY
	--	#}
	local curPos = 1
	obj.playerX, curPos = struct.unpack('<H', str, curPos)
	obj.playerY, curPos = struct.unpack('<H', str, curPos)
	obj.monX, curPos = struct.unpack('<H', str, curPos)
	obj.monY, curPos = struct.unpack('<H', str, curPos)

	return obj
end


CoDNetMSG_PlayerUseDeadZone = {}
function CoDNetMSG_PlayerUseDeadZone:new(playerID)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_CS_PLAYER_USE_DEAD_ZONE
	--	#--[[
	--	#{
	--	#	uint32 playerID
	--	#}
	local header = struct.pack('<H', obj.msgID)
	obj.playerID = playerID
	obj.msg = header..struct.pack('<I', obj.playerID)

	return obj
end

CoDNetMessage_PlayerDeadZonePerformed = {}
function CoDNetMessage_PlayerDeadZonePerformed:new(str)
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.msgID = CoDNetMessage.MSG_SC_PLAYER_PERFORM_DEAD_ZONE
	--	#--[[
	--	#{
	--	#	uint32 playerID
	--	#}
	local curPos = 1
	obj.playerID, curPos = struct.unpack('<I', str, curPos)

	return obj
end