
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local Resources = require("resourceHandler")
MusicHandler = require("musicHandler")

local self = {}
local api = {}

local guyTypeList = {
	"philosopher",
	"inventor",
	"scientist",
}

local greyColor = {0.4, 0.4, 0.4, 1}
local greyFlashColor = {0.7, 0.7, 0.7, 1}

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.AddAbduct(abductType, abductPlanet)
	self.abductScore[abductPlanet] = self.abductScore[abductPlanet] or {}
	self.abductScore[abductPlanet][abductType] = (self.abductScore[abductPlanet][abductType] or 0) + 1
end

--------------------------------------------------
-- Goals
--------------------------------------------------

local function DoesPlanetHasPendingGoals(name, have, need)
	if not need then
		return false
	end
	if not have then
		return true
	end
	for i = 1, #guyTypeList do
		local guy = guyTypeList[i]
		if (have[guy] or 0) < (need[guy] or 0) then
			return true
		end
	end
	return false
end

local function IsPlanetDead(name)
	local planetData = TerrainHandler.GetPlanet(name)
	return (not planetData) or (planetData.age == 1)
end

function api.CheckGoalSatisfaction()
	local planetNames = TerrainHandler.GetPlanetNames()
	local goal = TerrainHandler.GetLevelData().goal
	
	local won, lost = true, false
	for i = 1, #planetNames do
		local name = planetNames[i]
		if DoesPlanetHasPendingGoals(name, self.abductScore[name], goal[name]) then
			won = false
			if IsPlanetDead(name) then
				lost = true
				break
			end
		end
	end
	return won, lost
end

--------------------------------------------------
-- Drawing
--------------------------------------------------

local function PrintLine(text, size, x, y, align, width)
	Font.SetSize(size)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(text, x, y, width or 240, align or "left")
	if size == 1 then
		return y + 30
	elseif size == 2 then
		return y + 40
	end
	return y + 60
end

local function DrawGuyTypeScore(guyType, have, need, xOffset, offset, guyStack)
	local toDraw = math.max(have, need)
	if toDraw <= 0 then
		return
	end
	local offsetEachTime = math.min(55, 165 / (toDraw - 1))
	xOffset = xOffset + 35
	for i = 1, toDraw do
		local color = (have < i and greyColor)
		if color and (self.hovered == "Continue") and (self.animDt%0.4 < 0.2) then
			color = greyFlashColor
		end
		Resources.DrawImage(guyType, xOffset, offset + 22, 0, 1, 60, color)
		xOffset = xOffset + offsetEachTime
	end
	return offset + guyStack
end

local function DrawAbductScore(name, humanName, planetImage, goal, planetScore, xOffset, offset, guyStack)
	if not (planetScore or goal) then
		return offset
	end
	
	local planetData = TerrainHandler.GetPlanet(name)
	if planetData then
		if planetData.age > 1 then
			Resources.DrawImage(planetImage, xOffset + 20, offset + 22, planetData.GetAngle(), 1, 20)
			Resources.DrawImage(Global.AGE_IMAGE[planetData.age], xOffset + 20, offset + 22, planetData.GetAngle(), 1, 20)
		else
			Resources.DrawImage(Global.DEAD_IMAGE[planetImage], xOffset + 20, offset + 22, planetData.GetAngle(), 1, 20)
		end
	else
		Resources.DrawImage(Global.DEAD_IMAGE[planetImage], xOffset + 20, offset + 22, 0, 1, 20, greyColor)
	end
	offset = PrintLine(humanName, 3, xOffset + 60, offset)
	offset = offset + 15
	
	for i = 1, #guyTypeList do
		local guyType = guyTypeList[i]
		if (planetScore and (planetScore[guyType] or 0) > 0) or goal[guyType] then
			offset = DrawGuyTypeScore(guyType, (planetScore and planetScore[guyType]) or 0, goal[guyType] or 0, xOffset, offset, guyStack)
		end
	end
	offset = offset + 100 - guyStack
	return offset
