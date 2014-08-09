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
	MSG_SC_LOGIN_CONFIRM	= 0x2001,

	MSG_CS_MOVETO	= 0x1002,
	MSG_SC_MOVETO	= 0x2002,

	MSG_CS_CHAT		= 0x1003,
	MSG_SC_CHAT		= 0x2003,

	MSG_SC_ADDUSER	= 0x2004,
	MSG_SC_DELUSER	= 0x2005,

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

CoDNetMSG_PlayerLogin = {}
function CoDNetMSG_PlayerLogin:new()
	local ret = ret or {}
	setmetatable(ret, self)
	self.__index = self

	ret.msgID = CoDNetMessage.MSG_CS_LOGIN
	--[[
	packing struct 
	{
		ushort  accLength
		char*   accStr
		ushort  pwdLength
		char*   pwdStr
	} -- '<Hcn<Hcn' 
	]] 
	return ret
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

CoDNetMSG_ServerWelcome = {}
function CoDNetMSG_ServerWelcome:new()
	local ret = ret or {}
	setmetatable(ret, self)
	self.__index = self

	ret.msgID = CoDNetMessage.MSG_SC_WELCOME

	--[[
	packing struct 
	{
		uint32  playerHandle
		uint16  msgLength
		char*   msgStr
	} -- '<I4<Hcn' 
	]] 
	return ret
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
