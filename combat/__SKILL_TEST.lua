--
-- Author: (£þ.£þ)
-- Date: 2016-09-14 17:20:27
--


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

						-- situations = {
						-- 	{
						-- 	name = "target",
						-- 	conditions = {
						-- 			{
						-- 				name="attribute",
						-- 				params = {key="hpPercent",value=30,comp="=="}
										 
						-- 			},
						-- 			{
						-- 				name="haveBuff",
						-- 				params = {id=1,actionName=""}
										 
						-- 			}  
						-- 		}
						-- 	},
						-- 	{
						-- 	name = "host",
						-- 	conditions = {
						-- 			{
						-- 				name="attribute",
						-- 				params = {key="hpPercent",value=30,comp="=="}
										 
						-- 			},
						-- 			{
						-- 				name="haveBuff",
						-- 				params = {id=1,actionName=""}
										 
						-- 			}  
						-- 		}
						-- 	},
						-- 	{
						-- 	name = "weather",
						-- 	conditions = {
						-- 			{
						-- 				name="attribute",
						-- 				params = {key="isNight",value=true,comp="=="}
										 
						-- 			} 
						-- 		}
						-- 	},

						-- }
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
							target = "host" --[[
									turnOwner,0--拥有当前回合的武将 也带表放技能者
									caster，--本效果的释放者
									host,-- 本效果的 宿主
									all,--任何人都也可以 
							]]
						},
						round = 1,-- WARN 写一回合就是 即时释放的 会在 行为结束后清空 写 2回合 就是持续2回合的效果了
						} 

--[[
 

]]



local actionFormats = 
{
	{
		name="Poision",
		params = 
		{
			power = 100,
			element = 0, -- 0物理 1 法术
			
			round = 1,
			showType = 1, -- 用来定义BUFF的特定类型
		}
	}
	,
	{
		name="buff",
		params = 
		{
			mode = 0,
			value = 30,
			attrName = "critRate",
			stackType = 1,
			round = 1,
			showType = 1, -- 用来定义BUFF的特定类型
		}
	}
	,
	{
		name="damage",
		params = 
		{
			power = 100,
			element = 0, -- 0物理 1 法术
		}
	}
	,
	{
		name="revive",
		params = 
		{
			hpRatio = 100, 
		}
	}
	,
	{
		name="purge",
		params = 
		{
			count = 1, 
		}
	}
	,
	{
		name="deBuff",
		params = 
		{
			mode = 0,
			value = 30,
			attrName = "critRate",
			stackType = 1,
			round = 1
		} 
	}
}

local targetConditionsFormats = 
{
	{
		name="attribute",
		params = {key="hpPercent",value=30,comp="=="}
		 
	},
	{
		name="luck",
		params = {value=30} 
	},

	{
		name="haveBuff",
		params = {kind = 100}
	},
 
}

 
local targetFilterFormats = {
	--[[
		己方=0,
        敌方=1,
        自己=2,
        宿主=3
		]]
	Target= 2,
	--[[
		 
		0: 全部
		1：前排，如果没有前排，则取后排所有人
		2：后排，如果没有后排，则取前排所有人
		3: 死亡
		 
		]]
	TargetFilter= 0,
	--[[
			0： 随机排序  -- 影响表头 FrontHitRate ，BackHitRate
			1： 站位
			2： 攻击属性（Element）
			3： 性别（Gender）
			4： 攻击力（Atk）
			5： 防御力（Defence）
			6： 当前生命（HP)
			7： 最大生命（MaxHP)
			]]
	OrderRule= 0,
	--[[
			0;升序
			1：降序
			]]
	Descend= 0,
	SelectCount= 1,
}


local triggerEventFormats = {
							name= "onHit",
							-- 不填target 默认为host
							target = "host" --[[
									turnOwner,0--拥有当前回合的武将 也带表放技能者  
									actor, -- 当前行动者  WARN
									caster，--本效果的释放者
									host,-- 本效果的 宿主
									all,--任何人都也可以 
							]]
						}


return
{


 












}