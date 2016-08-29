--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 16:17:01
--

local HeroGroup = class("HeroGroup",
						{
						heros = {},
						speed = 0,
						name = "",
						})

function HeroGroup:ctor(name)
	self:setName(name)
end

function HeroGroup:getHeros()
	return self.heros
end


function HeroGroup:add(hero)
	local heros = self:getHeros()
	hero:setGroupName(self:getName())
	table.insert(heros,hero)
end

function HeroGroup:addSpeed(hero)
	local hero_speed = hero:getAttr("speed")
	self.speed = self.speed + hero_speed 
end

function HeroGroup:getSpeed()
	return self.speed
end

function HeroGroup:setName(var)
	self.name = var
end
function HeroGroup:getName()
	return self.name
end

function HeroGroup:remove(hero)
	-- body
end

function HeroGroup:release()
	-- body
end

return HeroGroup
