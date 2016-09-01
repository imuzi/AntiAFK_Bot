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

inturn = false 

turnOwner = nil


function loop()
	local shouldFindNextTurnOwner = shouldFindNextTurnOwner()
	if shouldFindNextTurnOwner then 
		turnOwner = turnOrders.basicAttack.whosTurn()
		trans_status(turnOwner,"BASICATTACK") 

	end  
	behaviors.loop(turnOwner)
	-- targetFilters.getTargets(turnOwner:getBasicSkill())
 
end

function do_ai(hero)
	-- behaviors
end

function trans_status(hero,status_key)
	local val = STATUS[status_key]
	hero:setStatus(val) 

	
	print("___trans_status_",hero:getCfgByKey("Name"),val)
	behaviors.do__(hero)
end


function turn_start(hero)
	-- body
end

function turn_end(hero)
	-- body
end

function shouldFindNextTurnOwner()
	if turnOwner then 
		local status = turnOwner:getStatus() 
		return status ~= STATUS.BASICATTACK and status ~= STATUS.CASTSKILL

	else
		return true 
	end 
end


function __isBingo(ratio) 
	local ratio = math.max(0,ratio)
	ratio = ratio*100/(ratio+100)
	local probability = random__(1,100)
	return probability <= ratio  
end


function onHit(skill)

	local targets = skill:getTargets()
	print(" onHit(skill)",#targets)
	for i,v in ipairs(targets) do
		local target = v 
		print("calculateDamage")
		calculateDamage(skill,target)	
		putEffects(skill,target)
	end
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
 

local needRandomVars = {
"comboRate", -- 
"blockRate",
"counterRate",
"critRate",
"hitRate",
"effectHitRate",
}

function calculateDamage(skill,target)	
	local targets = skill:getTargets()
	local caster = skill:getCaster()

	print(
	"skill：",skill:getCfgByKey("Name")
	,"释放者：",caster:getCfgByKey("Name")
	,"目标：",target:getCfgByKey("Name")
	) 


	local hitRate = caster:getAttr("hit") - target:getAttr("miss") + 100

	
	local isHit = __isBingo(hitRate) 

	if not isHit then 
		print("______miss,hitRate",hitRate)
		return 0 
	end 

	local isCrit = __isBingo(caster:getAttr("critRate"))
	local isBlock = __isBingo(caster:getAttr("blockRate"))

	local isIgnoreDefence = false
 


	local attack = caster:getAttr("attack")
	local defence = caster:getAttr("defence") 
	local critDamage = caster:getAttr("critDamage")

	local tenacity = caster:getAttr("tenacity")
	tenacityRatio = 1-tenacity/(tenacity+100)
 
 	local damageIncrease = caster:getAttr("damageIncrease") - target:getAttr("damageDecrease")
 	local cureIncrease = caster:getAttr("cureIncrease") - target:getAttr("cureDecrease")
 	local AOEIncrease = caster:getAttr("AOEIncrease") - target:getAttr("AOEDecrease")
 	local skillDamageIncrease = caster:getAttr("skillDamageIncrease") - target:getAttr("skillDamageDecrease")


 	-- fix me  技能伤害放大 倍率 通过既能获得
 	local skillDamageScaleRatio = 1 


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

	
	print( 
		"伤害：",damage
		,"\nattack,critDamage,tenacityRatio"
		,attack,critDamage,tenacityRatio
		,"\ndamageIncrease,cureIncrease,AOEIncrease,skillDamageIncrease"
		,damageIncrease,cureIncrease,AOEIncrease,skillDamageIncrease
		,"\nskillDamageScaleRatio"
		,skillDamageScaleRatio
		,"\nisCrit,isHit,isBlock,isIgnoreDefence"
		,isCrit,isHit,isBlock,isIgnoreDefence)				
	return damage 
end

function changeHp(target,val)

end


function putEffects(skill,target)
	local targets = skill:getTargets()
	local caster = skill:getCaster()
	
	-- for i,v in ipairs(Effs) do
		-- fix me  多个效果 同一个人 每一个效果都要随机一次
		local effectHitRate = caster:getAttr("effectHit") - target:getAttr("effectResist") +100
		print("effectHitRate",effectHitRate)
	-- end

	

end

-- hit events end 






 
 






