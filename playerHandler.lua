
--local EffectDefs = util.LoadDefDirectory("effects")
local NewPlayerShip = require("objects/playerShip")
local Font = require("include/font")

local self = {}
local api = {}

local guyTypeList = {
	"philosopher",
	"inventor",
	"scientist",
}

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

function api.GetDistanceToPlayer(pos)
	local playerBody = api.GetPlayerShipBody()
	if not playerBody then
		return false
	end
	local x, y = playerBody:getWorldCenter()
	return util.Dist(x, y, pos[1], pos[2])
end

function api.SetAbducting(guyType, linkedBody, linkedRadius)
	if self.abducting then
		return false
	end
	self.abducting = true
	self.abductProgress = 0
	self.abductType = guyType
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
		self.abductProgress = self.abductProgress + dt*Global.ABDUCT_SPEED
		if self.abductProgress > 1 then
			self.abducting = false
			self.abductBody = false
			self.abductScore[self.abductType] = (self.abductScore[self.abductType] or 0) + 1
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
				Resources.DrawImage(self.abductType, abductPos[1], abductPos[2], 0, 1, self.abductRadius*(1 - self.abductProgress))
				
				love.graphics.setColor(1, 1, 0, 0.6)
				love.graphics.polygon("fill", sX, sY, planetLeft[1], planetLeft[2], planetRight[1], planetRight[2])
			end})
		end
	end
end

function api.DrawInterface()
	local offset = 20
	for i = 1, #guyTypeList do
		local guyType = guyTypeList[i]
		if (self.abductScore[guyType] or 0) > 0 then
			Resources.DrawImage(guyType, 1740, offset + 80, 0, 1, 80)
			love.graphics.setColor(1, 1, 1, 1)
			Font.SetSize(3)
			love.graphics.printf((self.abductScore[guyType] or 0), 1825, offset + 50, 90, "left")
			
			offset = offset + 130
		end
	end
end

function api.Initialize(world)
	self = {
		playerShip = false,
		animationTimer = 0,
		world = world,
		abductScore = {}
	}
end

return api
