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
							-- targetFilter= {
							-- 	Target= 2,
							-- 	TargetFilter= 0,
							-- 	OrderRule= 0,
							-- 	Descend= 0,
							-- 	SelectCount= 1,
							-- },
						},
						round = 1,
						} 

local actions = {
	{
		name="newEffect",
		params = {
		 
	}
	 
	}

}











return
{


 












}