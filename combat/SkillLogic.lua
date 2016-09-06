--
-- Date: 2016-08-22 15:18:08
--
local _ = (...):match("(.-)[^%.]+$") 
 
local effect = require(_.."Effect")
local skillActions = require(_.."SkillActions")
module(...,package.seeall)

local effect_module = {
						action = {
							name="damage",
							params = 
							{
								power = 100,
								element = 0, 
							}
						
						} ,
						targetConditons = {
							{
								name="attributeThreshold",
								params = {
								{key="hp",value=30,comp="=="},
								{key="hp",value=30}}
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


	for i,v in ipairs(eff_funcs) do 
		local eff = effect.new(v) 
		eff:setSkill(skill) 

		caster:addTempEffect(eff)
	end 
end



function doEffect(effect)
	print("______Start Do Effect")
 	local skill = effect:getSkill()
 	local caster = skill:getCaster()


 	local targets = skill:getTargets() 
 	local targetFilter = effect:getTargetFilter()

 	targets = targetFilter and targetFilters.do__(targetFilter,caster) or targets
 
 	local action = effect:getAction()
 	for i,v in ipairs(targets) do
 		local target = v 
 		local name = action.name
 		-- local params = 

 		skillActions[name](effect,target)

 			print(
 				"actionName",name,
			"skill：",skill:getCfgByKey("Name")
			,"释放者：",caster:getCfgByKey("Name")
			,"目标：",target:getCfgByKey("Name")
			) 

 	end  

end




function generateBasicSkillStruct(skill)
	local caster = skill:getCaster()

	local targetFilter = targetFilters.generateFilter(skill)


end