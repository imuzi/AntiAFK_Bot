--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 16:50:47
--
local _ = (...):match("(.-)[^%.]+$") 


local hero = require(_.."Hero")
local heroGroup = require(_.."HeroGroup") 
local skill = require(_.."Skill")
module(...,package.seeall) 

-- 战斗模式 pvp or pve or something else
mode = nil
-- 场上所有阵营数据
groupMap = 
{
	myself = 0,
	enemy = 0,
}

basicAttackOrderSet = 
{}


-- 所有技能集合
skillMap = 
{
	myself = {},
	enemy = {}
}

-- 保存手动释放的技能数据
manualCastData  =
{}




-- data 为 服务器返回数据 message levelbegin or arena。。。
function init(data)
	local data = data or decodeLocalMsg()
 

	__init_groups(data)

	__init_skills()
 
end 


------ 武将数据集
function __init_groups(data)
  	local BattleGroupData = data.groups
  	local HeroGroupData = data.myGroup
 
  	local dataForGroupInit = 
  	{
		myself = {HeroGroupData},
		enemy  = BattleGroupData
  	} 
	for k,v in pairs(groupMap) do 
		local initData = dataForGroupInit[k]
		v = heroGroup.new(k)

		__init_heros(v,initData)

		groupMap[k] = v
	end
end

function __init_heros(group,initData)
	print("_______init_heros")

	for i_,v_ in ipairs(initData) do  
		local heros = v_.heros
		local group = group

		for i,v in ipairs(heros) do
			local hero = hero.new(v)
			group:add(hero)  
			group:addSpeed(hero)  

			__add_to_basicAttackOrderSet(hero)
		end 

		print(group:getName(),"速度是：",group:getSpeed())
	end 
end

function __add_to_basicAttackOrderSet(hero)
	table.insert(basicAttackOrderSet, hero)
end


 

-- skills 
function __init_skills()
	for k,skills in pairs(skillMap) do
		local heroGroup = groupMap[k] 
		assert(heroGroup~=nil,"heroGroup未初始化，skill 要在heroGroup初始化后初始")
		local heros = heroGroup:getHeros()
		
		for i,v in ipairs(heros) do
			local caster = v 
			local ids = __getSkillIdsFromHero(caster) 

			for k_,id in pairs(ids) do
				local skill = skill.new(id,k_,caster)
				skill:setCdLeft(INIT_CD)
				table.insert(skills, skill) 
			end
		end

		skillMap[k] = skills

	end
end
 

local SkillKeys = 
{
	"SkillA",
	"SkillB",
	"SkillC",
	"SkillD",
}
function __getSkillIdsFromHero(hero)
	local hero = hero 
	local ids = {}
	for i,v in ipairs(SkillKeys) do
		local key = v
		local id = hero:getCfgByKey(key)
		

		ids[key] = id
		-- table.insert(ids, id)
	end 
	return ids 
end







