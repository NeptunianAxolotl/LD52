
--local EffectDefs = util.LoadDefDirectory("effects")
local NewPlayerShip = require("objects/playerShip")
local Font = require("include/font")

local self = {}
local api = {}

function api.SpawnPlayer(initPlayerData)
	self.playerShip = NewPlayerShip({def = initPlayerData}, self.world.GetPhysicsWorld())
end

function api.Collision(aData, bData)

end

function api.GetPlayerShip()
	return self.playerShip
end

function api.GetPlayerShipBody()
	return self.playerShip and self.playerShip.GetBody()
end

function api.GetAbductPlanet()
	return self.abductPlanet
end

function api.GetDistanceToPlayer(pos)
	local playerBody = api.GetPlayerShipBody()
	if not playerBody then
		return false
	end
	local x, y = playerBody:getWorldCenter()
	return util.Dist(x, y, pos[1], pos[2])
end

function api.SetAbducting(guyType, planetName, linkedBody, linkedRadius)
	if self.abducting then
		return false
	end
	if api.GetPlayerShip().stasisProgress then
		return false
	end
	SoundHandler.PlaySound("abduct")
	self.abducting = true
	self.abductProgress = 0
	self.abductType = guyType
	self.abductPlanet = planetName
	self.abductBody = linkedBody
	self.abductRadius = linkedRadius
	
	local bx, by = self.abductBody:getWorldCenter()
	self.abductPos = {bx, by}
	return true
end

function api.ApplyToPlayer(func, ...)
	if not self.playerShip then
		return
	end
	func(false, self.playerShip, false, ...)
end

function api.Update(dt)
	if self.playerShip then
		self.playerShip.Update(dt)
	end
	if self.abducting then
		self.animationTimer = self.animationTimer + dt
		self.abductProgress = self.abductProgress + dt*Global.ABDUCT_SPEED
		if self.abductProgress > 1 then
			self.abducting = false
			GameHandler.AddAbduct(self.abductType, self.abductPlanet)
			self.abductType = false
			self.abductPlanet = false
			local body = api.GetPlayerShipBody()
			if body and self.abductBody and not self.abductBody:isDestroyed() then
				local bx, by = body:getWorldCenter()
				local vx, vy = self.abductBody:getLinearVelocity()
				EffectsHandler.SpawnEffect(
					"enter_ship",
					self.abductPos,
					{velocity = {vx, vy}}
				)
				EffectsHandler.SpawnEffect(
					"enter_ship",
					{bx, by},
					{scale = 0.45}
				)
			end
			self.abductBody = false
		end
	end
end

function api.Draw(drawQueue)
	if self.playerShip then
		self.playerShip.Draw(drawQueue)
		if self.abducting then
			if self.abductBody and not self.abductBody:isDestroyed() then
				local bx, by = self.abductBody:getWorldCenter()
				self.abductPos[1], self.abductPos[2] = bx, by
			end
			
			local sX, sY = api.GetPlayerShipBody():getWorldCenter()
			local toShip, shipDist = util.Unit(util.Subtract({sX, sY}, self.abductPos))
			local triangleRad = self.abductRadius*math.sqrt(1 - self.abductProgress)
			local planetLeft = util.Add(self.abductPos, util.RotateVector(util.Mult(triangleRad, toShip), 0.5*math.pi))
			local planetRight = util.Add(self.abductPos, util.RotateVector(util.Mult(triangleRad, toShip), -0.5*math.pi))
			local abductPos = util.Add(self.abductPos, util.Mult(self.abductProgress * shipDist, toShip))
			
			drawQueue:push({y=10; f=function()
				Resources.DrawAnimation(self.abductType .. "_abduct", abductPos[1], abductPos[2], self.animationTimer, 0, 1, self.abductRadius*(1 - self.abductProgress))
				
				love.graphics.setColor(255/255, 216/255, 0/255, 0.6)
				love.graphics.polygon("fill", sX, sY, planetLeft[1], planetLeft[2], planetRight[1], planetRight[2])
			end})
		end
	end
end

function api.DrawInterface()
end

function api.Initialize(world)
	self = {
		playerShip = false,
		animationTimer = 0,
		world = world
	}
end

return api
