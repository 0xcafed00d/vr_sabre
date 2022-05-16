local utils = require "utils"
local shaders = require "shaders"
local flux = require "flux"


local droid = {
	debug = true
}

function droid.new()
	local i = utils.fromclass(droid)
	i.player_pos = lovr.math.newVec3()
	i.position = lovr.math.newVec3()
	i.moveto = lovr.math.newVec3()
	i.movefrom = lovr.math.newVec3()
	return i
end

function droid:init()
	if droid.model == nil then
		droid.model = lovr.graphics.newModel("assets/droid.glb")
	end
end

function droid:newPosition(from_vec3)
	self.movefrom:set(from_vec3)
	self.moveto.x = lovr.math.random(self.area_center.x - self.area_range.x, self.area_center.x + self.area_range.x)
	self.moveto.y = lovr.math.random(self.area_center.y - self.area_range.y, self.area_center.y + self.area_range.y)
	self.moveto.z = lovr.math.random(self.area_center.z - self.area_range.z, self.area_center.z + self.area_range.z)
	self.timer = 0
end

function droid:setarea(center_vec3, range_vec3)
	self.active = true
	self.area_center = lovr.math.newVec3(center_vec3)
	self.area_range = lovr.math.newVec3(range_vec3)
	self.position:set(self.area_center)

	self:newPosition(self.position)
end

function droid:update(dt, player_pos_vec3)
	if self.active then
		self.player_pos:set(player_pos_vec3)
		
		self.position:set(vec3(self.movefrom):lerp(self.moveto, self.timer*self.timer))

		if self.timer == 1.0 then
			self:newPosition(self.position)
		end

		self.timer = self.timer + dt
		if self.timer > 1.0 then
			self.timer = 1.0
		end
	end
end

function droid:draw() 
	if self.active then
		lovr.graphics.setShader(shaders.lit_shader)
		lovr.graphics.setColor(0xffffff)
		self.model:draw(mat4(self.position):target(self.position, self.player_pos):scale(0.5))
		lovr.graphics.setShader()
	end
end

return droid