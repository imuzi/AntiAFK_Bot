--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 17:21:26
--

module(...,package.seeall) 

--[[- 技能的释放
1 ，2方的先攻值 --》 高的优先放
2 ，技能的AI逻辑--》 为单方的技能集合计算出的结果	

-AI 逻辑
1 通过先攻 找到释放技能的一方 
2 通过1方的技能合集 找到释放的技能类别
3 同类技能通过 技能表的priority优先级释放


-普通攻击的释放 
1，武将的速度

]]


readySkills = 
{
	[ATTACKER] = {},
	[DEFENDER] = {}
}


function loop()
	updateSkillCd()
end

function updateSkillCd() 
	local groupMap = combatData.groupMap
	for k,v in pairs(groupMap) do
		local group = v 
		local skills = group:getSkills() 
		print("\n____刷新技能CD__阵营",k)
		for i,skill in ipairs(skills) do
			checkSkillCd(skill)
		end
	end 
end


function checkSkillCd(skill)
	if isSkillJustReady(skill) then 
		onSkillReady(skill) 
	end
	skill:updateCdLeft()


	targetFilters.getTargets(skill)
	getSkillToCast()
end

function isSkillJustReady(skill)
	return skill:getCdLeft() == 0
end
function isSkillReady(skill)
	return skill:getCdLeft() <= 0
end

function onSkillReady(skill)
	storeReadySkill(skill)


end	

function storeReadySkill(skill)
	local groupName = skill:getCaster():getGroup():getName()
	local set_ = readySkills[groupName]

	table.insert(set_, skill) 
	print("添加技能到readySkills,技能名：",skill:getCfgByKey("Name")
		,"groupName",groupName) 
end


-- note:  这里不是找到技能后去决定武将何事放技能，而是 当武将的回合结束或要开始某个回合时去执行
function getSkillToCast()
	
	local nextTurnGroup = turnOrders.skill:whosTurn() 
	local nextGroupName =  nextTurnGroup:getName()

	local skills = readySkills[nextGroupName]
	local skillToCast = nil 



	print("\n__getSkillToCast________nextGroupName_",nextGroupName,"readySkills",#skills)
	return skillToCast
end

 

 