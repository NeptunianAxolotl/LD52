local images = {}

local toAdd = {
	"philosopher",
	"inventor",
	"scientist",
}

for i = 1, #toAdd do
	local name = toAdd[i]
	images[#images + 1] = {
		name = name,
		form = "image", -- image, sound or animation
		file = "resources/images/characters/" .. name .. ".png",
		xScale = 0.01050,
		yScale = 0.01050,
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return images
