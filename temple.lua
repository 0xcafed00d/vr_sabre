local utils = require "utils"
local shaders = require "shaders"


local temple = {
	debug = true
}

function temple.new()
	local i = utils.fromclass(temple)
	return i
end

function temple:init()
	if temple.model == nil then
		temple.model = lovr.graphics.newModel("assets/temple.glb")
	end
end

function temple:update(dt)
end

function temple:draw() 
	lovr.graphics.setShader(shaders.lit_shader)
	lovr.graphics.setColor(0xffffff)
	self.model:draw(mat4():scale(10))
	lovr.graphics.setShader()
end

return temple