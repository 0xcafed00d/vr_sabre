local utils = {}

function utils.fromclass (c)
	local t = {}
	c.__index = c
	setmetatable(t, c)
	return t
end 

-- point in rectangle --
function utils.p_in_r (px, py, rx, ry, rw, rh)
	if (px < rx) then return false end
	if (py < ry) then return false end
	if (px > rx+rw) then return false end
	if (py > ry+rh) then return false end
	return true
end

-- point in circle --
function utils.p_in_c (px, py, cx, cy, cr)
	local d = sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy))
	return d <= cr
end

 
function utils.bit_true(v, b)
	return band(shr(v, b), 1) == 1
end

function utils.bit_false(v, b)
	return not bit_true(v, b)
end

function utils.irnd_exc(a, b)
	return flr(rnd(b-a) + a)
end

function utils.irnd_inc(a, b)
	return flr(rnd(b-a+1) + a)
end

function utils.map_value(val, min, max)
	if (val <= min) then return 0 end
	if (val >= max) then return 1 end

	val = val - min
	max = max - min
	val = val / max
	return val
end


return utils
