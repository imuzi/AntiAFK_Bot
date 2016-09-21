--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 16:50:47
--
local _ = (...):match("(.-)[^%.]+$") 


local Hero = require(_.."Hero")
local HeroGroup = require(_.."HeroGroup") 
local Skill = require(_.."Skill")
module(...,package.seeall) 

-- 战斗模式 pvp or pve or something else
mode = nil

groupNames=
{
	ATTACKER,
	DEFENDER
}
-- 场上所有阵营数据
groupMap = 
{
	[ATTACKER] = 0,
	[DEFENDER] = 0,
}

basicAttackOrderSet = 
{}




-- 保存手动释放的技能数据
manualCastData  =
{}


random_sequence = {}
random_index = 0



-- data 为 服务器返回数据 message levelbegin or arena。。。
function init(data)
	local data = data or decodeLocalMsg()
 	random_index = 0



	__init_groups(data) 


	
 
end 

function getGroupByName(name)
	return groupMap[name]
end

------ 武将数据集
function __init_groups(data)
  	local BattleGroupData = data.groups
  	local HeroGroupData = data.myGroup
 
  	local transDataForGroupInit = 
  	{
		[ATTACKER] = {HeroGroupData},
		[DEFENDER]  = BattleGroupData

		-- [DEFENDER] = {HeroGroupData},
		-- [ATTACKER]  = BattleGroupData
  	} 
	for k,v in pairs(groupMap) do 
		local initData = transDataForGroupInit[k]
		v = HeroGroup.new(k)
		v:setName(k)

		__init_heros(v,initData)

		__init_skills(v)


		groupMap[k] = v
	end
end

function __init_heros(group,initData)
	print("_______init_heros")

	for i_,v_ in ipairs(initData) do  
		local heros = v_.heros
		local group = group

		for i,v in ipairs(heros) do
			local hero = Hero.new(v)
			group:add(hero)  
			group:addSpeed(hero)  

			__init_basic_skill(hero)

			__add_to_basicAttackOrderSet(hero)
		end 

		print(group:getName(),"速度是：",group:getSpeed())
	end 
end

function __init_basic_skill(hero)
	local caster = hero 
	local skill = Skill.new(nil,BASIC_SKILL_TYPE,caster)
	hero:setBasicSkill(skill) 
end
 
function __add_to_basicAttackOrderSet(hero)
	table.insert(basicAttackOrderSet, hero)
end


 

-- skills 
function __init_skills(group)
	-- for k,skills in pairs(skillMap) do
		local heroGroup = group
		assert(heroGroup~=nil,"heroGroup未初始化，skill 要在heroGroup初始化后初始")
		local heros = heroGroup:getHeros()
		
		for i,v in ipairs(heros) do
			local caster = v 
			local ids = __getSkillIdsFromHero(caster) 

			for k_,id in pairs(ids) do
				local id = id[1]
				if id ~= nil then 
					local skill = Skill.new(id,k_,caster)  


					if k_=="SkillC" or k_=="SkillD" then 
						caster:addPassiveSkill(skill)
					else 
						skill:setCdLeft(INIT_CD) 
						group:addSkill(skill)
					end 
 
				end
			end
		end

		-- skillMap[k] = skills

	-- end
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


function foreachAllHeros(func)
	local groupMap = groupMap
	for k,group in pairs(groupMap) do

		local heros = group:getHeros()
		for i,hero in ipairs(heros) do 
			func(hero)
		end
	end
end

function foreachAllSkills(func)
	local groupMap = groupMap
	for k,group in pairs(groupMap) do

		local skills = group:getSkills() 
		for i,skill in ipairs(skills) do 
			func(skill)
		end
	end
end

function random__( ... )
	random_index = random_index + 1
	local result_record = random_sequence[random_index]
	local result = result_record or math.random(...)

	random_sequence[random_index] = result_record or result

	-- print("random__",result_record,result)
	-- dump(random_sequence)
	return result
end

function set_random_sequence(val)
	random_sequence = val 
end

