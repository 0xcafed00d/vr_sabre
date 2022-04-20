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
	

	standard_shader = lovr.graphics.newShader(
		[[
			out vec3 FragmentPos;
			out vec3 Normal;
	
			vec4 position(mat4 projection, mat4 transform, vec4 vertex) { 
				Normal = lovrNormal;
				FragmentPos = (lovrModel * vertex).xyz;
			
				return projection * transform * vertex;
			}
		]],
		[[
			uniform vec4 liteColor;
	
			uniform vec4 ambience;
		
			in vec3 Normal;
			in vec3 FragmentPos;
			uniform vec3 lightPos;
	
			uniform vec3 viewPos;
			uniform float specularStrength;
			uniform float metallic;
			
			vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
			{    
				//diffuse
				vec3 norm = normalize(Normal);
				vec3 lightDir = normalize(lightPos - FragmentPos);
				float diff = max(dot(norm, lightDir), 0.0);
				vec4 diffuse = diff * liteColor;
				
				//specular
				vec3 viewDir = normalize(viewPos - FragmentPos);
				vec3 reflectDir = reflect(-lightDir, norm);
				float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
				vec4 specular = specularStrength * spec * liteColor;
				
				vec4 baseColor = graphicsColor * texture(image, uv) * lovrDiffuseColor;         
				//vec4 objectColor = baseColor * vertexColor;
	
				return baseColor * (ambience + diffuse + specular);
			}
		]], {}),

		unlit_shader = lovr.graphics.newShader(
		[[
			out vec3 Normal;

			vec4 position(mat4 projection, mat4 transform, vec4 vertex)
			{
				Normal = lovrNormal;
				return projection * transform * vertex;
			}
		]],
		[[
			in vec3 Normal;

			vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
			{
				return vec4(Normal, 0.5);
				//return graphicsColor * lovrDiffuseColor * vertexColor * texture(image, uv);
			}
		]],{})
}

return shaders