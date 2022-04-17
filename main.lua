
local saber_colours = {0x00ff00, 0x0000ff, 0xff0000}

local data = {
	sabre_count = 0,
	sabre_info = {},
}

function lovr.load()
	
	shader = lovr.graphics.newShader([[
		vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
		  return projection * transform * vertex;
		}
	]], 
	[[
		const float gridSize = 25.;
		const float cellSize = .5;
	
		vec4 color(vec4 gcolor, sampler2D image, vec2 uv) {
	
		  // Distance-based alpha (1. at the middle, 0. at edges)
		  float alpha = 1. - smoothstep(.15, .50, distance(uv, vec2(.5)));
	
		  // Grid coordinate
		  uv *= gridSize;
		  uv /= cellSize;
		  vec2 c = abs(fract(uv - .5) - .5) / fwidth(uv);
		  float line = clamp(1. - min(c.x, c.y), 0., 1.);
		  vec3 value = mix(vec3(.01, .01, .011), (vec3(.04)), line);
	
		  return vec4(vec3(value), alpha);
		}
	  ]], { flags = { highp = true } })
	
	  shader2 = lovr.graphics.newShader('standard', {
		flags = { animated = true }
	  })

	  lovr.graphics.setBackgroundColor(.05, .05, .05)

	  world = lovr.physics.newWorld(0,-1,0)
	  world:newBoxCollider(0, -2.5, 0, 5, 5, 5):setKinematic(true) -- floor
	  world:newBoxCollider(0, 7.5, 0, 5, 5, 5):setKinematic(true) -- roof

	  world:newBoxCollider( 5, 2.5, 0, 5, 5, 5):setKinematic(true)  -- right wall
	  world:newBoxCollider(-5, 2.5, 0, 5, 5, 5):setKinematic(true)  -- left wall
	  world:newBoxCollider( 0, 2.5, 5, 5, 5, 5):setKinematic(true)  -- back wall
	  world:newBoxCollider( 0, 2.5,-5, 5, 5, 5):setKinematic(true)  -- front wall

	  sphere = world:newSphereCollider(0, 2, 0, 0.10)
	  sphere:setRestitution(1)

	  hilt = lovr.graphics.newModel("assets/hilt.glb")
end

function lovr.update(dt)
	world:update(dt)

	for i, hand in ipairs(lovr.headset.getHands()) do
    	if lovr.headset.wasPressed(hand, 'trigger') then
      		local position = vec3(lovr.headset.getPosition(hand))
    	end
  	end
end

local draw_marker = function (pos_vec3, colour)	
	lovr.graphics.setColor(colour)
	lovr.graphics.sphere(pos_vec3, 0.02);
end

local draw_sabre = function (pos, colour, device)	
	
	local v1 = vec3(pos*mat4():rotate(math.pi/4, 1, 0, 0))
	local v2 = vec3(pos*mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, -1))
	draw_marker(v1, 0xff00ff)
	draw_marker(v2, 0xffff00)

	world:raycast(v1, v2, 
		function(shape, x, y, z, nx, ny, nz)
			draw_marker(vec3(x, y, z), 0xff0000)
			shape:getCollider():applyForce(-nx, -ny, -nz)
			lovr.headset.vibrate(device, 1, 0.25, 0)
		end
	)


	local m1 = mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, -0.5)

	lovr.graphics.setColor(colour)
	lovr.graphics.cylinder(pos*m1, 0.01, 0.01, true)

	local m2 = mat4():rotate(math.pi/4, 1, 0, 0):translate(0, -0.02, 0.15)

	lovr.graphics.setColor(0xffffff)
	lovr.graphics.setShader(shader2)
	hilt:draw(pos*m2:scale(0.04))
	lovr.graphics.setShader()


--	lovr.graphics.setColor(0x777777)
--	lovr.graphics.cylinder((pos*m2):scale(0.14), 0.015, 0.015, true)
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
	lovr.graphics.setShader(shader)
	lovr.graphics.plane('fill', 0, 0, 0, 25, 25, -math.pi / 2, 1, 0, 0)
	lovr.graphics.setShader()

	-- draw sabres -- 
	for i, hand in ipairs(lovr.headset.getHands()) do
		local pos = mat4(lovr.headset.getPose(hand))
		draw_sabre(pos, saber_colours[i], hand)
	end

	lovr.graphics.setColor(0x00ffff)	
	lovr.graphics.sphere(mat4(sphere:getPose()):scale(0.1));

	draw_axis(vec3(0,0,0))

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
end
