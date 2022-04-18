local sabre = {}

function sabre.new() 
	local i = fromclass(sabre)
	i.debug = true
	return i
end

function sabre:init(index)
	if sabre.hilt_model != nil then
		sabre.hilt_model = lovr.graphics.newModel("assets/hilt.glb")
	end
end

function sabre:update(dt, pos, index) 
	
end

function sabre:draw(dt, index) 
	
end

return sabre