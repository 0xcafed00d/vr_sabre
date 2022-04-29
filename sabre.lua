local utils = require "utils"
local sabre = {
}

function sabre.new() 
	local i = utils.fromclass(sabre)
	i.debug = true
	i.blade_start = lovr.math.newVec3()
	i.blade_end = lovr.math.newVec3()
	i.blade_pose = lovr.math.newMat4()
	i.active = false
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
	self.blade_pose:set(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0))

	local v1 = vec3(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0))
	local v2 = vec3(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, -1))

	self.blade_start:set(v1);
	self.blade_end:set(v2);
	
	self.active = true	
end

function sabre:draw() 
	if self.active == true then 

		if self.debug then 
			draw_marker(self.blade_start, 0xff00ff)
			draw_marker(self.blade_end, 0xff00ff)
		end
			
		local m1 = mat4(self.blade_pose):translate(0, 0, -0.5)
		lovr.graphics.setShader(sabre.blade_shader)
		lovr.graphics.setColor(self.colour)
		lovr.graphics.cylinder(m1, 0.01, 0.01, true)

		lovr.graphics.setShader(self.hilt_shader)
		lovr.graphics.setColor(0xffffff)
		sabre.hilt_model:draw(self.blade_pose:translate(0, -0.02, 0.15):scale(0.04))	
		lovr.graphics.setShader()
	end
end

return sabre