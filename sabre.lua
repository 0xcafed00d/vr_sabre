local utils = require "utils"
local sabre = {
	debug = false,
}

function sabre.new() 
	local i = utils.fromclass(sabre)
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

	if self.hilt_model == nil then
		self.hilt_model = lovr.graphics.newModel("assets/hilt.glb")
	end
end

function sabre:update(dt, hand_pose_mat4)
	self.blade_pose:set(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0))

	local v1 = vec3(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0))
	local v2 = vec3(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, -1))


	if self.last_blade_start == nil then 
		self.last_blade_start = lovr.math.newVec3(v1)
		self.last_blade_end = lovr.math.newVec3(v2)
	else
		self.last_blade_start:set(self.blade_start)
		self.last_blade_end:set(self.blade_end)
	end

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

		local m1 = mat4(self.blade_pose):translate(0, 0, -0.5) -- blade pos

		-- draw hilt
		lovr.graphics.setShader(self.hilt_shader)
		lovr.graphics.setColor(0xffffff)
		self.hilt_model:draw(self.blade_pose:translate(0, -0.02, 0.14):scale(0.04))	

		-- draw blade core 
		lovr.graphics.setShader(self.blade_shader)
		lovr.graphics.setColor(self.colour)
		lovr.graphics.sphere(self.blade_end, 0.01)
		lovr.graphics.cylinder(m1, 0.01, 0.01, true)

		-- draw blade glow 
		lovr.graphics.setBlendMode("add", "alphamultiply")
		lovr.graphics.cylinder(m1, 0.02, 0.02, true)
		lovr.graphics.sphere(self.blade_end, 0.019)
		lovr.graphics.setBlendMode("alpha", "alphamultiply")


--		lovr.graphics.line(self.last_blade_start.xyz, self.last_blade_end.xyz)

		lovr.graphics.setShader()
	end
end

return sabre