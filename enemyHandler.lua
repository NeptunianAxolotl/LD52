

local Font = require("include/font")
local NewAsteroid = require("objects/asteroid")

local self = {}
local api = {}


----------------------------------------------------------------------
----------------------------------------------------------------------
-- Collision

function api.Collision(aData, bData)
	if aData.objType == "asteroid" and bData.objType == "sun" then
		aData.Destroy()
		return true
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Creation and handling

function api.AddAsteroid(data)
	IterableMap.Add(self.asteroids, NewAsteroid({def = data}, self.world.GetPhysicsWorld()))
end

local function SpawnEnemiesUpdate(dt)
	local mapData = TerrainHandler.GetMapData()
	if not self.asteroidTimer then
		self.asteroidTimer = mapData.asteroidTimeMin + math.random()*mapData.asteroidTimeRand
	end
	self.asteroidTimer = self.asteroidTimer - dt
	if self.asteroidTimer < 0 then
		local pos = {0, math.random()*TerrainHandler.GetHeight()}
		local velocity = util.RandomPointInAnnulus(80, 350)
		if velocity[1] < 0 then
			pos[1] = TerrainHandler.GetWidth()
		end
		local asteroidData = {
			pos = pos,
			velocity = velocity,
			radius = 45,
			density = 5
		}
		api.AddAsteroid(asteroidData)
		self.asteroidTimer = self.asteroidTimer + mapData.asteroidTimeMin + math.random()*mapData.asteroidTimeRand
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Callins

function api.Update(dt)
	SpawnEnemiesUpdate(dt)
	IterableMap.ApplySelf(self.asteroids, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.asteroids, "Draw", drawQueue)
end

function api.Initialize(world, levelIndex, mapDataOverride)
	self = {
		world = world,
		asteroids = IterableMap.New(),
	}
end

return api
