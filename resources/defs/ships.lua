local images = {}

local toAdd = {
	"ship",
	"police",
	"smuggler",
}

local scale = {
	smuggler = 1.1
}

local xOff = {
	ship = 0.45,
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
