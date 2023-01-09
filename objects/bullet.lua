
local Resources = require("resourceHandler")
local Font = require("include/font")
local planetUtils = require("utilities/planetUtils")

local BulletDefs = util.LoadDefDirectory("defs/bullet")

local function New(self, physicsWorld)
	-- pos
	self.animTime = 0
	self.objType = "bullet"
	self.def = util.CopyTable(BulletDefs[self.def.typeName], false, self.def)
	
	self.body = love.physics.newBody(physicsWorld, self.def.pos[1], self.def.pos[2], "dynamic")
	self.shape = love.physics.newCircleShape(self.def.radius)
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density)
	
	if self.def.velocity then
		self.body:setLinearVelocity(self.def.velocity[1], self.def.velocity[2])
	end
	self.body:setUserData(self)
	self.fixture:setFriction(0.6)
	
	 self.life =  self.def.life
	
	function self.Destroy()
		if self.isDead then
			return
		end
		local bx, by = self.body:getWorldCenter()
		for i = 1, 5 do
			EffectsHandler.SpawnEffect(
				"fireball_explode",
				util.Add({bx, by}, util.RandomPointInCircle(self.def.radius*0.6)),
				{
					delay = math.random()*0.2,
					scale = 0.15 + 0.2*math.random(),
					animSpeed = 1 + 0.8*math.random()
				}
			)
		end
		self.isDead = true
	end
	
	function self.Update(dt)
		self.life = self.life - dt
		if self.isDead or self.life < 0 then
			self.isDead = true
			self.body:destroy()
			return true
		end
		self.animTime = self.animTime + dt
		
		TerrainHandler.WrapBody(self.body)
		TerrainHandler.ApplyGravity(self.body)
		TerrainHandler.UpdateSpeedLimit(self.body, Global.BULLET_SPEED_LIMIT, self.def.minDampening)
		
		if self.def.homingForce and self.def.target and not self.def.target:isDestroyed() then
			local tx, ty = self.def.target:getWorldCenter()
			planetUtils.ApplyForceTowards(self.body, {tx, ty}, self.def.homingForce, true)
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=3; f=function()
			love.graphics.push()
				local x, y = self.body:getWorldCenter()
				local angle
				if self.def.homingForce and self.def.target and not self.def.target:isDestroyed() then
					local tx, ty = self.def.target:getWorldCenter()
					angle = util.Angle(tx - x, ty - y)
				else
					local vx, vy = self.body:getLinearVelocity()
					angle = util.Angle(vx, vy)
				end
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				Resources.DrawImage(self.def.image, 0, 0, 0, math.min(1, self.life), self.def.radius)
				if Global.DRAW_PHYSICS then
					love.graphics.setColor(1, 1, 1, math.min(1, self.life))
					love.graphics.circle("line", 0, 0, self.def.radius)
				end
			love.graphics.pop()
		end})
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return New
