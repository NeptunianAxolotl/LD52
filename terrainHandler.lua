
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
	local bx, by = body:getWorldCenter()
	local toSun, sunDist = util.Unit({self.sunX - bx, self.sunY - by})
	local distSq = math.max(sunDist * sunDist, 100)
	local forceVector = util.Mult(body:getMass() * self.sunGravity / distSq, toSun)
	body:applyForce(forceVector[1], forceVector[2])
end
function api.GetLocalGravityAccel(x, y)	if not y then		x, y = x[1], x[2]	end	local toSun, sunDist = util.Unit({self.sunX - x, self.sunY - y})	local distSq = math.max(sunDist * sunDist, 100)	return util.Mult(self.sunGravity / distSq, toSun)end
function api.UpdateSpeedLimit(body, speedLimit, minDampening)	speedLimit = speedLimit or Global.SPEED_LIMIT
	local vx, vy = body:getLinearVelocity()
	local speedSq = util.DistSq(0, 0, vx, vy)
	if speedSq < speedLimit * speedLimit then
		body:setLinearDamping(minDampening or 0)
		return
	end
	local speed = math.sqrt(speedSq)
	body:setLinearDamping(math.max(minDampening or 0, (speed - speedLimit) / speedLimit))
endfunction api.GetWrapAlpha(x, y)	local alpha = 1	if x < Global.WRAP_ALPHA_SIZE then		alpha = math.max(0, math.min(alpha, x / Global.WRAP_ALPHA_SIZE))	end	if y < Global.WRAP_ALPHA_SIZE then		alpha = math.max(0, math.min(alpha, y / Global.WRAP_ALPHA_SIZE))	end	if x > (self.width - Global.WRAP_ALPHA_SIZE) then		alpha = math.max(0, math.min(alpha, (self.width - x) / Global.WRAP_ALPHA_SIZE))	end	if y > (self.height - Global.WRAP_ALPHA_SIZE) then		alpha = math.max(0, math.min(alpha, (self.height - y) / Global.WRAP_ALPHA_SIZE))	end	return alphaend
---------------------------------------------------------------------------------------------------------------------------------------------- Collisionfunction api.Collision(aData, bData)	if aData.objType == "planet" and bData.objType == "sun" then		aData.Destroy()		return true	endend---------------------------------------------------------------------------------------------------------------------------------------------- Level utilsfunction api.GetLevelData()	return self.levelDataendfunction api.GetWidth()	return self.widthendfunction api.GetHeight()	return self.heightendfunction api.GetSunX()	return self.sunXendfunction api.GetSunY()	return self.sunYendfunction api.GetSunRadius()	return self.levelData.sun.radiusendfunction api.GetPlanets()	return self.planetsendfunction api.GetPlanetNames()	return self.planetNameListendfunction api.GetPlanetImages()	return self.planetImageListendfunction api.GetPlanet(name)	return IterableMap.Get(self.planets, name)end---------------------------------------------------------------------------------------------------------------------------------------------- Setup and creation
local function AddPlanet(data)	local newPlanet = NewPlanet({def = data}, self.world.GetPhysicsWorld())
	IterableMap.Add(self.planets, data.name, newPlanet)	return newPlanet
endlocal function AddSun(data)	IterableMap.Add(self.suns, NewSun({def = data}, self.world.GetPhysicsWorld()))end
function api.GetCircularOrbitVelocity(pos, factor, angleTweak)	factor = factor or 1
	local toSun, dist = util.Unit({pos[1] - self.sunX, pos[2] - self.sunY})
	local speed = math.sqrt(self.sunGravity / dist)
	return util.RotateVector({0, -1*factor*speed}, util.Angle(toSun) + (angleTweak or 0))
end

local function SetupLevel(levelData)	self.levelData = levelData		self.sunX = self.width * levelData.sun.alignX	self.sunY = self.height * levelData.sun.alignY	self.sunGravity = Global.GRAVITY_MULT * levelData.gravity		for i = 1, #levelData.planets do		local planetData = util.CopyTable(levelData.planets[i])		planetData.name = planetData.name or ("noname_" .. i)
		planetData.pos = {self.sunX + planetData.pos[1], self.sunY + planetData.pos[2]}
		planetData.velocity = planetData.velocity or api.GetCircularOrbitVelocity(			planetData.pos, planetData.orbitMult, planetData.orbitAngle)				planetData.age = ageNameMap[planetData.age]		planetData.maxAge = ageNameMap[planetData.maxAge]
		local planet = AddPlanet(planetData)		self.planetNameList[#self.planetNameList + 1] = planetData.name		self.planetImageList[#self.planetImageList + 1] = planet.planetDrawBase	end		for i = 1, #levelData.asteroids do		local asteroidData = util.CopyTable(levelData.asteroids[i])		asteroidData.pos = {self.sunX + asteroidData.pos[1], self.sunY + asteroidData.pos[2]}		asteroidData.velocity = asteroidData.velocity or api.GetCircularOrbitVelocity(			asteroidData.pos, asteroidData.orbitMult, asteroidData.orbitAngle)		EnemyHandler.AddAsteroid(asteroidData)	end		local sunData = {		pos = {self.sunX, self.sunY},		radius = levelData.sun.radius,		image = levelData.sun.image,		density = 1000,		gravity = levelData.gravity	}	AddSun(sunData)		local playerData = util.CopyTable(levelData.player)	playerData.pos = {self.sunX + playerData.pos[1], self.sunY + playerData.pos[2]}	playerData.velocity = playerData.velocity or api.GetCircularOrbitVelocity(		playerData.pos, playerData.orbitMult, playerData.orbitAngle)	PlayerHandler.SpawnPlayer(playerData)
end
---------------------------------------------------------------------------------------------------------------------------------------------- Callins
function api.Update(dt)
	IterableMap.ApplySelf(self.planets, "Update", dt)	IterableMap.ApplySelf(self.suns, "Update", dt)
end

function api.Draw(drawQueue)
	drawQueue:push({y=-100; f=function()		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.rectangle("line", 0, 0, self.width, self.height)
	end})
	IterableMap.ApplySelf(self.planets, "Draw", drawQueue)	IterableMap.ApplySelf(self.suns, "Draw", drawQueue)
end

function api.Initialize(world, levelData)
	self = {
		world = world,
		width = Global.WORLD_WIDTH,
		height = Global.WORLD_HEIGHT,
		planets = IterableMap.New(),		suns = IterableMap.New(),		planetNameList = {},		planetImageList = {},
	}
	
	SetupLevel(levelData)
end

return api
