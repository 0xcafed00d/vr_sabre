local shaders = {
	grid_shader = lovr.graphics.newShader([[
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
	]], { flags = { highp = true } }),
	
	standard_shader = lovr.graphics.newShader('standard', {
	flags = {
		normalMap = false,
		indirectLighting = true,
		occlusion = true,
		emissive = true,
		skipTonemap = false
		}	  
	})
}

return shaders