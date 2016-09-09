--
-- Author: (£þ.£þ)
-- Date: 2016-09-01 18:31:55
--
local CombatMgr = 
require("app.combat.CombatMgr")

 
local fileUtil = CCFileUtils:sharedFileUtils()
fileUtil:addSearchPath("res/")

local CombatScene = quick_class(COMBATSCENE_NAME,function()
	return display.newScene(COMBATSCENE_NAME)
end)


function CombatScene:ctor()
	CombatMgr.init()
	Performances.init(self) 

end

function CombatScene:onExit()
	-- body
end

function CombatScene:onEnter() 

	CombatMgr.start()
end
 
 








return CombatScene
