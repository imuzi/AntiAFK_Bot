--
-- Author: (£þ.£þ)
-- Date: 2016-09-02 14:12:54
--
local _ = (...):match("(.-)[^%.]+$") 
module(...,package.seeall) 

--[[ 
1. 重命名： onHit -> beenHit
2. buff (debuf) 的Value有默认值：0，意味不好也不坏的buff

3. 默认的，Purge不能净化value为 0 的 buff(debuf) 
21. Purge需要有一个默认参数，Count ＝ 99。但Purge只会净化Value不为0的buff
22. Purge需要一个TypeList，意味净化指定Type


4. 封装：RoundDamage
5. 封装：重伤。效果等于RoundDamage ＋ changeAttr（cureDecrease）
6. 封装：烧伤。效果等于RoundDamage ＋ changeAttr（atk）
7. 每个 action 都应该有个 Group。 比如中毒，烧伤，流血属于一个Group。他们也会互相覆盖。
8. changeAttr的 stackType应该抽象到 action层，与Group一起出现。


9. action应该支持数组，意味同时发生
10. action需要一个新字段： buff type，意味动画表现。比如重伤是一个action组，但buffType只有1个。  若没配bufftype的话，取attrName对应的buff type
11. 每个attrName都应对应一个buff type。对应关系数据结构在哪里？
12. AddBuffRound 没实现
13. ignore buff effect, 没实现
14. select target, 没实现
15. ignore action, 没实现
16. 
17. target condition 支持数组，并定义 AND , OR 操作。默认是 OR
19. triggerEvent 支持数组，并定义逻辑操作. 默认是 OR
20. 对必定暴击进行封装: mustCrit
21. effect的rate重新封装，效果效果等价于：
	"targetCondition":{
  		 "name":"luck",
   		"params":{
     			  "param:30
  		 }
	}

23. damage公式确认：当power为负时，会受到治疗加成
24. effect缺少定义：是否是被动技能触发的。若是被动触发，那么无法被任何技能remove，只能等回合用完为止。


]]

--[[
CurePower  
即 吸血效果
也不该写在 damage 里面 
因为他不是一种效果 

他是 2种效果的集合
damage 
和
heal 

控制的话  
控制heal 的 power 就好了 

而 heal 就是 damage 的power为负 
]] 
--  means damage.. element 
-- fix me  是否要在这里 做 免疫某种属性攻击做检测呢
--  damage无根据  某个属性放大的 参数  --这个参数应是一个  公式  TODO AND FIXME
--[[
{
	name="damage",
	params = 
	{
	power = 100,
	element = 0, 
	}
}]]
					
damage = 
function(effect,target) 
	local damage = CombatLogic.calculateDamage(effect,target)   
	CombatLogic.changeHp(target,damage) 
	CombatLogic.checkDeath(target)   --  WARN这里 死亡 状态 表现上应该是对面行为结束后才消失 目标依然可攻击
	
	local isDamage = damage > 0  

	CombatLogic.checkCounter(target,isDamage)
end

-- damage1 = 
-- function (effect,target)
-- 	local damgeScaleRatio = params.power
-- 	return damgeScaleRatio
-- end


--[[
{
	name="revive",
	params = 
	{
	hpRatio = 100, 
	}
}]]
-- 无死亡这个变量 如isdead 只有死亡这个状态
-- parma 可能是skill fucntion  or 解析后 power
revive = 
function(effect,target)
	local params = effect:getAction().params
	local hpRatio = params.hpRatio/100
	local maxHp = target:getAttr("maxHP")
	local reivedHp = maxHp*hpRatio
	target:setAttr("hp",reivedHp)
	target:setAttr("hpPercent",reivedHp*100/maxHp)   
	-- target:setStatus("")
	CombatLogic.trans_status(target,"STANDBY")
	target:setAttr("ignoreSelect",false)
end
--[[
{
	name="purge",
	params = 
	{
	count = 1, 
	}
}
]]
purge =
function(effect,target)
	local caster = effect:getSkill():getCaster()
	local isFriend = caster:getGroup():getName() == target:getGroup():getName()

	local list = isFriend and target:getDeBuffList() or target:getDeBuffList()

 	local params = effect:getAction().params
 	local count = params.count 

 	-- 随机选一个 FIXme
 	local indexsToRemove = {} 
	for i,v in ipairs(list) do
		if i > count then 
			break 
		end 

		for _i,eff in ipairs(v) do
			TriggerEvents.checkDoEffect(eff,"effectOver") 
		end 
		table.insert(indexsToRemove,i)
	end

	local size = #indexsToRemove

	for i=size,1,-1 do
		local index = indexsToRemove[i] 

		TriggerEvents.onEffectRemove(list[index],isFriend)
		table.remove(list,index)
 
	end
