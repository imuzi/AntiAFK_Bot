--
-- Date: 2016-08-11 11:41:15
--


--[[
--TODO::
1,
技能时长/效果触发事件点/ 大动画文件的时长获取 --生成配置文件
solution；解析spinejsone 找出指定动画event的触发time  / spine库加入获取指定动画时长接口 导给lua
 解析cocosstudio 找出指定动画event的触发time /cocosstudio 库加入获取指定动画时长接口 导给lua

2 
应对现有的 技能配置数据结构  --解析 并转换 
solution：重写 。目的是达到 数据结构清晰 /明白/方便查错 
"[{
 ""ClassName"": ""ActionEffect"",
 ""Action"": 1,
 ""TriggerTarget"": 2, 
 ""Effects"": [{
   ""ClassName"":""StopSkill"",
   ""Type"":104,
   ""Round"":2,
   ""Rate"":65 }],
 ""EffectTarget"": 1,
 ""ClientEffectTarget"":1,
 ""RemoveOnUserDead"":1
}]"

3，
重写核心战斗逻辑  。。支持 回放/跳过战斗
solution：逻辑 分离

4
issue：场景/镜头/UI/周边功能
solution；只做基本功能。后期慢慢移植




]]
 
module(...,package.seeall) 

turnOwner = nil

counterOwner = nil  -- 一次只有一个人能反击。。  记录下个反击者




function loop()
	local shouldFindNextTurnOwner = shouldFindNextTurnOwner()

	if shouldFindNextTurnOwner then  
		if turnOwner then 
			turn_over()
		end

		counterOwner = nil  

		local skillToCast = CastAi.think()

		--- 技能 游离回合之外  WARN
		if skillToCast then 
			turnOwner = skillToCast:getCaster() 
			turnOwner:setSkillToCast(skillToCast)
			trans_status(turnOwner,"CASTSKILL") 
		else 
			turn_begin()

			turnOwner = TurnOrders.basicAttack.whosTurn() 

			local basicSkill = turnOwner:getBasicSkill()
			turnOwner:setSkillToCast(basicSkill)
			trans_status(turnOwner,"BASICATTACK") 
		end  
	end  


	if isAlive(turnOwner) then 
		Behaviors.loop(turnOwner) 
	end 
 
	if counterOwner and counterOwner:getStatus()==STATUS.COUNTERATTACK then 
		Behaviors.loop(counterOwner) 
	end 

end

 
function trans_status(hero,status_key) 
	if canDoNothing(hero) then return end 

	local val = STATUS[status_key]
	hero:setStatus(val)  
	hero:resetFrameStep() 
	hero:resetFrameEventRecorder()
	print("改变 ",hero:getCfgByKey("Name"),"状态为 ：",val)
	Behaviors.begin(hero)

	VisualEffect.updateAction(hero)
end


function turn_begin()
	TriggerEvents.listen("turnBegin")
end

function turn_over()
	TriggerEvents.listen("turnOver") 
end

function isOverAction(hero)
	if not hero then return true end 

	local status = hero:getStatus() 
	return status == STATUS.STANDBY or status == STATUS.DEAD
end

function shouldFindNextTurnOwner()
	if turnOwner then  
		 return isOverAction(turnOwner) and isOverAction(counterOwner) 
		-- status ~= STATUS.BASICATTACK and status ~= STATUS.CASTSKILL

	else
		return true 
	end 
end


function checkCounterOwner()
	if counterOwner and isAlive(counterOwner) then 
		local basicSkill = counterOwner:getBasicSkill()
		counterOwner:setSkillToCast(basicSkill)
		trans_status(counterOwner,"COUNTERATTACK")
		-- counterOwner = nil   -- 要在下回合开始时  重置
	end 
end
--[[
	一回合 只触发至多 一次反击 一次连击
	当同时存在是 
	先连击 
]]
function checkCombo()
	local hero = turnOwner
	local isCombo = isBingo(hero:getAttr("comboRate"))

	if isCombo then  
		local basicSkill = hero:getBasicSkill()
		hero:setSkillToCast(basicSkill)
		trans_status(hero,"COMBOATTACK")


		return true
	end  

	return false
end

function checkCounter(target,isDamge)
	if not isDamge or not isAlive(target) then return end 

	local isCounter = isBingo(target:getAttr("counterRate"))
	if isCounter and not counterOwner then 
		counterOwner = target
	end  
end


