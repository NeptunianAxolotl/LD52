
local IterableMap = require("include/IterableMap")
local util = require("include/util")

--local EffectDefs = util.LoadDefDirectory("effects")
local NewPlayerShip = require("objects/playerShip")

local self = {}
local api = {}

function api.SpawnComponent(name, pos, data)
	--local def = EffectDefs[name]
	data = data or {}
	data.pos = pos
	self.playerShip = NewPlayerShip(data, self.world.GetPhysicsWorld())
end

function api.Update(dt)
	IterableMap.ApplySelf(self.components, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.components, "Draw", drawQueue)
end

function api.Initialize(world)
	self = {
		playerShip = false,
		animationTimer = 0,
		world = world,
	}
end

return api
