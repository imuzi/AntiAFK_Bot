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
-- {
-- 	name="damage",
-- 	params = 
-- 	{
-- 	power = 100,
-- 	element = 0, 
-- 	}
-- }
					
damage = 
function(effect,target) 
	local damage = combatLogic.calculateDamage(effect,target)   
	combatLogic.changeHp(target,damage) 
end

-- damage1 = 
-- function (effect,target)
-- 	local damgeScaleRatio = params.power
-- 	return damgeScaleRatio
-- end


-- {
-- 	name="revive",
-- 	params = 
-- 	{
-- 	hpRatio = 100, 
-- 	}
-- }
-- 无死亡这个变量 如isdead 只有死亡这个状态
-- parma 可能是skill fucntion  or 解析后 power
revive = 
function(effect,target)
	local params = effect:getParams()
	local hpRatio = params.hpRatio/100
	local maxHp = target:getAttr("maxHP")
	local reivedHp = maxHp*hpRatio
	target:setAttr("hp",reivedHp)
	-- target:setStatus("")
	combatLogic.trans_status(target,"STANDBY")
end

-- {
-- 	name="purge",
-- 	params = 
-- 	{
-- 	count = 1, 
-- 	}
-- }
purge =
function(effect,target)
 	local params = effect:getParams()
	local tempEffectList = target:getTempEffectList()
	for i,v in ipairs(tempEffectList) do
		
	end
end

-- {
-- 	name="changeAttr",
-- 	params = 
-- 	{
-- 	count = 1, 
-- 	}
-- }
-- 叠加 是该变 当前存在的buff的回合数为最新的buff回合数 
-- 必暴击和 必怎么 怎么样的  护盾和 不死等也是 changeattr
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
-- {
-- 	name="newEffect",
-- 	params = 
-- 	{
-- 	effect = {}, 
--  stackType = 1,  FIX ME 
-- 	}
-- } 
local effectCls = require(_.."Effect")
newEffect = 
function(effect,target)
	local params = effect:getParams()
	local params_ = params.effect

	local stackType = params.stackType

	local caster = effect:getSkill():getCaster()
	local effectHitRate = caster:getAttr("effectHit") - target:getAttr("effectResist") +100

	local isHit = combatLogic.isBingo(effectHitRate)
	if isHit then 
		local newEffect = effectCls.new(params_)
		target:addTempEffect(newEffect)
	end

	-- 如果是  changeattr则赋予target 一个 changeattr 的action  


end