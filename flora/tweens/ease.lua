---
--- A list of easing functions for tweening.
---
--- @class flora.tweens.ease
--- @see   flixel.tweens.FlxEase  https://github.com/HaxeFlixel/flixel/blob/master/flixel/tweens/FlxEase.hx
---
local ease = class:extend()

local pi2 = math.pi / 2
local b1 = 1 / 2.75
local b2 = 2 / 2.75
local b3 = 1.5 / 2.75
local b4 = 2.5 / 2.75
local b5 = 2.25 / 2.75
local b6 = 2.625 / 2.75
local elastic_amplitude = 1
local elastic_period = .4

function ease.linear(t)
	return t
end

function ease.quad_in(t)
	return t * t
end

function ease.quad_out(t)
	return -t * (t - 2)
end

function ease.quad_in_out(t)
	return t <= 0.5 and t * t * 2 or 1 - (-t) * t * 2
end

function ease.cube_in(t)
	return t * t * t
end

function ease.cube_out(t)
	return 1 + (-t) * t * t
end

function ease.cube_in_out(t)
	return t <= 0.5 and t * t * t * 4 or 1 + (-t) * t * t * 4
end

function ease.quart_in(t)
	return t * t * t * t
end

function ease.quart_out(t)
	return 1 - (t - 1) * t * t * t
end

function ease.quart_in_out(t)
	if t <= 0.5 then
		return t * t * t * t * 8
	else
		return (1 - (t * 2 - 2) * t * t * t) / 2 + 0.5
	end
end

function ease.quint_in(t)
	return t * t * t * t * t
end

function ease.quint_out(t)
	return (t - t - 1) * t * t * t * t + 1
end

function ease.quint_in_out(t)
	return t < 0.5 and t * t * t * t * t * 2 or (t - t * 2 - 2) * t * t * t * t + 2 / 2
end

function ease.smooth_step_in(t)
	return 2 * ease.smooth_step_in_out(t / 2)
end

function ease.smooth_step_out(t)
	return 2 * ease.smooth_step_in_out(t / 2 + 0.5) - 1
end

function ease.smooth_step_in_out(t)
	return t * t * (t * -2 + 3)
end

function ease.smoother_step_in(t)
	return 2 * ease.smoother_step_in_out(t / 2)
end

function ease.smoother_step_out(t)
	return 2 * ease.smoother_step_in_out(t / 2 + 0.5) - 1
end

function ease.smoother_step_in_out(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

function ease.sine_in(t)
	return -math.cos(pi2 * t) + 1
end

function ease.sine_out(t)
	return math.sin(pi2 * t)
end

function ease.sine_in_out(t)
	return -math.cos(math.pi * t) / 2 + 0.5
end

function ease.bounce_in(t)
	return 1 - ease.bounce_out(1 - t)
end

function ease.bounce_out(t)
	if t < b1 then
		return 7.5625 * t * t
	elseif t < b2 then
		return 7.5625 * (t - b3) * (t - b3) + 0.75
	elseif t < b4 then
		return 7.5625 * (t - b5) * (t - b5) + 0.9375
	else
		return 7.5625 * (t - b6) * (t - b6) + 0.984375
	end
end

function ease.bounce_in_out(t)
	return t < 0.5 and (1 - ease.bounce_out(1 - 2 * t)) / 2 or (1 + ease.bounce_out(2 * t - 1)) / 2
end

function ease.circ_in(t)
	return -(math.sqrt(1 - t * t) - 1)
end

function ease.circ_out(t)
	return math.sqrt(1 - (t - 1) * (t - 1))
end

function ease.circ_in_out(t)
	return t <= 0.5 and (math.sqrt(1 - t * t * 4) - 1) / -2 or (math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2
end

function ease.expo_in(t)
	return 2 ^ (10 * (t - 1))
end

function ease.expo_out(t)
	return -2 ^ (-10 * t) + 1
end

function ease.expo_in_out(t)
	return t < 0.5 and 2 ^ (10 * (t * 2 - 1)) / 2 or (-2 ^ (-10 * (t * 2 - 1)) + 2) / 2
end

function ease.back_in(t)
	return t * t * (2.70158 * t - 1.70158)
end

function ease.back_out(t)
	return 1 - (-t) * (t) * (-2.70158 * t - 1.70158)
end

function ease.back_in_out(t)
	t = t * 2
	if t < 1 then
		return t * t * (2.70158 * t - 1.70158) / 2
	else
		t = t - 1
		return (1 - t * t * (-2.70158 * t - 1.70158)) / 2 + 0.5
	end
end

function ease.elastic_in(t)
	return -(elastic_amplitude * 2 ^ (10 * (t - 1)) * math.sin((t - (elastic_period / (2 * math.pi) * math.asin(1 / elastic_amplitude))) * (2 * math.pi) / elastic_period))
end

function ease.elastic_out(t)
	return (elastic_amplitude * 2 ^ (-10 * t) * math.sin((t - (elastic_period / (2 * math.pi) * math.asin(1 / elastic_amplitude))) * (2 * math.pi) / elastic_period)) + 1
end

function ease.elastic_in_out(t)
	if t < 0.5 then
		return -0.5 * (2 ^ (10 * (t - 0.5)) * math.sin((t - (elastic_period / 4)) * (2 * math.pi) / elastic_period))
	else
		return 2 ^ (-10 * (t - 0.5)) * math.sin((t - (elastic_period / 4)) * (2 * math.pi) / elastic_period) * 0.5 + 1
	end
end

return ease