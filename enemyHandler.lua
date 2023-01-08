

local Font = require("include/font")
local NewAsteroid = require("objects/asteroid")
local NewBullet = require("objects/bullet")

local self = {}
local api = {}


----------------------------------------------------------------------
----------------------------------------------------------------------
-- Collision

function api.Collision(aData, bData)
	if (aData.objType == "asteroid" or aData.objType == "bullet") and bData.objType == "sun" then
		aData.Destroy()
		return true
	end
	if aData.objType == "asteroid" and bData.objType == "bullet" then
		aData.AddDamage(bData.def.damage)
		bData.Destroy()
		return true
	end
	if aData.objType == "planet" and bData.objType == "bullet" then
		if not aData.IsBulletImmune() then
			aData.AddDamage(bData.def.planetDamage)
			bData.Destroy()
			return true
		end
	end
	if aData.objType == "planet" and bData.objType == "asteroid" then
		aData.AddDamage(bData.def.planetDamage)
		bData.Destroy()
		return true
	end
	if aData.objType == "playerShip" and bData.objType == "bullet" then
		bData.Destroy()
		return true
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Utilities

function api.GetClosestAsteroid(x, y, maxDist)
	local maxDistSq = maxDist * maxDist
	local function MinFunc(asteroid)
		if asteroid.isDead then
			return false
		end
		local bx, by = asteroid.GetBody():getPosition()
		local distSq = util.DistSq(x, y, bx, by)
		if distSq < maxDistSq then
			return distSq
		end
		return false
	end
	
	local asteroid, asteroidDist = IterableMap.GetMinimum(self.asteroids, MinFunc)
	return asteroid, asteroidDist and math.sqrt(asteroidDist)
end

function api.ApplyToBullets(func, ...)
	IterableMap.Apply(self.bullets, func, ...)
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- Creation and handling

function api.QueueAsteroidCreation(asteroidData)
	self.asteroidCreateQueue = self.asteroidCreateQueue or {}
	self.asteroidCreateQueue[#self.asteroidCreateQueue + 1] = asteroidData
end

function api.AddAsteroid(data)
	IterableMap.Add(self.asteroids, NewAsteroid({def = data}, self.world.GetPhysicsWorld()))
end

function api.AddBullet(data)
	IterableMap.Add(self.bullets, NewBullet({def = data}, self.world.GetPhysicsWorld()))
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
			typeName = "asteroid_big",
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
	IterableMap.ApplySelf(self.bullets, "Update", dt)
	
	if self.asteroidCreateQueue then
		for i = 1, #self.asteroidCreateQueue do
			local asteroidData = self.asteroidCreateQueue[i]
			api.AddAsteroid(asteroidData)
		end
		self.asteroidCreateQueue = false
	end
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.asteroids, "Draw", drawQueue)
	IterableMap.ApplySelf(self.bullets, "Draw", drawQueue)
end

function api.Initialize(world, levelIndex, mapDataOverride)
	self = {
		world = world,
		asteroids = IterableMap.New(),
		bullets = IterableMap.New(),
		asteroidCreateQueue = false
	}
end

return api
