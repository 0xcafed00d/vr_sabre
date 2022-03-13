
local saber_colours = {0x00ff00, 0x0000ff, 0xff0000}

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
	
	  lovr.graphics.setBackgroundColor(.05, .05, .05)

	  world = lovr.physics.newWorld(0,0,0)
	  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
end

function lovr.update(dt)
	world:update(dt)

	for i, hand in ipairs(lovr.headset.getHands()) do
    	if lovr.headset.wasPressed(hand, 'trigger') then
      		local position = vec3(lovr.headset.getPosition(hand))
    	end
  	end
end

local draw_sabre = function (pos, colour)	
	local m1 = mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, -0.5)

	lovr.graphics.setColor(colour)
	lovr.graphics.cylinder(pos*m1, 0.01, 0.01, true)

	local m2 = mat4():rotate(math.pi/4, 1, 0, 0):translate(0, 0, 0.07)

	lovr.graphics.setColor(0x777777)
	lovr.graphics.cylinder((pos*m2):scale(0.14), 0.015, 0.015, true)
end

function lovr.draw()
	-- draw floor grid -- 
	lovr.graphics.setShader(shader)
	lovr.graphics.plane('fill', 0, 0, 0, 25, 25, -math.pi / 2, 1, 0, 0)
	lovr.graphics.setShader()

	-- draw sabres -- 
	for i, hand in ipairs(lovr.headset.getHands()) do
		local pos = mat4(lovr.headset.getPose(hand))
		draw_sabre(pos, saber_colours[i])
  	end

	-- draw room bounding box -- 
	lovr.graphics.setColor(0xffffff)	
	lovr.graphics.cube("fill", 0, 0, 0, 0.05, 0, 0, 1, 0)
	lovr.graphics.cube("line", 0, 2.51, 0, 5, 0, 0, 1, 0)
end
