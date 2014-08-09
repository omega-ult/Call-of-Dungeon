--[[
Handle the messages transported between client and server.
]]


local socket = require 'socket'
local struct = require 'struct'
require 'bit'



CoDNetClient = {
	NET_STATE_STOP = 0,				--# state: init value
	NET_STATE_CONNECTING = 1,		--# state: connecting
	NET_STATE_ESTABLISHED = 2,		--# state: connected
	NET_MSG_HEADER_SIZE = 2,
	NET_MSG_PACK_HEADER = '<H'
}

function CoDNetClient:new()
	local ret = ret or {}
	setmetatable(ret, self)
	self.__index = self

	ret._sock = nil
	ret._sendBuf = ''
	ret._recvBuf = ''
	ret._state = CoDNetClient.NET_STATE_STOP

	return ret
end

function CoDNetClient:close()
	self._state = CoDNetClient.NET_STATE_STOP
	if self._sock ~= nil then
		return
	else
		self._sock:close()
		self._sock = nil
	end
end

function CoDNetClient:_tryConnect()
	if self._state == CoDNetClient.NET_STATE_ESTABLISHED then
		return 1
	end
	if self._state == CoDNetClient.NET_STATE_CONNECTING then
		local _rcv, _wrt, _msg = socket.select({self._sock}, {self._sock}, 0)
		if #_rcv ~= 0 then
			cclog('server connected')
			self._state = CoDNetClient.NET_STATE_ESTABLISHED
			self._sock:setoption('keepalive', true)
		end
	end
end

function CoDNetClient:connect(addr, port)
	local ip = socket.dns.toip(addr)
	self._sock = socket.tcp()
	self._sock:settimeout(0)
	self._state = CoDNetClient.NET_STATE_CONNECTING
	-- just connect it leave it time out.
	self._sock:connect(ip, port)
end

--# try to receive all the data into recv_buf
function CoDNetClient:_tryRecv()
	if self._state ~= CoDNetClient.NET_STATE_ESTABLISHED then
		return -1
	end
	local _recvCount = 0
	local _text, _err = self._sock:receive('1')
	if _text == nil then
		if _err == 'closed' then
			self:close()
		end
		return -1
	else -- there are still many bytes in the buf, take them all
		repeat
			self._recvBuf = self._recvBuf.._text
			_recvCount = _recvCount + 1
			_text = self._sock:receive('1')
		until _text == nil
	end
	return _recvCount
end

--# send data from send_buf until block (reached system buffer limit)
function CoDNetClient:_trySend()
	if string.len(self._sendBuf) == 0 then
		return 0
	end
	local _wsize, _err = self._sock:send(self._sendBuf)
	--_wsize = _wsize or 0
	if _wsize == nil then
		if _err == 'closed' then
			self:close()
		end
		return -1
	end
	self._sendBuf = string.sub(self._sendBuf, _wsize + 1, #self._sendBuf)
	return _wsize 
end

function CoDNetClient:process()
	if self._state == CoDNetClient.NET_STATE_STOP then
		return 0
	end
	if self._state == CoDNetClient.NET_STATE_CONNECTING then
		self:_tryConnect()
	end
	if self._state == CoDNetClient.NET_STATE_ESTABLISHED then
		self:_tryRecv()
	end
	if self._state == CoDNetClient.NET_STATE_ESTABLISHED then
		self:_trySend()
	end
	return 0
end

--# append data to send_buf then try to send it out (__trySend)
function CoDNetClient:_sendRaw(data)
	self._sendBuf = self._sendBuf..data
	self:process()
	return 0
end

--# peek data from recv_buf (read without delete it)
function CoDNetClient:_peekRaw(size)
	self:process()
	if #self._recvBuf == 0 then
		return ''
	end
	if size > #self._recvBuf then
		size = #self._recvBuf
	end
	local _rdata = string.sub(self._recvBuf, 1, size)
	--cclog('rdata'..#_rdata)
	return _rdata
end

--# read data from recv_buf (read and delete it from recv_buf)
function CoDNetClient:_recvRaw(size)
	local _rdata = self:_peekRaw(size)
	self._recvBuf = string.sub(self._recvBuf, #_rdata+1, #self._recvBuf)
	return _rdata
end

--# append data into send_buf with a size header
function CoDNetClient:send(data)
	local _size = #data + CoDNetClient.NET_MSG_HEADER_SIZE -- two byte for category
	local _head = struct.pack(CoDNetClient.NET_MSG_PACK_HEADER, _size)
	self:_sendRaw(_head..data)
	return 0
end

function CoDNetClient:recv()
	local _head = self:_peekRaw(CoDNetClient.NET_MSG_HEADER_SIZE) --header size
	if #_head < CoDNetClient.NET_MSG_HEADER_SIZE then
		return ''
	end
	local _packSize = struct.unpack(CoDNetClient.NET_MSG_PACK_HEADER, _head)
	if _packSize > #self._recvBuf then
		return ''
	end
	self:_recvRaw(CoDNetClient.NET_MSG_HEADER_SIZE)
	return self:_recvRaw(_packSize - CoDNetClient.NET_MSG_HEADER_SIZE)
end

function CoDNetClient:noDelay(flag)
	if self._sock ~= nil then
		self._sock:setoption('tcp-nodelay', flag)
	end
end

function CoDNetClient:getStatus()
	return self._state
end