--
-- Author: (£þ.£þ)
-- Date: 2016-08-24 15:23:23
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







AICategory = {
	DPS = 
	{

	},
	BUFF = 
	{

	},
	CONTROL = 
	{

	},
	HEAL = 
	{

	},
	REVIVE = 
	{

	},
}


-- note:  这里不是找到技能后去决定武将何事放技能，而是 当武将的回合结束或要开始某个回合时去执行
function think()
	if isAllSkillOnCd() then return end 
	
	local nextTurnGroup = TurnOrders.skill.whosTurn() 
 
	local skills = nextTurnGroup:getSkills()

	local readySkills = getReadySkills(skills)


	local skillToCast = nil 

	if #readySkills >0 then  
		skillToCast = readySkills[random__(1,#readySkills)] 

		print("\nskillToCast",skillToCast:getCfgByKey("Name"),"readySkills",#readySkills)
	end

	print("___did CastAi")
	
	return skillToCast
end

function getReadySkills(skills)
	local readySkills = {}

	for i,skill in ipairs(skills) do

		if skill:getCdLeft()<=0 then  
			table.insert(readySkills, v)
		end
	end

	return readySkills 
end


-- 或者通过 INIT_CD <=frame_step 对比  FIXME  
function isAllSkillOnCd() 
	local bool_ = true

	CombatData.foreachAllSkills(
	function(skill)
		if skill:getCdLeft()<=0 then  
			bool_ = false 
		end
	end) 
	 
	return bool_ 
end