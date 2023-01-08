local images = {}

local toAdd = {
	"ship",
	"police",
}

for i = 1, #toAdd do
	local name = toAdd[i]
	images[#images + 1] = {
		name = name,
		form = "image", -- image, sound or animation
		file = "resources/images/characters/" .. name .. ".png",
		xScale = 0.19*1.2 * 1.2,
		yScale = 0.19*1.2 * 1.2,
		xOffset = 0.45,
		yOffset = 0.5,
	}
end

return images
