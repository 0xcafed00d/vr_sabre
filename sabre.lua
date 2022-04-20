local utils = require "utils"
local sabre = {
	saber_colours = {0x00ff00, 0x0000ff, 0xff0000}
}

function sabre.new() 
	local i = utils.fromclass(sabre)
	i.debug = true
	i.blade_start = lovr.math.newVec3()
	i.blade_end = lovr.math.newVec3()
	i.blade_pose = lovr.math.newMat4()
	return i
end

function sabre:init(hilt_shader, blade_shader, colour)
	self.hilt_shader = hilt_shader
	self.blade_shader = blade_shader
	self.colour = colour

	if sabre.hilt_model == nil then
		sabre.hilt_model = lovr.graphics.newModel("assets/hilt.glb")
	end
end

function sabre:update(dt, hand_pose_mat4)
	self.blade_pose.set(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0))
	
	self.blade_start.set(vec3(self.blade_pose));
	self.blade_end.set(vec3(self.blade_pose:translate(0, 0, -1)))	
end

function sabre:draw() 
	local m1 = self.blade_pose:translate(0, 0, -0.5)

	lovr.graphics.setShader(sabre.blade_shader)
	lovr.graphics.setColor(self.colour)
	lovr.graphics.cylinder(m1, 0.01, 0.01, true)
	lovr.graphics.setShader()

end

return sabre