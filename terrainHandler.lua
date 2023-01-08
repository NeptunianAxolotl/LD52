
local Font = require("include/font")

local MapDefs = util.LoadDefDirectory("defs/maps")
local NewPlanet = require("objects/planet")local NewSun = require("objects/sun")

local self = {}
local api = {}local ageNameMap = {	dead = 1,	stone = 2,	bronze = 3,	iron = 4,	classical = 5,	invention = 6,	modern = 7,	space = 8,}
---------------------------------------------------------------------------------------------------------------------------------------------- Update utilities
function api.WrapBody(body)
	local bx, by = body:getPosition()
	local nx, ny = false, false
	
	if bx > self.width then
		nx = bx - self.width
	elseif bx < 0 then
		nx = bx + self.width
	end
	
	if by > self.height then
		ny = by - self.height
	elseif by < 0 then
		ny = by + self.height
	end
	
	if nx or ny then
		body:setPosition(nx or bx, ny or by)
	end
end

function api.ApplyGravity(body)
	local bx, by = body:getPosition()
	local toSun, sunDist = util.Unit({self.sunX - bx, self.sunY - by})
	local distSq = math.max(sunDist * sunDist, 100)
	local forceVector = util.Mult(body:getMass() * self.sunGravity / distSq, toSun)
	body:applyForce(forceVector[1], forceVector[2])
end
function api.GetLocalGravityAccel(x, y)	if not y then		x, y = x[1], x[2]	end	local toSun, sunDist = util.Unit({self.sunX - x, self.sunY - y})	local distSq = math.max(sunDist * sunDist, 100)	return util.Mult(self.sunGravity / distSq, toSun)end
function api.UpdateSpeedLimit(body, speedLimit)	speedLimit = speedLimit or Global.SPEED_LIMIT
	local vx, vy = body:getLinearVelocity()
	local speedSq = util.DistSq(0, 0, vx, vy)
	if speedSq < speedLimit * speedLimit then
		body:setLinearDamping(0)
		return
	end
	local speed = math.sqrt(speedSq)
	body:setLinearDamping((speed - speedLimit) / speedLimit)
end
---------------------------------------------------------------------------------------------------------------------------------------------- Collisionfunction api.Collision(aData, bData)	if aData.objType == "planet" and bData.objType == "sun" then		aData.Destroy()		return true	endend---------------------------------------------------------------------------------------------------------------------------------------------- Level utilsfunction api.GetMapData()	return self.mapendfunction api.GetWidth()	return self.widthendfunction api.GetHeight()	return self.heightend---------------------------------------------------------------------------------------------------------------------------------------------- Setup and creation
local function AddPlanet(data)
	IterableMap.Add(self.planets, NewPlanet({def = data}, self.world.GetPhysicsWorld()))
endlocal function AddSun(data)	IterableMap.Add(self.suns, NewSun({def = data}, self.world.GetPhysicsWorld()))end
function api.GetCircularOrbitVelocity(pos, factor, angleTweak)	factor = factor or 1
	local toSun, dist = util.Unit({pos[1] - self.sunX, pos[2] - self.sunY})
	local speed = math.sqrt(self.sunGravity / dist)
	return util.RotateVector({0, -1*factor*speed}, util.Angle(toSun) + (angleTweak or 0))
end

local function SetupLevel()
	self.map = {		asteroidTimeMin = 4,		asteroidTimeRand = 2,	}	self.sunGravity = Global.GRAVITY_MULT * 20	
	local pos = {self.sunX - 1000, self.sunY}
	local planetData = {
		pos = pos,
		velocity = api.GetCircularOrbitVelocity(pos),
		radius = 95,
		density = 150,		age = ageNameMap.space,		maxAge = ageNameMap.space,		ageSpeed = 1/20,		guySpeed = 1/6,		guyGap = 8,		guyAgeBoost = 1.5,		fillLastAge = false
	}
	AddPlanet(planetData)		local sunData = {		pos = {self.sunX, self.sunY},		radius = 200,		density = 1000	}	AddSun(sunData)		pos = {self.sunX + 1100, self.sunY - 750}		local asteroidParams = {		{			pos = {self.sunX + 1100, self.sunY - 750},			mult = 0.65,		},		{			pos = {self.sunX + 500, self.sunY + 360},			mult = -1.15,		},	}		for i = 1, #asteroidParams do		local data = asteroidParams[i]		local asteroidData = {			pos = data.pos,			velocity = api.GetCircularOrbitVelocity(data.pos, data.mult, data.angle),			typeName = "asteroid_big",		}		EnemyHandler.AddAsteroid(asteroidData)	end		pos = {self.sunX - 300, self.sunY - 500}	local initPlayerData = {		pos = pos,		velocity = api.GetCircularOrbitVelocity(pos, -0.95)	}	PlayerHandler.SpawnPlayer(initPlayerData)
end
---------------------------------------------------------------------------------------------------------------------------------------------- Callins
function api.Update(dt)
	IterableMap.ApplySelf(self.planets, "Update", dt)	IterableMap.ApplySelf(self.suns, "Update", dt)
end

function api.Draw(drawQueue)
	drawQueue:push({y=0; f=function()		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", 0, 0, self.width, self.height)
	end})
	IterableMap.ApplySelf(self.planets, "Draw", drawQueue)	IterableMap.ApplySelf(self.suns, "Draw", drawQueue)
end

function api.Initialize(world, levelIndex, mapDataOverride)
	self = {
		world = world,
		width = Global.WORLD_WIDTH,
		height = Global.WORLD_HEIGHT,
		planets = IterableMap.New(),		suns = IterableMap.New(),
	}
	self.sunX = self.width / 2
	self.sunY = self.height / 2
	
	SetupLevel(levelIndex, mapDataOverride)
end

return api
