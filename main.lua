
local droid = require "droid"
local sabre = require "sabre"
local shaders = require "shaders"

local saber_colours = {0x00ff00, 0x0000ff, 0xff0000}

local data = {
	sabres = {}

}

function lovr.conf(t)
end

function lovr.load()
	print("ENTER: lovr.load")


	shaders.lit_shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
    shaders.lit_shader:send('ambience', {0.5, 0.5, 0.5, 1.0})
    shaders.lit_shader:send('specularStrength', 1.0)
    shaders.lit_shader:send('metallic', 64.0)
	shaders.lit_shader:send('lightPos', {0.0, 5.0, 0.0})

	lovr.graphics.setBackgroundColor(.05, .05, .05)

	world = lovr.physics.newWorld(0,-1,0)
	world:newBoxCollider(0, -2.5, 0, 5, 5, 5):setKinematic(true) -- floor
	world:newBoxCollider(0, 7.5, 0, 5, 5, 5):setKinematic(true) -- roof

	world:newBoxCollider( 5, 2.5, 0, 5, 5, 5):setKinematic(true)  -- right wall
	world:newBoxCollider(-5, 2.5, 0, 5, 5, 5):setKinematic(true)  -- left wall
	world:newBoxCollider( 0, 2.5, 5, 5, 5, 5):setKinematic(true)  -- back wall
	world:newBoxCollider( 0, 2.5,-5, 5, 5, 5):setKinematic(true)  -- front wall

	sphere = world:newSphereCollider(0, 2, -2, 0.10)
	sphere:setRestitution(1)

	hilt = lovr.graphics.newModel("assets/hilt.glb")

	-- create driod
	data.droid = droid.new()
	data.droid:init(shaders.lit_shader)	

	
	-- create 2 sabres 
	local sl = sabre.new()
	sl:init(shaders.lit_shader, shaders.unlit_shader, saber_colours[1])	
	local sr = sabre.new()
	sr:init(shaders.lit_shader, shaders.unlit_shader, saber_colours[2])	

	data.sabres["hand/left"] = sl
	data.sabres["hand/right"] = sr

	print("LEAVE: lovr.load")
end

local frame = 0;

local function update_hands(dt)
	for i, hand in ipairs(lovr.headset.getHands()) do
      	local pos = mat4(lovr.headset.getPose(hand))
		data.sabres[hand]:update(dt, pos)
  	end
end

function lovr.update(dt)

	-- Adjust head position (for specular)
	if lovr.headset then 
		hx, hy, hz = lovr.headset.getPosition()
		shaders.lit_shader:send('viewPos', { hx, hy, hz } )
	end

	world:update(dt)
	data.droid:update(dt, mat4(lovr.headset.getPosition()))

	update_hands(dt)
end

draw_marker = function (pos_vec3, colour)	
	lovr.graphics.setColor(colour)
	lovr.graphics.sphere(pos_vec3, 0.02);
end

local draw_sabre = function (pos, colour, device)	
	
	local v1 = vec3(pos*mat4():rotate(math.pi/4, 1, 0, 0))
	local v2 = vec3(pos*mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, -1))

	world:raycast(v1, v2, 
		function(shape, x, y, z, nx, ny, nz)
			draw_marker(vec3(x, y, z), 0xff0000)
			shape:getCollider():applyForce(-nx, -ny, -nz)
			lovr.headset.vibrate(device, 1, 0.25, 0)
		end
	)

end

local draw_axis = function (pos)
	lovr.graphics.setColor(0xff0000)	
	lovr.graphics.box("fill", 0.5, 0, 0, 1, 0.05, 0.05, 0, 0, 1, 0)
	lovr.graphics.setColor(0x00ff00)	
	lovr.graphics.box("fill", 0, 0.5, 0, 0.05, 1, 0.05, 0, 0, 1, 0)
	lovr.graphics.setColor(0x0000ff)	
	lovr.graphics.box("fill", 0, 0, 0.5, 0.05, 0.05, 1, 0, 0, 1, 0)
	lovr.graphics.setColor(0xffffff)	
	lovr.graphics.cube("fill", 0, 0, 0, 0.1, 0, 0, 1, 0)
end	


function lovr.draw()
	-- draw floor grid -- 
	lovr.graphics.setShader(shaders.grid_shader)
	lovr.graphics.plane('fill', 0, 0, 0, 25, 25, -math.pi / 2, 1, 0, 0)
	lovr.graphics.setShader()

	draw_axis(vec3(0,0,0))

	lovr.graphics.setColor(0x00ffff)	
	lovr.graphics.sphere(mat4(sphere:getPose()):scale(0.1));

	data.droid:draw(mat4(sphere:getPose()))

	-- draw room bounding box -- 
	lovr.graphics.setColor(0xffffff)	
	lovr.graphics.cube("line", 0, 2.51, 0, 5, 0, 0, 1, 0)

	lovr.graphics.setColor(0xff0000)	

	for i, collider in ipairs(world:getColliders()) do
	    local x,y,z, angle, ax,ay,az = collider:getPose()
		for _, shape in ipairs(collider:getShapes()) do
			local shapeType = shape:getType()
			if shapeType == 'box' then
				local sx, sy, sz = shape:getDimensions()
				lovr.graphics.box('line', x,y,z, sx,sy,sz, angle, ax,ay,az)
			end
		end
	end

	for k, sabre in pairs(data.sabres) do
		sabre:draw()
	end

	frame = frame + 1
end
