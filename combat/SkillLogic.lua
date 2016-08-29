--
-- Date: 2016-08-22 15:18:08
--
local _ = (...):match("(.-)[^%.]+$") 
 

module(...,package.seeall)


function castSkill(hero,skill,groupSet)
	-- body
end


function loop()
	updateSkillCd()
end

function updateSkillCd()
	local skillMap = combatData.skillMap

	for k,v in pairs(skillMap) do
		local skills = v 
		for i,skill in ipairs(skills) do
			skill:updateCdLeft()
		end
	end 
end


TargetFilter = 
function()
	-- body
end

 