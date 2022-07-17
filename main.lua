
local droid = require "droid"
local sabre = require "sabre"
local shaders = require "shaders"
local temple = require "temple"

local saber_colours = {0xffffff, 0xffffff, 0x00ff00, 0x0000ff, 0xff0000}

local data = {
	sabres = {}
}

function lovr.conf(t)
end

function lovr.load()
	skybox = lovr.graphics.newTexture({
		left   = 'assets/yokahama/negx.jpg',
		right  = 'assets/yokahama/posx.jpg',
		top    = 'assets/yokahama/posy.jpg',
		bottom = 'assets/yokahama/negy.jpg',
		back   = 'assets/yokahama/posz.jpg',
		front  = 'assets/yokahama/negz.jpg'
	})

	lovr.graphics.setCullingEnabled(true)

	shaders.lit_shader:send('liteColor', {0.9, 0.9, 0.9, 1.0})
    shaders.lit_shader:send('ambience', {0.02, 0.02, 0.02, 1.0})
    shaders.lit_shader:send('specularStrength', 1.0)
    shaders.lit_shader:send('metallic', 64.0)
	shaders.lit_shader:send('lightPos', {0.0, 5.0, 0.0})

	lovr.graphics.setBackgroundColor(.05, .05, .05)

	-- create driod
	data.droid = droid.new()
	data.droid:init(shaders.lit_shader)
	data.droid:setarea(vec3(0, 2, -3), vec3(2, 1, 1))	

	-- create 2 sabres 
	local sl = sabre.new()
	sl:init(lovr.math.newVec3(0.0, 1.0, 0.0), saber_colours[1])	
	local sr = sabre.new()
	sr:init(lovr.math.newVec3(0.0, 0.0, 1.0), saber_colours[2])	

	data.sabres["hand/left"] = sl
	data.sabres["hand/right"] = sr

	data.temple = temple.new()
	data.temple:init()
end

local frame = 0;
local time = 0;
local fps = 0;

local function update_hands(dt)
	for i, hand in ipairs(lovr.headset.getHands()) do
      	local pos = mat4(lovr.headset.getPose(hand))
		data.sabres[hand]:update(dt, pos)
  	end
end

function lovr.update(dt)
	-- Adjust head position (for shaders)
	if lovr.headset then 
		local hx, hy, hz = lovr.headset.getPosition()
		shaders.lit_shader:send('viewPos', { hx, hy, hz } )
		shaders.glow_shader:send('viewPos', { hx, hy, hz } )
	end
	data.droid:update(dt, vec3(lovr.headset.getPosition()))
	update_hands(dt)

	time = time + dt
	frame = frame + 1

	if time > 1 then 
		time = time - 1
		fps = frame
		frame = 0 
	end
end

draw_marker = function (pos_vec3, colour)	
	lovr.graphics.setColor(colour)
	lovr.graphics.sphere(pos_vec3, 0.02);
end

local draw_axis = function (pos)
	lovr.graphics.setColor(0xff0000)	
	lovr.graphics.box("fill", 0.5 + pos.x, 0 + pos.y, 0 + pos.z, 1, 0.01, 0.01, 0, 0, 1, 0)
	lovr.graphics.setColor(0x00ff00)	
	lovr.graphics.box("fill", 0 + pos.x, 0.5 + pos.y, 0 + pos.z, 0.01, 1, 0.01, 0, 0, 1, 0)
	lovr.graphics.setColor(0x0000ff)	
	lovr.graphics.box("fill", 0 + pos.x, 0 + pos.y, 0.5 + pos.z, 0.01, 0.01, 1, 0, 0, 1, 0)
	lovr.graphics.setColor(0xffffff)	
	lovr.graphics.cube("fill", 0 + pos.x, 0 + pos.y, 0 + pos.z, 0.1, 0, 0, 1, 0)
end	

function lovr.draw()
	lovr.graphics.setColor(0xffffff)	
	lovr.graphics.skybox(skybox)

	data.temple:draw()
	
	-- draw floor grid -- 
--	lovr.graphics.setShader(shaders.grid_shader)
--	lovr.graphics.plane('fill', 0, 0, 0, 25, 25, -math.pi / 2, 1, 0, 0)
--	lovr.graphics.setShader()

	draw_axis(vec3(0,0.2,0))

	draw_marker(vec3(0.0, 5.0, 0.0), 0xffff00)

	data.droid:draw()

	for k, sabre in pairs(data.sabres) do
		sabre:draw()
	end

	--lovr.graphics.print(fps, 1, 1, -3)
end
