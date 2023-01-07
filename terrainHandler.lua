
local Font = require("include/font")

local MapDefs = util.LoadDefDirectory("defs/maps")
local NewPlanet = require("objects/planet")local NewSun = require("objects/sun")

local self = {}
local api = {}

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

function api.UpdateSpeedLimit(body)
	local vx, vy = body:getLinearVelocity()
	local speedSq = util.DistSq(0, 0, vx, vy)
	if speedSq < Global.SPEED_LIMIT * Global.SPEED_LIMIT then
		body:setLinearDamping(0)
		return
	end
	local speed = math.sqrt(speedSq)
	body:setLinearDamping((speed - Global.SPEED_LIMIT) / Global.SPEED_LIMIT)
end

local function AddPlanet(data)
	IterableMap.Add(self.planets, NewPlanet({def = data}, self.world.GetPhysicsWorld()))
end
local function AddSun(data)	IterableMap.Add(self.suns, NewSun({def = data}, self.world.GetPhysicsWorld()))end
local function GetCircularOrbitVelocity(pos, factor)	factor = factor or 1
	local toSun, dist = util.Unit({pos[1] - self.sunX, pos[2] - self.sunY})
	local speed = math.sqrt(self.sunGravity / dist)
	return util.RotateVector({0, -1*factor*speed}, util.Angle(toSun))
end

local function SetupLevel()
	-- TODO self.map = {}	self.sunGravity = Global.GRAVITY_MULT * 15	
	local pos = {1800, Global.WORLD_HEIGHT/2}
	local planetData = {
		pos = pos,
		velocity = GetCircularOrbitVelocity(pos),
		radius = 80,
		density = 150
	}
	AddPlanet(planetData)		local sunData = {		pos = {self.sunX, self.sunY},		radius = 200,		density = 1000	}	AddSun(sunData)		pos = {2500, 1200}	local initPlayerData = {		pos = pos,		velocity = GetCircularOrbitVelocity(pos, -0.8)	}	PlayerHandler.SpawnPlayer(initPlayerData)
end

function api.Update(dt)
	IterableMap.ApplySelf(self.planets, "Update", dt)	IterableMap.ApplySelf(self.suns, "Update", dt)
end

function api.Draw(drawQueue)
	drawQueue:push({y=0; f=function()
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
