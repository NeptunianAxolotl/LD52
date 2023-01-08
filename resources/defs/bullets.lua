local images = {}

local toAdd = {
	"bullet_modern",
	"bullet_police",
	"bullet_ship",
	"bullet_space",
}

for i = 1, #toAdd do
	local name = toAdd[i]
	images[#images + 1] = {
		name = name,
		form = "image", -- image, sound or animation
		file = "resources/images/bits/" .. name .. ".png",
		xScale = 0.01050,
		yScale = 0.01050,
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return images
