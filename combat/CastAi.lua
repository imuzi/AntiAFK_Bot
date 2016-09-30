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

-- 能预约多少个技能 
local RESERVATION_SKILL_COUNT_MAX = 6
-- 保存预约技能
reservationSkills = {}

-- 是否手动
_isManualCast = true 


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

	local skillToCast = nil  
	
	local nextTurnGroup = TurnOrders.skill.whosTurn() 

 	skillToCast = checkReservationSkill(nextTurnGroup)

 	-- 有预约就 直接返回
 	if skillToCast then return skillToCast end 


 	-- 手动时 机会机制依然走 但是总是敌方放技能
	nextTurnGroup = isManualCast() and CombatData.getGroupByName(DEFENDER) or nextTurnGroup

	local skills = nextTurnGroup:getSkills()

	local readySkills = getReadySkills(skills) 

	if #readySkills >0 then  
		skillToCast = readySkills[random__(1,#readySkills)] 

		print("\nskillToCast",skillToCast:getCfgByKey("Name"),"readySkills",#readySkills)
	end

	print("___did CastAi")
	
	return skillToCast
end

-- 预约技能的检测逻辑 --[[预约需要满足 机会轮到自己了+冷却完成了+ 先约先出]]
function checkReservationSkill(nextTurnGroup)
	local isAttackerTurn = nextTurnGroup:getName() == ATTACKER
	if not isAttackerTurn or #reservationSkills==0 then return end 

	local firstOne = reservationSkills[1]

	if firstOne:getCdLeft() > 0 then return end  

	removeReservationSkillByIndex(1) --约完就散
	return firstOne
end

function getReadySkills(skills)
	local readySkills = {} 
	 
	for i,skill in ipairs(skills) do 
		 
		if skill:getCdLeft()<=0 then  
			table.insert(readySkills, skill)
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
			return true 
		end
	end) 
	 
	return bool_ 
end


function addReservationSkill(skill)
	if #reservationSkills >= RESERVATION_SKILL_COUNT_MAX then 
		return false 
	end	 
	table.insert(reservationSkills,skill)

	VisualEffect.dealShowReservationOrder(reservationSkills)
	return true 
end

function removeReservationSkillById(id)
	for i,v in ipairs(reservationSkills) do
		if id == v:getCfgByKey("ID") then 
			removeReservationSkillByIndex(i)
			break
		end
	end
end
function removeReservationSkill(skill)
	for i,v in ipairs(reservationSkills) do
		if skill:getCfgByKey("ID")  == v:getCfgByKey("ID") then 
			removeReservationSkillByIndex(i)
			break
		end
	end
end

function removeReservationSkillByIndex(index)
	table.remove(reservationSkills,index)


	VisualEffect.dealShowReservationOrder(reservationSkills)
end





function setIsManualCast(val)
	_isManualCast = val
end

function isManualCast()
	return _isManualCast
end