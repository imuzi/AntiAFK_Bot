--
-- Date: 2016-08-22 15:18:08
--
local _ = (...):match("(.-)[^%.]+$") 
 
local effect = require(_.."Effect")
local effectActions = require(_.."EffectActions")
local conditions = require(_.."Conditions")
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
		if not v.targetConditions then os.exit() end 
		local eff = effect.new(v) 
		eff:setSkill(skill) 

		caster:addEffect(eff)
	end 
end



function doEffect(effect)
	print("______Start Do Effect")
 	local skill = effect:getSkill()
 	local caster = skill:getCaster()

 	local targetConditions = effect:getTargetConditions()

 	local targets = skill:getTargets() 
 	local targetFilter = effect:getTargetFilter()

 	print("targetFilter",targetFilter and 1 or 0)
 	targets = type(targetFilter)=="table"  and targetFilters.do__(targetFilter,caster) or targets
 	print( 
			"skill：",skill:getCfgByKey("Name")
			,"释放者：",caster:getCfgByKey("Name")
			,"targets数量",#targets
			,"effectListSize",#caster:getEffectList()
			,"tempEffectListSize",#caster:getTempEffectList()
			) 

 	local action = effect:getAction()
 	for i,v in ipairs(targets) do
 		local target = v 
 		local name = action.name
 		-- local params = 
 		local meets = conditions.meets(target,targetConditions)
 		effectActions[name](effect,target)

 			print(
 			"actionName:",name
 			,"目标：",target:getCfgByKey("Name") 
			) 

 	end  

end

function castPassiveSkills()
	local groupMap = combatData.groupMap
	for k,group in pairs(groupMap) do

		local heros = group:getHeros()
		for i,hero in ipairs(heros) do
			local skills = hero:getPassiveSkills()
			for _,skill in ipairs(skills) do

			 	castSkill(skill)
		 	end 
		end
	end

end




function generateBasicSkillStruct(skill)
	local caster = skill:getCaster()

	local targetFilter = targetFilters.generateFilter(skill)


end