end

--[[
{
	name="changeAttr",
	params = 
	{
	mode = 0,
	value = 30,
	attrName = "critRate",
	}
}]]
-- 叠加 是该变 当前存在的buff的回合数为最新的buff回合数 
-- 必暴击和 必怎么 怎么样的  护盾和 不死 沉默 眩晕 冰冻 沉睡 等也是 changeattr
changeAttr = 
function(effect,target)
	local params = effect:getAction().params
	local mode = params.mode 
	local value = params.value 

	local valueMax = params.valueMax
	local attrName = params.attrName

	local attrValue = target:getAttr(attrName)

	if mode == 0 then --%
		attrValue = attrValue + attrValue*value/100 
	elseif mode == 1 then --int
		attrValue = attrValue + value
	elseif mode == 2 then --bool
		attrValue = value
	else 
		print("WARNING：不支持的属性改变模式mode 要为0和1 2 ",mode) 
	end 

	target:setAttr(attrName,attrValue)

	VisualEffect.dealAttributeChanged(target,effect)


end


-- changeConfigValue
-- changeInstanceVarValue --FIXME

-- 创建效果  这个行为会残生一个新的效果  赋予给target 保存在efflist
--  当round >1 时，则执行这段逻辑
--  round>1 即为这个效果是持续效果
--[[
{
	name="newEffect",
	params = 
	{
	effect = {}  
	}
} 
]]

-- 这个专用来赋予对方技能效果
local EffectCls = require(_.."Effect")
newEffect = 
function(effect,target)
	local params = effect:getAction().params
	local params_ = params.effect 

	local skill = effect:getSkill() 

	 
	local newEffect = EffectCls.new(params_)
	newEffect:setSkill(skill)
	target:addTempEffect(newEffect)
	newEffect:setHost(target)

	TriggerEvents.checkDoEffect(newEffect,"effectBegin")  
	-- 如果是  changeattr则赋予target 一个 changeattr 的action   
end

-- 针对多个同类BUFF 同时存在   取值高的 底的不生效 当 高的消失时  低的就生效的问题 

-- 这个buff 也要保存 但不保存在原有生效的 效果集合里 
-- hero  增加一个 sleepEffectList的集合 每次 buff结束时 去比较生效的效果集合里的值是否仍有比他高的 
-- 没有就加入到 tempEffect 里面 去作用  并触发 effectBegin事件 
--  或者将 effectlist 的 子集扩展成 数组   同类型的BUFF类技能 放在一个数组中  

--[[
 
           0还是若存在，则无视
           1表示若更强则取代并刷新Round，
           2表示取代但不刷新Round,
           3表示叠加并刷新Round,
           4表示叠加但不算新Round"	
]]

--[[
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
	]]
-- stackType = 1,  FIX ME 

-- 逻辑 和 表现用2个列表 buffShowList  FIXME
buff = function(effect,target,isDeBuff) 
	local params = effect:getAction().params
	local stackType = params.stackType

	local skill = effect:getSkill()
	local caster = skill:getCaster()

	local hitRate = caster:getAttr("hit") - target:getAttr("miss") + 100 
	local effectHitRate = caster:getAttr("effectHit") - target:getAttr("effectResist") +100
	local isHit = CombatLogic.isBingo(hitRate) 
	local isEffectHit = CombatLogic.isBingo(effectHitRate)
   
	if isHit and isEffectHit then   
		local skill = effect:getSkill() 
		local _buff = SkillLogic.generateCommBuffEffects(params,isDeBuff) 

		for i,v in ipairs(_buff) do
		  	v:setHost(target)
		  	v:setSkill(skill)
		  	v:setTargets({target}) 
	  	end  
	  	
		local effectBeginEff 

		if not SkillLogic.check_buff_stack(_buff,isDeBuff) then  
			if isDeBuff then  

				target:addDeBuff(_buff)  
				effectBeginEff = _buff[2]  
			else 
			  
				target:addBuff(_buff)  
				effectBeginEff = _buff[1]
			end   
 		
 			TriggerEvents.checkDoEffect(effectBeginEff,"effectBegin")  
 			print("___________effectBeginEff_____")
 		else

 			print("____ignoreed_______")
 			-- os.exit()
 			-- print("______________________________",os.exit())
		end

		return true 
	else
		VisualEffect.showMiss(target)
	end

	return false 
end


--[[
{
	name="deBuff",
	params = 
	{
	mode = 0,
	value = 30,
	attrName = "critRate",
	round = 1
	}
	]]
deBuff = function(effect,target) 
	buff(effect,target,true)
end








