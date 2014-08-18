require "Cocos2d"
require "Cocos2dConstants"


CoDCameraController = {
	
}

function CoDCameraController:new()
	local obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.camConstrain = {minx = 0, miny = 0, maxx = 10, maxy = 10}
	obj.visibleSize = cc.Director:getInstance():getVisibleSize()

	local trckLyr = cc.Layer:create()
	local vLyr = cc.Layer:create()
	--vLyr:retain()
	vLyr:addChild(trckLyr)

	obj.trackLayer = trckLyr
	obj.viewLayer = vLyr

	return obj
end

function CoDCameraController:setFullViewRect(minx, miny, maxx, maxy)
	minx = minx or 0
	miny = miny or 0
	maxx = maxx or 10
	maxy = maxy or 10
	local camMinX = minx + self.visibleSize.width/2
	local camMaxX = maxx - self.visibleSize.width/2
	local camMinY = miny + self.visibleSize.height/2
	local camMaxY = maxy - self.visibleSize.height/2
	local constrainW = camMaxX - camMinX
	if constrainW < 0 then 
		constrainW = 0
		minx = (minx + maxx)/2
		maxx = minx
	else
		minx = camMinX
		maxx = camMaxX
	end
	local constrainH = camMaxY - camMinY
	if constrainH < 0 then
		constrainH = 0
		miny = (miny + maxy)/2
		maxy = miny
	else
		miny = camMinY
		maxy = camMaxY
	end
	self.camConstrain.minx = minx
	self.camConstrain.miny = miny
	self.camConstrain.maxx = maxx
	self.camConstrain.maxy = maxy
end

function CoDCameraController:getCameraNode()
	return self.viewLayer
end

function CoDCameraController:getTrackNode()
	return self.trackLayer
end

function CoDCameraController:setViewTarget(x, y)
	x = x or 0
	y = y or 0
	if x < self.camConstrain.minx then
		x = self.camConstrain.minx
	end
	if x > self.camConstrain.maxx then
		x = self.camConstrain.maxx
	end
	if y < self.camConstrain.miny then
		y = self.camConstrain.miny
	end
	if y > self.camConstrain.maxy then
		y = self.camConstrain.maxy
	end
	self.trackLayer:setPosition(-x, -y)
end