end

local function DrawRightInterface()
	local planetNames, planetHumanNames = TerrainHandler.GetPlanetNames()
	local planetImages = TerrainHandler.GetPlanetImages()
	local goal = TerrainHandler.GetLevelData().goal
	
	local offset = 45
	local xOffset = 1650
	offset = PrintLine("Requirements", 3, xOffset, offset)
	
	local guyStack = 90
	if #planetNames == 3 then
		guyStack = 45
	elseif #planetNames >= 4 then
		guyStack = 20
	end
	
	for i = 1, #planetNames do
		local name = planetNames[i]
		offset = DrawAbductScore(name, planetHumanNames[i], planetImages[i], goal[name], self.abductScore[name], xOffset, offset, guyStack)
	end
end

local function DrawTopLeftInterface()
	local levelData = TerrainHandler.GetLevelData()
	local offset = 45
	local xOffset = 0
	offset = PrintLine(levelData.humanName, 3, xOffset, offset, "center", 280)
	
	offset = PrintLine(levelData.description or "missing description", 4, xOffset + 20, offset + 8, "left", 255)
	
end

local function DrawBottomLeftInterface()
	local mousePos = self.world.GetMousePositionInterface()
	local won, lost = api.CheckGoalSatisfaction()
	
	self.hovered = InterfaceUtil.DrawButton(65, 905, 165, 60, mousePos, "Menu")
	self.hovered = InterfaceUtil.DrawButton(65, 830, 165, 60, mousePos, "Restart", false, lost) or self.hovered
	if self.world.GetCosmos().TestSwitchLevel(true) then
		self.hovered = InterfaceUtil.DrawButton(65, 755, 165, 60, mousePos, "Continue", not won, won, true) or self.hovered
	end
end

local function DrawMenu()
if self.world.GetPaused() then
		local overX = 700
		local overWidth = 500
		local overY = 350
		local overHeight = 300
		love.graphics.setColor(Global.PANEL_COL[1], Global.PANEL_COL[2], Global.PANEL_COL[3], 1)
		love.graphics.setLineWidth(4)
		love.graphics.rectangle("fill", overX, overY, overWidth, overHeight*1.12, 8, 8, 16)
		love.graphics.setColor(Global.OUTLINE_COL[1], Global.OUTLINE_COL[2], Global.OUTLINE_COL[3], 1)
		love.graphics.setLineWidth(10)
		love.graphics.rectangle("line", overX, overY, overWidth, overHeight*1.12, 8, 8, 16)
		
		Font.SetSize(1)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("Paused", overX, overY + overHeight * 0.04, overWidth, "center")
		
		Font.SetSize(3)
		love.graphics.printf([[
P or Esc:
Ctrl+M:
Ctrl+R:
Ctrl+N:
Ctrl+P:]], overX + 30, overY + overHeight * 0.3 , 175, "right")

		love.graphics.printf([[
Open menu
Toggle music
Reset the level
Next level
Previous level]], overX + 210, overY + overHeight * 0.3 , 350, "left")
	end
end

--------------------------------------------------
-- API
--------------------------------------------------

function api.MousePressed(x, y)
	if self.hovered == "Menu" then
		self.world.ToggleMenu()
	end
	if self.hovered == "Restart" then
		self.world.Restart()
	end
	if self.hovered == "Continue" and api.CheckGoalSatisfaction() then
		self.world.GetCosmos().SwitchLevel(true)
	end
end

function api.GetViewRestriction()
	local pointsToView = {{0, 0}, {800, 800}}
	return pointsToView
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
	self.animDt = self.animDt + dt
end

function api.DrawInterface()
	DrawRightInterface()
	DrawTopLeftInterface()
	DrawBottomLeftInterface()
	DrawMenu()
end

function api.Initialize(parentWorld)
	self = {
		abductScore = {},
		world = parentWorld,
		animDt = 0
	}
	
end

return api
