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

local gameSpeed = 4

function CombatScene:ctor()
	CombatMgr.init()
	VisualEffect.init(self) 

end

function CombatScene:onExit()
	-- body
end

function CombatScene:onEnter() 

	self:setGameSpeed(gameSpeed)
	CombatMgr.start()

end
 

function CombatScene:setGameSpeed(val)
	gameSpeed = val 
	CombatMgr.set_game_speed(gameSpeed) 
end

function CombatScene:dropFrame(ratio)
	local dropedSpeed = gameSpeed*ratio
	print("ratio.",ratio)

	CombatMgr.set_game_speed(dropedSpeed)
end

function CombatScene:resetGameSpeed()
	self:setGameSpeed(gameSpeed)
end



---------- ui 
function CombatScene:BG()
	-- body
end



function CombatScene:FUNCTION_BTNS()
	local speedBtn,autoCastSwitchBtn 


	
end

function CombatScene:FUNCTION_BTNS()
	-- body
end



return CombatScene
