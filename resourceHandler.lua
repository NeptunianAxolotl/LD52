

local api = {}
local self = {
	debugMode = false
}

--------------------------------------------------
-- Images
--------------------------------------------------

local function LoadImage(resData)
	local image = love.graphics.newImage(resData.file)
	local imageWidth, imageHeight = image:getWidth(), image:getHeight()
	
	local data = {
		image = image,
		xScale = resData.xScale or 1,
		yScale = resData.yScale or 1,
		imageWidth = imageWidth,
		imageHeight = imageHeight,
	}
	data.xOffset = (resData.xOffset or 0.5)*imageWidth
	data.yOffset = (resData.yOffset or 0.5)*imageHeight
	
	return data
end

local function LoadIsoImage(resData)
	local image = {}
	local imageWidth, imageHeight
	for i = 1, #resData.files do
		image[i] = love.graphics.newImage(resData.files[i])
		if not imageWidth then
			imageWidth, imageHeight = image[i]:getWidth(), image[i]:getHeight()
		end
	end
	
	local data = {
		image = image,
		xScale = resData.xScale or 1,
		yScale = resData.yScale or 1,
		firstDir = resData.firstDir or 0,
		directionCount = #resData.files,
		rotate = resData.rotate,
	}
	data.xOffset = (resData.xOffset or 0.5)*imageWidth
	data.yOffset = (resData.yOffset or 0.5)*imageHeight
	
	return data
end

