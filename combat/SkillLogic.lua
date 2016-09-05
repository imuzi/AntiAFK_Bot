--
-- Date: 2016-08-22 15:18:08
--
local _ = (...):match("(.-)[^%.]+$") 
 
local effect = require(_.."Effect")
module(...,package.seeall)



-- 讲技能的eff 解压到 hero身上  xxx  不负责执行
function castSkill(hero,skill,groupSet)
	local eff_funcs = --skill:getCfgByKey("Functions") or 
	{
		action = {
					name="damage"
					power = 100,
					element = 0, 
					} ,
		targetConditons = {
							{
								name="attributeThreshold",
								params = {
											{key="hp",value=30,comp="=="},
											{key="hp",value=30}}
										} 
							},
		targetFilter = {
			Target= 2,
			TargetFilter= 0,
			OrderRule= 0,
			Descend= 0,
			SelectCount= 1,
		},
		triggerEvent = {name= "onHit",
						targetFilter= {
							Target= 2,
							TargetFilter= 0,
							OrderRule= 0,
							Descend= 0,
							SelectCount= 1,
						},

		round = 1,

	}

	
	for i,v in ipairs(eff_funcs) do 
		local eff = effect.new(v) 
		eff:setSkill(skill) 


	end



end



function doEffect(effect)


	-- body
end


