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

readySkills = {}



function getSkillToCast()
	-- body
end




function startCoolDown( ... )
	-- body
end

