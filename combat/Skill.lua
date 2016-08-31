--
-- Date: 2016-08-22 15:21:03
--
local _ = (...):match("(.-)[^%.]+$") 

local getCfg = getConfig
local __skill_anim_events = require(_.."__skill_anim_events")

local Skill = class("Skill",
					{	
					anim_events = nil,
					cfg = nil,
					cdLeft = 0,
					keytype = nil,
					caster = nil,

					group = nil
					})

function Skill:ctor(id,keytype,caster)
	self:initCfg(id)
	self:setKeyType(keytype)
	self:setCaster(caster)

	local avatarType = caster:getCfgByKey("AvatarType")
	local anim_events = __skill_anim_events[tostring(avatarType)]
	-- print("avatarType",avatarType)
	self:set_anim_events(anim_events)
end

function Skill:initCfg(id)
	local cfg = getCfg(id, "SkillConfig")
	if not cfg then print("ID为",id,"的技能找不到") end
	self.cfg = cfg
end

function Skill:getCfg() 
	return self.cfg
end

function Skill:getCfgByKey(key)
	return self:getCfg()[key]
end

function Skill:setCaster(val)
	self.caster = val
end
function Skill:getCaster()
	return self.caster
end


---
function Skill:updateCdLeft(gap)
	local gap = gap or 1
	self.cdLeft = self.cdLeft - gap 
	if self.cdLeft <0 then 
		self.cdLeft = -1
	else
		print("_______技能：",self:getCfgByKey("Name"),"剩余冷却：",self.cdLeft)
	end
end

function Skill:getCdLeft()
	return self.cdLeft
end

function Skill:setCdLeft(val)
	self.cdLeft = val
	print("setCdLeft",self.cdLeft)
end


function Skill:getInterval(key)
	local key = key or self:getKeyType()
	local anim_events = self:get_anim_events()
	local events = anim_events[k] or anim_events["attack"] 

	return events.interval
end



function Skill:set_anim_events(val)
	self.anim_events = val
end

function Skill:get_anim_events()
	return self.anim_events
end

-- 区分表头做特殊用
function Skill:setKeyType(var)
	self.keytype = var
end
function Skill:getKeyType()
	return self.keytype
end

return Skill
