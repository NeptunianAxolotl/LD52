local images = {}

local toAdd = {
	"philosopher",
	"inventor",
	"scientist",
}

for i = 1, #toAdd do
	local name = toAdd[i]
	images[#images + 1] = {
		name = name .. "_abduct",
		form = "animation", -- image, sound or animation
		fileList = {"resources/images/characters/" .. name .. ".png", "resources/images/characters/" .. name .. "_surprise.png"},
		xScale = 0.0050,
		yScale = 0.0050,
		xOffset = 0.5,
		yOffset = 0.5,
		duration = 0.3,
	}
end

return images
