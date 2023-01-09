
local Resources = require("resourceHandler")
local Font = require("include/font")

local DRAW_DEBUG = false

local function NewEffect(self, def)
	-- pos
	self.inFront = def.inFront or 0
	local maxLife = (def.duration == "inherit" and def.image and Resources.GetAnimationDuration(def.image)) or def.duration
	if not maxLife then
		print(maxLife, def.image, def.actual_image)
	end
	self.life = maxLife / (self.animSpeed or 1)
	self.animTime = 0
	self.direction = self.direction  or (def.randomDirection and math.random()*2*math.pi) or 0
	self.delay = self.delay or 0
	self.scale = self.scale or def.scale
	
	self.pos = (def.spawnOffset and util.Add(self.pos, def.spawnOffset)) or self.pos
	
	local function GetAlpha()
		if not def.alphaScale then
			return 1
		end
		if def.alphaBuffer then
			if self.life / maxLife > 1 - def.alphaBuffer then
				return 1
			end
			return (self.life / maxLife) / (1 - def.alphaBuffer)
		end
		return self.life/maxLife
	end
	
	function self.Update(dt)
		if self.delay > 0 then
			self.delay = self.delay - dt
			return
		end
		self.animTime = self.animTime + dt*(self.animSpeed or 1)
		self.life = self.life - dt
		if self.life <= 0 then
			return true
		end
		
		if self.velocity then
			self.pos = util.Add(self.pos, util.Mult(dt, self.velocity))
		end
		if self.angularVelocity then
			self.direction = self.direction + dt * self.angularVelocity
		end
	end
	
	function self.Draw(drawQueue)
		if self.delay > 0 then
			return
		end
		drawQueue:push({y=self.pos[2] + self.inFront; f=function()
			if def.fontSize and self.text then
				local col = def.color
				Font.SetSize(def.fontSize)
				love.graphics.setColor((col and col[1]) or 1, (col and col[2]) or 1, (col and col[3]) or 1, GetAlpha())
				love.graphics.printf(self.text, self.pos[1] - def.textWidth/2, self.pos[2] - def.textHeight, def.textWidth, "center")
				love.graphics.setColor(1, 1, 1, 1)
			elseif self.actualImageOverride or def.actual_image then
				local scale = (self.scale or 1)*((def.lifeScale and (1 - 0.5*self.life/maxLife)) or 1)
				if def.shrink then
					scale = (self.scale or 1)*self.life/maxLife
				end
				Resources.DrawImage(self.actualImageOverride or def.actual_image, self.pos[1], self.pos[2], self.direction, GetAlpha(), scale, def.color)
			else
				Resources.DrawAnimation(def.image, self.pos[1], self.pos[2], self.animTime, self.direction, GetAlpha(),
					(self.scale or 1)*((def.lifeScale and (1 - 0.5*self.life/maxLife)) or 1),
				def.color)
			end
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	function self.DrawInterface()
		if self.delay > 0 then
			return
		end
		if self.actualImageOverride or def.actual_image then
			Resources.DrawImage(self.actualImageOverride or def.actual_image, self.pos[1], self.pos[2], self.direction, GetAlpha(),
					(self.scale or 1)*((def.lifeScale and (1 - 0.5*self.life/maxLife)) or 1),
				def.color)
		else
			Resources.DrawAnimation(def.image, self.pos[1], self.pos[2], self.animTime, self.direction, GetAlpha(),
					(self.scale or 1)*((def.lifeScale and (1 - 0.5*self.life/maxLife)) or 1),
				def.color)
		end
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], 100)
		end
	end
	
	return self
end

return NewEffect
