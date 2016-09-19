--
-- Author: (£þ.£þ)
-- Date: 2016-09-02 14:12:54
--
local _ = (...):match("(.-)[^%.]+$") 
module(...,package.seeall) 
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
	local params = effect:getParams()
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

 	local params = effect:getParams()
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

		onEffectRemove(list[index],isFriend)
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
	local params = effect:getParams()
	local mode = params.mode 
	local value = params.value 

	local valueMax = params.valueMax
	local attrName = parmas.attrName

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
	effect = {},  
 	
	}
} 
]]
local EffectCls = require(_.."Effect")
newEffect = 
function(effect,target)
	local params = effect:getParams()
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
	stackType = 1
	}
	]]
-- stackType = 1,  FIX ME 

-- 逻辑 和 表现用2个列表 buffShowList  FIXME
buff = function(effect,target,isDebuff) 
	local params = effect:getParams()
	local stackType = params.stackType

	local skill = effect:getSkill()
	local caster = skill:getCaster()

	local hitRate = caster:getAttr("hit") - target:getAttr("miss") + 100 
	local effectHitRate = caster:getAttr("effectHit") - target:getAttr("effectResist") +100
	local isHit = CombatLogic.isBingo(hitRate) 
	local isEffectHit = CombatLogic.isBingo(effectHitRate)
 
	local skill = effect:getSkill() 

	if isHit and isEffectHit then  
		 
		local eff_add = EffectCls.new()
		eff_add:setSkill(skill)
		eff_add:setAction({
							name="changeAttr",
							params = params
							}) 
		eff_add:setHost(target)


		local _params = clone(params)
		_params.value = _params.value*-1

		local eff_reduce = EffectCls.new()
		eff_reduce:setSkill(skill)
		eff_reduce:setAction({
							name="changeAttr",
							params = _params
							}) 
		eff_reduce:setHost(target) 
		

		local _buff = {eff_add,eff_reduce} 

		if not SkillLogic.check_buff_stack(_buff,isDebuff) then  
			if isDebuff then 
				eff_reduce:setTriggerEvent({name = "effectBegin"}) 
				eff_add:setTriggerEvent({name = "effectOver"}) 

				target:addDeBuff(_buff) 
			else 
				eff_add:setTriggerEvent({name = "effectBegin"}) 
				eff_reduce:setTriggerEvent({name = "effectOver"}) 

				target:addBuff(_buff) 
			end  

			TriggerEvents.checkDoEffect(newEffect,"effectBegin")  
		end

		return true 
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
	}
	]]
deBuff = function(effect,target) 
	buff(effect,target,true)
end



