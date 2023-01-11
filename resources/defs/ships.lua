local images = {}

local toAdd = {
	"ship",
	"smuggler",
	"p_thrust",
	"p_left",
	"p_right",
	"p_slow",
	"police_thrust",
	"smuggler_thrust",
	"police_left",
	"police_right",
}

local scale = {
	smuggler = 1.1
}

local shipOff = 0.445

local xOff = {
	ship = shipOff,
	p_thrust = shipOff,
	p_left = shipOff,
	p_right = shipOff,
	p_slow = shipOff,
	police = 0.52,
	smuggler = 0.52,
}

for i = 1, #toAdd do
	local name = toAdd[i]
	images[#images + 1] = {
		name = name,
		form = "image", -- image, sound or animation
		file = "resources/images/characters/" .. name .. ".png",
		xScale = 0.003257 * (scale[name] or 1),
		yScale = 0.003257 * (scale[name] or 1),
		xOffset = xOff[name] or 0.5,
		yOffset = 0.5,
	}
end

return images
