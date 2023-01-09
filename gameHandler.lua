
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

--------------------------------------------------
-- Updating
--------------------------------------------------


function api.AddAbduct(abductType, abductPlanet)
	self.abductScore[abductPlanet] = self.abductScore[abductPlanet] or {}
	self.abductScore[abductPlanet][abductType] = (self.abductScore[abductPlanet][abductType] or 0) + 1
end

--------------------------------------------------
-- API
--------------------------------------------------

function api.ToggleMenu()
	self.menuOpen = not self.menuOpen
	self.world.SetMenuState(self.menuOpen)
end

function api.MousePressed(x, y)
	local windowX, windowY = love.window.getMode()
	local drawPos = self.world.ScreenToInterface({windowX, 0})
end

function api.GetViewRestriction()
	local pointsToView = {{0, 0}, {800, 800}}
	return pointsToView
end

--------------------------------------------------
-- Drawing
--------------------------------------------------

local function DrawAbductScore(name, planetScore, offset)
	if not planetScore then
		return offset
	end
	for i = 1, #guyTypeList do
		local guyType = guyTypeList[i]
		if true or (planetScore[guyType] or 0) > 0 then
			Resources.DrawImage(guyType, 1750, offset + 80, 0, 1, 80)
			love.graphics.setColor(1, 1, 1, 1)
			Font.SetSize(3)
			love.graphics.printf((planetScore[guyType] or 0), 1825, offset + 50, 90, "left")
			
			offset = offset + 130
		end
	end
	return offset
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end

function api.DrawInterface()
	local offset = 20
	local planetNames = TerrainHandler.GetPlanetNames()
	for i = 1, #planetNames do
		local name = planetNames[i]
		offset = DrawAbductScore(name, self.abductScore[name], offset)
	end
end

function api.Initialize(parentWorld)
	self = {
		abductScore = {},
		world = parentWorld,
	}
	
end

return api
