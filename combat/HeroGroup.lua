--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 16:17:01
--

local HeroGroup = class__("HeroGroup",
						{
						heros = "{}",
						speed = "0",
						name = "nil",
						skills = "{}",
 
						})

function HeroGroup:ctor(name)
	self:setName(name)
end

function HeroGroup:getHeros()
	return self.heros
end
function HeroGroup:getSkills()
	return self.skills
end

function HeroGroup:add(hero)
	local heros = self:getHeros()
	hero:setGroup(self)
	table.insert(heros,hero)
end

function HeroGroup:addSpeed(hero)
	local hero_speed = hero:getAttr("speed")
	-- print("addSpeed",self:getName(),self:getSpeed())
	self.speed = self.speed + hero_speed 
end

function HeroGroup:addSkill(skill)
	local skills = self:getSkills()
	table.insert(skills,skill)
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
	self:__init__()
end

 
return HeroGroup
