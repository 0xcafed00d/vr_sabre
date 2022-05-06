local utils = require "utils"
local shaders = require "shaders"
local flux = require "flux"


local droid = {
	debug = true
}

function droid.new()
	local i = utils.fromclass(droid)
	i.player_pose = lovr.math.newMat4()
	return i
end

function droid:init()
	if droid.model == nil then
		droid.model = lovr.graphics.newModel("assets/droid.glb")
	end
end

function droid:update(dt, player_pose_mat4)
	self.player_pose:set(player_pose_mat4)
end

function droid:draw(pos_mat4) 
	lovr.graphics.setShader(shaders.lit_shader)
	lovr.graphics.setColor(0xffffff)
	self.model:draw(pos_mat4:target(vec3(pos_mat4), vec3(self.player_pose)):scale(0.25))
	lovr.graphics.setShader()
end

return droid