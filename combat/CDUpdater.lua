--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 17:21:26
--

module(...,package.seeall) 




 

function loop()
	updateSkillCd()
end

function updateSkillCd() 
	CombatData.foreachAllSkills(
	function(skill)
		checkSkillCd(skill)

		doWithCheck__("updateCd__",VisualEffect.getSkillIcon(skill)) 
	end)  
end


function checkSkillCd(skill)
	if isSkillJustReady(skill) then 
		onSkillReady(skill) 
	end
	skill:updateCdLeft()

 
end

function isSkillJustReady(skill)
	return skill:getCdLeft() == 0
end
function isSkillReady(skill)
	return skill:getCdLeft() <= 0
end

function onSkillReady(skill)
	-- storeReadySkill(skill)


end	

-- function storeReadySkill(skill)
-- 	local groupName = skill:getCaster():getGroup():getName()
-- 	local set_ = readySkills[groupName]

-- 	table.insert(set_, skill) 
-- 	print("添加技能到readySkills,技能名：",skill:getCfgByKey("Name")
-- 		,"groupName",groupName) 
-- end




 

 