

--local EffectDefs = util.LoadDefDirectory("effects")
local NewPlayerShip = require("objects/playerShip")

local self = {}
local api = {}

function api.SpawnPlayer(initPlayerData)
	initPlayerData.density = 10
	self.playerShip = NewPlayerShip({def = initPlayerData}, self.world.GetPhysicsWorld())
end

function api.Collision(aData, bData)

end

function api.Update(dt)
	if self.playerShip then
		self.playerShip.Update(dt)
	end
end

function api.Draw(drawQueue)
	if self.playerShip then
		self.playerShip.Draw(drawQueue)
	end
end

function api.Initialize(world)
	self = {
		playerShip = false,
		animationTimer = 0,
		world = world,
	}
end

return api
