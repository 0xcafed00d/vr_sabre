local utils = require "utils"
local shaders = require "shaders"

local sabre = {
	debug = false,
}

function sabre.new() 
	local i = utils.fromclass(sabre)
	i.blade_start = lovr.math.newVec3()
	i.blade_end = lovr.math.newVec3()
	i.blade_pose = lovr.math.newMat4()
	i.hilt_pose = lovr.math.newMat4()
	i.active = false
	return i
end

function sabre:init(glowColor_vec3, colour)
	self.colour = colour
	self.glowColor = glowColor_vec3

	if self.hilt_model == nil then
		self.hilt_model = lovr.graphics.newModel("assets/hilt.glb")
	end

	self.hilt_offset = 0.03
end

function sabre:update(dt, hand_pose_mat4)
	self.hilt_pose:set(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0):translate(0,0,0.09-self.hilt_offset):scale(0.04))
	self.blade_pose:set(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0,-self.hilt_offset))

	local v1 = vec3(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, -self.hilt_offset))
	local v2 = vec3(hand_pose_mat4*mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, -1-self.hilt_offset))

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

		local m1 = mat4(self.blade_pose):translate(0, 0, -0.5) -- blade origin - center on blade

		-- draw hilt
		lovr.graphics.setShader(shaders.lit_shader)
		lovr.graphics.setColor(0xffffff)
		self.hilt_model:draw(self.hilt_pose)	

		-- draw blade core 
		lovr.graphics.setShader(shaders.unlit_shader)
		lovr.graphics.setColor(self.colour)
		lovr.graphics.sphere(self.blade_end, 0.01)
		lovr.graphics.cylinder(m1, 0.01, 0.01, false)

		-- draw blade glow 
		lovr.graphics.setShader(shaders.glow_shader)

		shaders.glow_shader:send('glowColor', self.glowColor)
		shaders.glow_shader:send('pos', self.blade_start)

		lovr.graphics.setBlendMode("add", "alphamultiply")
		lovr.graphics.cylinder(m1, 0.02, 0.02, false)
		lovr.graphics.sphere(self.blade_end, 0.019)
		lovr.graphics.setBlendMode("alpha", "alphamultiply")

		lovr.graphics.setShader()
	end
end

return sabre