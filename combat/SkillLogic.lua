--
-- Date: 2016-08-22 15:18:08
--
local _ = (...):match("(.-)[^%.]+$") 
 
local Effect = require(_.."Effect")
local EffectActions = require(_.."EffectActions")
local Conditions = require(_.."Conditions")
module(...,package.seeall)

local effect_module =  
						{
						action = {
							name="damage",
							params = 
							{
								power = 100,
								element = 0, 
							} 
						} ,

						-- situations = {
						-- 	{
						-- 	name = "target",
						-- 	conditions = {
						-- 			{
						-- 				name="attribute",
						-- 				params = {key="hpPercent",value=30,comp="=="}
										 
						-- 			},
						-- 			{
						-- 				name="haveBuff",
						-- 				params = {id=1,actionName=""}
										 
						-- 			}  
						-- 		}
						-- 	},
						-- 	{
						-- 	name = "host",
						-- 	conditions = {
						-- 			{
						-- 				name="attribute",
						-- 				params = {key="hpPercent",value=30,comp="=="}
										 
						-- 			},
						-- 			{
						-- 				name="haveBuff",
						-- 				params = {id=1,actionName=""}
										 
						-- 			}  
						-- 		}
						-- 	},
						-- 	{
						-- 	name = "weather",
						-- 	conditions = {
						-- 			{
						-- 				name="attribute",
						-- 				params = {key="isNight",value=true,comp="=="}
										 
						-- 			} 
						-- 		}
						-- 	},

						-- }
						targetConditions = {
							{
								name="attribute",
								params = {key="hpPercent",value=30,comp="=="}
								 
							},
							{
								name="haveBuff",
								params = {id=1,actionName=""}
								 
							}  
						},
						-- targetFilter = {
						-- 	Target= 2,
						-- 	TargetFilter= 0,
						-- 	OrderRule= 0,
						-- 	Descend= 0,
						-- 	SelectCount= 1,
						-- },
						triggerEvent = {
							name= "onHit",
							targetFilter= {
								Target= 2,
								TargetFilter= 0,
								OrderRule= 0,
								Descend= 0,
								SelectCount= 1,
							},
						},
						round = 1,
						} 
-- 讲技能的eff 解压到 hero身上  xxx  不负责执行
function castSkill(skill)

	local eff_funcs = --skill:getCfgByKey("Functions") or 
	{
		effect_module 
	}


	local caster = skill:getCaster()
 

	print("_____castSkill_____________",caster:getCfgByKey("name"),caster:getAttr("id"))

	for i,v in ipairs(eff_funcs) do  
		local eff = Effect.new(v) 
		eff:setSkill(skill)  
		eff:setHost(caster)

		caster:addEffect(eff)
	end 
end



function doEffect(effect)
	print("\n\n______Start Do Effect_______")
 	local skill = effect:getSkill()
 	local caster = skill:getCaster()

 	local targetConditions = effect:getTargetConditions()

 	local targets = skill:getTargets() 
 	local targetFilter = effect:getTargetFilter()

 	local hasTargetFilter = type(targetFilter)=="table" 
 	-- print("targetFilter",targetFilter and 1 or 0)
 	targets = hasTargetFilter and TargetFilters.getTargets(effect) or targets
 	print( 
			"\nskill：",skill:getCfgByKey("Name")
			,"\n释放者：",caster:getCfgByKey("Name")
			,"\ntargets数量",#targets
			,"\nhasTargetFilter",hasTargetFilter
			,"\neffectListSize",#caster:getEffectList()
			,"\ntempEffectListSize",#caster:getTempEffectList()
			) 

 	local action = effect:getAction()
 	for i,v in ipairs(targets) do
 		local target = v 
 		local name = action.name
 		-- local params = 
 		local meets = Conditions.meets(target,targetConditions)
 
 		print(
 			"\nactionName:",name
 			,"\n是否满足targetConditions",meets
 			,"\n目标：",target:getCfgByKey("Name") 
			) 
 		if meets then 
 			EffectActions[name](effect,target)
 		end 

 	end  

end

function castPassiveSkills()
	CombatData.foreachAllHeros(
	function(hero)
		local skills = hero:getPassiveSkills()
		for _,skill in ipairs(skills) do 
		 	castSkill(skill)
	 	end 
	end) 
end




function generateBasicSkillStruct(skill)
	local caster = skill:getCaster()

	local targetFilter = TargetFilters.generateFilter(skill)


end