--
-- Date: 2016-08-22 15:18:08
--
local _ = (...):match("(.-)[^%.]+$") 
 local __SKILL_TEST = require(_.."__SKILL_TEST")
local Effect = require(_.."Effect")
local EffectActions = require(_.."EffectActions")
local Conditions = require(_.."Conditions")
module(...,package.seeall)

function loop(frame_step)
	CombatData.foreachManualCastData(
		function(data)
			local cast_frame,skill_id = unpack(data)

			if frame_step == cast_frame then 

				CombatData.foreachAllSkills(
					function(skill)
						if skill:getCfgByKey("ID") == skill_id then 
							castSkill(skill) 
							return true 
						end 
					end)
				
			end 
		end)
end


-- 讲技能的eff 解压到 hero身上  xxx  不负责执行
function castSkill(skill)

	local eff_funcs = --skill:getCfgByKey("Functions") or 
	{
		-- effect_module 
		generateBasicSkillStruct()
	}


	local caster = skill:getCaster()
 

	print("_____castSkill_____________",caster:getCfgByKey("Name"),caster:getAttr("id"))

	for i,v in ipairs(eff_funcs) do  
		local eff = Effect.new(v) 
		eff:setSkill(skill)  
		eff:setHost(caster)
		eff:setTargets(skill:getTargets())


		-- WARN 写一回合就是 即时释放的 会在 行为结束后清空 写 2回合 就是持续2回合的效果了
		if eff:getRound() <= 1 then 
			caster:addCastingEffect(eff)
		else 
			caster:addTempEffect(eff)
		end 
		print("____add__eff",skill:getCfgByKey("Name"))
	end 
end



function doEffect(effect)
	print("\n\n______Start Do Effect_______")
 	local skill = effect:getSkill()
 	local caster = skill:getCaster()

 	local targetConditions = effect:getTargetConditions()

 	local targets = effect:getTargets() 
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
 	if hasTargetFilter then 
 		skill:setTargets(targets)  --如果效果重算目标 要不要更新原技能找到的目标呢 WARN FIX ME
 	end
 	-- effect:setTargets(targets)

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

 		VisualEffect.dealBeHitedEffect(caster,target)
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




function generateBasicSkillStruct() 
	return 
	{
		action = 
		{
		name="buff",
		params = 
		{
			mode = 0,
			value = 30,
			attrName = "critRate",
			stackType = 1,
			round = 1
		}
	},
		-- {
		-- 	name="damage",
		-- 	params = 
		-- 	{
		-- 		power = 100,
		-- 		element = 0, 
		-- 	} 
		-- },
		triggerEvent = {
			name= "hit",
			target = "host" 
		},
		round = 1,
	} 
end


function generateCommBuffEffects(params,isDeBuff)
	local _params = clone(params) 
	
	if _params.mode == 2 then -- bool 
		_params.value = not params.value  
	else 
		_params.value = _params.value*-1
	end 
 
	local eff_add = Effect.new() 
	eff_add:setAction({
						name="changeAttr",
						params = params
						})   

	local eff_reduce = Effect.new() 
	eff_reduce:setAction({
						name="changeAttr",
						params = _params
						})   
	
	if isDeBuff then 
		eff_reduce:setTriggerEvent({name = "effectBegin"}) 
		eff_add:setTriggerEvent({name = "effectOver"}) 
	else 
		eff_add:setTriggerEvent({name = "effectBegin"}) 
		eff_reduce:setTriggerEvent({name = "effectOver"})
	end 

	return {eff_add,eff_reduce} 
end


function onSkillCasted(skillCasting)
	local skills = skillCasting:getCaster():getGroup():getSkills()
	-- CombatData.foreachAllSkills(
	-- function(skill) 
	for i,skill in ipairs(skills) do 
		local skillCdToSet = skill:getCdLeft() < G_CD and G_CD or skill:getCdLeft()
		skill:setCdLeft(skillCdToSet) 
		skill:setCd(skillCdToSet)
	end  

	local skillCdToSet = skillCasting:getCfgByKey("CoolDown")*LOGIC_FPS 
	skillCdToSet = skillCdToSet < G_CD and G_CD or skillCdToSet 

	skillCasting:setCdLeft(skillCdToSet)
	skillCasting:setCd(skillCdToSet)


	doWithCheck__("onUseSkill__",VisualEffect.getSkillIcon(skillCasting)) 

	VisualEffect.dealSkillName(skillCasting)
end



--[[
 
           0还是若存在，则无视
           1表示若更强则取代并刷新Round，
           2表示取代但不刷新Round,
           3表示叠加并刷新Round,
           4表示叠加但不算新Round"	
]]
check_buff_stack = 
function(buff,isDebuff)
	local effect = buff[1]
	local host = effect:getHost()
	local params = effect:getAction().params
	local attrName = params.attrName
	local value = params.value
	local stackType = params.stackType


	local buffList  
	if isDebuff then 
		buffList = host:getDeBuffList()
	else 
		buffList = host:getBuffList()
	end 

	
	local isIgnore = false

	for i,v in ipairs(buffList) do
		local eff_add = v[1]
		local _params = eff_add:getAction().params
		local _attrName = _params.attrName
		local _value = _params.value

		if eff_add:sleep() == false then
			local hasSameType = attrName == _attrName

			local better = value > _value
			if _params.mode == 2 then -- bool  
				stackType = 3  -- WARN 状态类属性 默认都为 叠加 并刷新round 
			end 

			if hasSameType then 
				if stackType == 0 then 
					 isIgnore = true 
					 -- os.exit()
				elseif stackType == 1 then 
					if better then 
						for _i,eff in ipairs(v) do  
							TriggerEvents.checkDoEffect(eff,"effectOver") 
						end
						buffList[i] = buff 
					 	isIgnore = true  
					 else 
					 	for _,eff in ipairs(buff) do  
							eff:sleep(true)
						end
					 end 
				elseif stackType == 2 then 
					for _i,eff in ipairs(v) do  
						buff[_i]:setRound(eff:getRound())
						TriggerEvents.checkDoEffect(eff,"effectOver")  
					end
					buffList[i] = buff
					isIgnore = true  
				elseif stackType == 3 then 
					for _i,eff in ipairs(v) do  
						eff:setRound(buff[_i]:getRound()) 
					end 
				elseif stackType == 4 then  
					-- donothing
				end  
				break
			end 

		end  

	end

	return isIgnore
end
