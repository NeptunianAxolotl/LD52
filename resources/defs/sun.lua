local images = {}

local toAdd = {
	"sun",
	"sun_flare_1",
	"sun_flare_2",
}

for i = 1, #toAdd do
	local name = toAdd[i]
	images[#images + 1] = {
		name = name,
		form = "image", -- image, sound or animation
		file = "resources/images/planets/" .. name .. ".png",
		xScale = 0.0036,
		yScale = 0.0036,
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return images