local function LoadFileListAnimation(resData)
	local images = {}
	local fileList = resData.fileList
	local singleFrameData = util.CopyTable(resData)
	singleFrameData.fileList = false
	for i = 1, #fileList do
		singleFrameData.file = fileList[i]
		images[#images + 1] = LoadImage(singleFrameData)
	end
	
	local animData = {}
	animData.duration = resData.duration
	animData.imageList = images
	animData.frames = #images
	return animData
end

local function LoadAnimation(resData)
	if resData.fileList then
		return LoadFileListAnimation(resData)
	end
	local data = LoadImage(resData)
	
	data.quads = {}
	data.duration = resData.duration
	
	local width = resData.width
	local imageWidth = data.image:getWidth()
	local imageHeight = data.image:getHeight()
	
	data.xOffset = (resData.xOffset or 0.5)*width
	data.yOffset = (resData.yOffset or 0.5)*imageHeight
	
	data.quadWidth = width
	data.quadHeight = imageHeight
	
	for x = 0, imageWidth - width, width do
		--print(x)
		data.quads[#data.quads + 1] = love.graphics.newQuad(x, 0, width, imageHeight, imageWidth, imageHeight)
	end
	
	data.frames = #data.quads
	
	return data
end

local function LoadIsoAnimation(resData)
	local dirAnim = {}
	for i = 1, #resData.files do
		dirAnim[i] = LoadAnimation({
			file = resData.files[i],
			width = resData.width,
			duration = resData.duration,
			xScale = resData.xScale,
			yScale = resData.yScale,
			xOffset = resData.xOffset,
			yOffset = resData.yOffset,
		})
	end
	
	if resData.anchors then
		for i = 1, #resData.files do
			dirAnim[i].anchors = {}
			for key, value in pairs(resData.anchors) do
				dirAnim[i].anchors[key] = value[i]
			end
		end
	end
	
	local data = {
		dirAnim = dirAnim,
		duration = resData.duration,
		firstDir = resData.firstDir or 0,
		directionCount = #resData.files,
		rotate = resData.rotate,
		anchors = resData.anchors,
	}
	
	return data
end

local function GetAnimationFrame(progress, duration, frames)
	return math.floor((progress%duration) / duration * frames) + 1
end

--------------------------------------------------
-- Sound
--------------------------------------------------

local function LoadSound(resData)

end

--------------------------------------------------
-- Loading
--------------------------------------------------

local function LoadResouce(name, res)
	if res.form == "image" then
		self.images[name] = LoadImage(res)
	elseif res.form == "iso_image" then
		self.images[name] = LoadIsoImage(res)
	elseif res.form == "animation" then
		self.animations[name] = LoadAnimation(res)
	elseif res.form == "iso_animation" then
		self.animations[name] = LoadIsoAnimation(res)
	elseif res.form == "sound" then
		self.sounds[name] = LoadSound(res)
	else
		print("Invalid form ", res.form, " for resource ", name)
	end
end

local function LoadResourceFile(name)
	local res = require("resources/defs/" .. name)
	if res.form then
		LoadResouce(name, res)
		return
	end
	
	for i = 1, #res do
		LoadResouce(res[i].name, res[i])
	end
end

function api.LoadResources()
	local resList = util.GetDefDirList("resources/defs")
	self.images = {}
	self.animations = {}
	self.sounds = {}
	
	for i = 1, #resList do
		LoadResourceFile(resList[i])
	end
end

--------------------------------------------------
-- Drawing Functions
--------------------------------------------------

function api.SetTexture(mesh, name)
	if not self.images[name] then
		print("Invalid SetTexture ", name)
		return
	end
	mesh:setTexture(self.images[name].image)
end

function api.DrawImageInternal(data, x, y, rotation, alpha, scale, color)
	rotation = rotation or 0
	local scaleX, scaleY = scale, scale
	if type(scale) == "table" then
		scaleX, scaleY = scale[1], scale[2]
	end
	scaleX = scaleX or 1
	scaleY = scaleY or 1
	
	love.graphics.setColor(
		(color and color[1]) or 1,
		(color and color[2]) or 1,
		(color and color[3]) or 1,
		((color and color[4]) or 1)*(alpha or 1)
	)
	
	love.graphics.draw(data.image, x, y, rotation, data.xScale*scaleX, data.yScale*scaleY, data.xOffset, data.yOffset, 0, 0)
end

function api.DrawImage(name, x, y, rotation, alpha, scale, color)
	if not self.images[name] then
		print("Invalid DrawImage ", name)
		return
	end
	api.DrawImageInternal(self.images[name], x, y, rotation, alpha, scale, color)
end

function api.DrawIsoImage(name, x, y, direction, alpha, scale, color)
	if not self.images[name] then
		print("Invalid DrawIsoImage ", name)
		return
	end
	
	scale = scale or 1
	
	love.graphics.setColor(
		(color and color[1]) or 1,
		(color and color[2]) or 1,
		(color and color[3]) or 1,
		((color and color[4]) or 1)*(alpha or 1)
	)
	
	local data = self.images[name]
	local drawDir = util.DirectionToCardinal(direction, data.firstDir, data.directionCount)
	
	local rotation = 0
	if data.rotate then
		rotation = -util.AngleToCardinal(direction, drawDir, data.firstDir, data.directionCount)
	end
	
	love.graphics.draw(data.image[drawDir], x, y, rotation, data.xScale*scale, data.yScale*scale, data.xOffset, data.yOffset, 0, 0)
end

function api.UpdateAnimation(name, progress, dt)
	if not self.animations[name] then
		print("Invalid UpdateAnimation ", name)
		return
	end
	return (progress + dt)%self.animations[name].duration
end

function api.GetAnimationDuration(name)
	if not self.animations[name] then
		print("Invalid GetAnimationDuration ", name)
		return
	end
	return self.animations[name].duration
end

function api.DrawAnimInternal(data, x, y, progress, rotation, alpha, scale, color)
	if data.imageList then
		local imageToDraw = GetAnimationFrame(progress, data.duration, data.frames)
		api.DrawImageInternal(data.imageList[imageToDraw], x, y, rotation, alpha, scale, color)
		return
	end
	
	love.graphics.setColor(
		(color and color[1]) or 1,
		(color and color[2]) or 1,
		(color and color[3]) or 1,
		((color and color[4]) or 1)*(alpha or 1)
	)
	
	scale = scale or 1
	rotation = rotation or 0
	progress = progress or 0
	
	local quadToDraw = GetAnimationFrame(progress, data.duration, data.frames)
	love.graphics.draw(data.image, data.quads[quadToDraw], x, y, rotation, data.xScale*scale, data.yScale*scale, data.xOffset, data.yOffset, 0, 0)
	
	if self.debugMode then
		love.graphics.rectangle("line", x - data.xOffset*data.xScale, y - data.yOffset*data.yScale, data.quadWidth*data.xScale, data.quadHeight*data.yScale, 0, 0)
	end
end

function api.DrawAnimation(name, x, y, progress, rotation, alpha, scale, color)
	if not self.animations[name] then
		print("Invalid DrawAnimation ", name)
		return
	end
	api.DrawAnimInternal(self.animations[name], x, y, progress, rotation, alpha, scale, color)
end

function api.DrawIsoAnimation(name, x, y, progress, direction, alpha, scale, color)
	if not self.animations[name] then
		print("Invalid DrawIsoAnimation ", name)
		return
	end
	
	local data = self.animations[name]
	local drawDir = util.DirectionToCardinal(direction, data.firstDir, data.directionCount)
	
	local rotation = 0
	if data.rotate then
		rotation = -util.AngleToCardinal(direction, drawDir, data.firstDir, data.directionCount)
	end
	
	api.DrawAnimInternal(data.dirAnim[drawDir], x, y, progress, rotation, alpha, scale, color)
end

function api.GetIsoAnimationAnchorOffset(name, anchorName, progress, direction, scale)
	if not self.animations[name] then
		print("Invalid GetIsoAnimationAnchorOffset ", name)
		return {0, 0}
	end
	scale = scale or 1
	progress = progress or 0
	
	local data = self.animations[name]
	local drawDir = util.DirectionToCardinal(direction, data.firstDir, data.directionCount)
	dirData = data.dirAnim[drawDir]
	
	local animFrame = GetAnimationFrame(progress, dirData.duration, dirData.frames)
	local offset = dirData.anchors[anchorName][animFrame]
	return {offset[1]*dirData.xScale*scale, offset[2]*dirData.yScale*scale}
end


function api.DrawImageOrAnimation(name, x, y, progress, rotation, alpha, scale, color)
	if self.animations[name] then
		api.DrawAnimation(name, x, y, progress, rotation, alpha, scale, color)
	elseif self.images[name] then
		api.DrawImage(name, x, y, rotation, alpha, scale, color)
	end
end

--------------------------------------------------
-- Drawing Functions
--------------------------------------------------

return api
