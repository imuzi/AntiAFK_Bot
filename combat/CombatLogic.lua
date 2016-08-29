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


function loop()
	local heros = combatData.basicAttackOrderSet

end

function do_ai(hero)
	
end

function trans_status(hero)
	-- body
end


function turn_start(hero)
	-- body
end

function turn_end(hero)
	-- body
end


-- 染红的写法 确保动态插入后 仍能正确找到正确的attacker
function get_next_basic_attacker(basicAttackOrderSet)
	local basicAttackOrderSet = basicAttackOrderSet 
	local attacker = nil

	for i,v in ipairs(basicAttackOrderSet) do
		local hero = v 
		local didBasicAtk = hero:didBasicAtk()

		if didBasicAtk == false then 
			attacker = hero 
			hero:didBasicAtk(true)
			break
		end 
	end

	return attacker
end
 






