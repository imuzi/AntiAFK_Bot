--
-- Date: 2016-08-22 15:21:03
--
local _ = (...):match("(.-)[^%.]+$") 

local getCfg = getConfig
local __skill_anim_events = require(_.."__skill_anim_events")

local Skill = class__("Skill",
					{	
					anim_events = "nil",
					cfg = "nil",
					cdLeft = "0",
					keytype = "nil",
					caster = "nil",
					targets = "{}",
					cd = "0",

					group = "nil"
					})

function Skill:ctor(id,keytype,caster)
	
	self:setKeyType(keytype)
	self:setCaster(caster)

	if self:isBasicAttack() then 
		self:initBasicAttack()
	else 
		self:initCfg(id)
	end 
	

	local avatarType = caster:getCfgByKey("AvatarType")
	local anim_events = __skill_anim_events[tostring(avatarType)]
	-- print("avatarType",avatarType)
	self:set_anim_events(anim_events)
end


function Skill:initBasicAttack()
	local cfg = self:getCaster():getCfg()
	-- self:setCfg(cfg)
	self.cfg = cfg
end


function Skill:isBasicAttack()
	return self:getKeyType() == BASIC_SKILL_TYPE
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

function Skill:setTargets(val)
	self.targets = val
end
function Skill:getTargets()
	return self.targets
end


---
function Skill:updateCdLeft(gap)
	local gap = gap or 1
	self.cdLeft = self.cdLeft - gap 
	if self.cdLeft <0 then 
		self.cdLeft = -1
	else
		-- print("_______技能：",self:getCfgByKey("Name"),"剩余冷却：",self.cdLeft)
	end
end

function Skill:getCdLeft()
	return self.cdLeft
end

function Skill:setCdLeft(val)
	self.cdLeft = val
	print("setCdLeft",self.cdLeft)
end

function Skill:getCd()
	return self.cd
end

function Skill:setCd(val)
	self.cd = val
	 
end



--- anim _events funcs
function Skill:getInterval(key)
	local events = self:getAnimEvent(key) 
	return events.interval
end

-- function Skill:getPoint(key,evt)
-- 	local events = self:getAnimEvent(key) 
-- 	return events[evt]
-- end

function Skill:getAnimEvent(key)
	local key = key or self:getKeyType()
	return self:get_anim_events()[key]
end

function Skill:set_anim_events(val)
	self.anim_events = val
end

function Skill:get_anim_events()
	return self.anim_events
end
--- anim _events funcs end


-- 区分表头做特殊用
function Skill:setKeyType(var)
	self.keytype = var
end
function Skill:getKeyType()
	return self.keytype
end

return Skill
