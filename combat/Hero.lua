--
-- Author: (£þ.£þ)
-- Date: 2016-08-22 15:34:06
--
local getCfg = getConfig

local Hero = class("Hero",
					{
					cfg         = nil,
					baseAttrs   = {},
					externAttrs = {},
					status      = nil, 
					frameStep   = 0,
					skillToCast = nil,
					groupName   = nil, 

					_didBasicAtk = false,
					}) 

function Hero:ctor(heroData)
	local heroData = heroData 
	local svr_id = heroData.id 
	local type_ = heroData.type

	self:initCfg(type_)
	self:__initAttrs(heroData)

	print("svr_id,type_",svr_id,type_)
end

function Hero:initCfg(id)
	local cfg = getCfg(id, "HeroConfig")
	self.cfg = cfg
end

function Hero:getCfg()
	return self.cfg
end

function Hero:getCfgByKey(key)
	return self:getCfg()[key]
end
--- Attributes
function Hero:__initAttrs(attrData)
	local attrData = attrData  
	self.baseAttrs = {}

	for k,v in pairs(attrData) do
		self:setAttr(k,v)
	end  
end

function Hero:getAttr(name)
	local baseAttrs = self.baseAttrs
	return baseAttrs[name]
end

function Hero:setAttr(name,val)
	local baseAttrs = self.baseAttrs
	baseAttrs[name] = val
	print("name,val",name,val)
end

function Hero:setGroupName(val)
	self.groupName = val
end
function Hero:getGroupName()
	return self.groupName 
end
--- status 
function Hero:setStatus(val)
	self.status = val 
end

function Hero:getStatus()
	return self.status
end


function Hero:didBasicAtk(val)
	local didBasicAtk = self._didBasicAtk

	if val~=nil then 
		didBasicAtk = val  
	else
		return didBasicAtk
	end

	self._didBasicAtk = didBasicAtk
	return self
end 

--- frame step  
function Hero:updateFrameStep(gap)
	local gap = gap or 1 
	self.frameStep = self.frameStep + gap
end

function Hero:resetFrameStep()
	self.frameStep = 0
end

function Hero:getFrameStep()
	return self.frameStep 
end



function Hero:isSkillOver()
	local interval = self:getSkillToCast():getInterval()
	local frameStep = self:getgetFrameStep()
	local isOver = interval <= frameStep

	return isOver 
end

function Hero:setSkillToCast(skill)
	self.skillToCast = skill
end

function Hero:getSkillToCast()
	return self.skillToCast
end









return Hero