function onHit(skill)

	-- local targets = skill:getTargets()
	-- print(" onHit(skill)",#targets)
	-- for i,v in ipairs(targets) do
	-- 	local target = v 
	-- 	print("calculateDamage")
	-- 	calculateDamage(skill,target)	
	-- 	putEffects(skill,target)
	-- end

	local evtName = skill:isBasicAttack() and "basicHit" or "skillHit" 
	TriggerEvents.listen(evtName)
	TriggerEvents.listen("onHit") 

end

--- hit events 

-- include healer
--[[

（攻击–  (无视防御 and 0 or 防御））
×格挡修正    isBLock and 0.5 or 0
×暴击修正    1+cd
×（1 + 最终伤害修正） 		optional int32 damageIncrease=22;//伤害加深      
							optional int32 damageDecrease=23;//伤害减少
							optional int32 cureIncrease=24;//治疗加深
							optional int32 cureDecrease=25;//治疗减少
							optional int32 AOEIncrease=26;//AOE伤害加深
							optional int32 AOEDecrease=27;//AOE伤害减少
							optional int32 skillDamageIncrease=28;//绝技伤害加深
							optional int32 skillDamageDecrease=29;//绝技伤害减少 
--×绝技倍率    -- skill __ function 中获取
	
 ,  

]]
 

-- local needRandomVars = {
-- "comboRate", -- 
-- "blockRate",
-- "counterRate",
-- "critRate",
-- "hitRate",
-- "effectHitRate",
-- }
function isBingo(ratio) 
	local ratio = math.max(0,ratio)
	ratio = ratio*100/(ratio+100)
	local probability = random__(1,100)
	return probability <= ratio  
end

function calculateDamage(effect,target)	
	local skill = effect:getSkill()

	-- local host = effect:getHost()
	local caster = skill:getCaster()

	print(
	"skill：",skill:getCfgByKey("Name")
	,"释放者：",caster:getCfgByKey("Name")
	,"目标：",target:getCfgByKey("Name")
	) 
	-- print(host,type(host))
	-- caster = host or caster

	local hitRate = caster:getAttr("hit") - target:getAttr("miss") + 100

	
	local isHit = isBingo(hitRate) 

	if not isHit then 
		print("————未命中,hitRate",hitRate,hitRate*100/(hitRate+100))
		VisualEffect.showMiss(target)
		return 0 
	end 
 

	local isCrit = caster:getAttr("mustCrit") or isBingo(caster:getAttr("critRate")) 
	if isCrit then TriggerEvents.listen("critHit") end  -- WARN 要先于计算伤害 


	local isBlock = isBingo(target:getAttr("blockRate"))

	local isIgnoreDefence = caster:getAttr("mustIgnoreDefence")
 


	local attack = caster:getAttr("attack")
	local defence = target:getAttr("defence") 
	local critDamage = caster:getAttr("critDamage")

	local tenacity = target:getAttr("tenacity")
	tenacityRatio = 1-tenacity/(tenacity+100)
 
 	local damageIncrease = caster:getAttr("damageIncrease") - target:getAttr("damageDecrease")
 	local cureIncrease = caster:getAttr("cureIncrease") - target:getAttr("cureDecrease")
 	local AOEIncrease = caster:getAttr("AOEIncrease") - target:getAttr("AOEDecrease")
 	local skillDamageIncrease = caster:getAttr("skillDamageIncrease") - target:getAttr("skillDamageDecrease")
 
 	local skillDamageScaleRatio = effect:getAction().params.power 


 	local checkVal = function(val)
 		return math.max(0,val)
 	end

 	local damage = 	(
	 					attack -
	 					(isIgnoreDefence and 0 or defence)
					)
 					*
 					(
 						isBlock and 0.5 or 1
					)
 					*
 					(
 						isCrit and (1+(critDamage-100)/100*tenacityRatio) or 1
					)
 					*
 					(
						1+ 
						checkVal(damageIncrease)*
						checkVal(cureIncrease)*
						checkVal(AOEIncrease)*
						checkVal(skillDamageIncrease)
					)
					*
					skillDamageScaleRatio

	

	damage = math.floor(damage)
	print( 
		"\n伤害：",damage
		,"\nattack,critDamage,tenacityRatio"
		,attack,critDamage,tenacityRatio
		,"\ndamageIncrease,cureIncrease,AOEIncrease,skillDamageIncrease"
		,damageIncrease,cureIncrease,AOEIncrease,skillDamageIncrease
		,"\nskillDamageScaleRatio"
		,skillDamageScaleRatio
		,"\nisCrit,isHit,isBlock,isIgnoreDefence"
		,isCrit,isHit,isBlock,isIgnoreDefence)		


	VisualEffect.showDamage(damage,isCrit,isBlock,target)			
	return damage 
end

 


function changeHp(target,val) 
	local hp = target:getAttr("hp")
	local maxHp = target:getAttr("maxHP")
	hp = hp - val  

	hp = math.max(hp,0)
	hp = math.min(hp,maxHp)
	target:setAttr("hp",hp)
	target:setAttr("hpPercent",hp*100/maxHp)   
end 

function checkDeath(target)
	local hp = target:getAttr("hp")
	if hp <= 0 then 

		onDeath(target) 
	end 
end

function onDeath(target)
	-- target:setStatus(STATUS.DEAD) 
	-- target:setAttr("ignoreSelect",true) -- WARN 只选死亡 可以被选择
end


function isAlive(hero)
	return hero:getStatus() ~= STATUS.DEAD
end
 
function canDoNothing(hero)
	return hero:getAttr("stun") or hero:getAttr("iceBlock")
end


--  应该在 effectAction 中
-- function putEffects(skill,target)
-- 	local targets = skill:getTargets()
-- 	local caster = skill:getCaster()
	
-- 	-- for i,v in ipairs(Effs) do
-- 		-- fix me  多个效果 同一个人 每一个效果都要随机一次
-- 	local effectHitRate = caster:getAttr("effectHit") - target:getAttr("effectResist") +100
-- 		print("effectHitRate",effectHitRate)
-- 	-- end 

-- end

-- hit events end 






 
 






