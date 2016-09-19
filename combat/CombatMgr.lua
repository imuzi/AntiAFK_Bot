--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 16:50:16
--
local _ = (...):match("(.-)[^%.]+$") 
require(_.."___utils")
require(_.."Const")

CombatData = require(_.."CombatData")
TargetFilters = require(_.."TargetFilters")
TurnOrders = require(_.."TurnOrders")
Behaviors = require(_.."Behaviors")
CastAi = require(_.."CastAi") 

TriggerEvents = require(_.."TriggerEvents")


CombatLogic = require(_.."CombatLogic")
SkillLogic = require(_.."SkillLogic")
local CDUpdater = require(_.."CDUpdater")

VisualEffect = require(_.."VisualEffect")
module(...,package.seeall) 
 

local scheduler = require("framework.scheduler")
local socket = require "socket"

 

looper = nil 
frame_count = 0
frame_step = 0
game_speed = 3   -- 

function init()
	CombatData.init() 

	TurnOrders.basicAttack.sort()
	TurnOrders.skill.sort()  
 
end

function start() 
 
	looper = scheduler.scheduleGlobal(main_loop, 0) 

	SkillLogic.castPassiveSkills()

	TriggerEvents.listen("combatBegin")
	
	print("combat,started!")

	CCDirector:sharedDirector():getScheduler():setTimeScale(game_speed) 
end

function stop()
	if looper then 
		scheduler.unscheduleGlobal(looper)
		looper = nil
	end
end

function pause()
	-- body
end

function resume(  )
	-- body
end


function main_loop(_dt_)
	local gap = _dt_*MAX_FPS/game_speed
	frame_count = frame_count + gap   --1  

	local scale_ratio = MAX_FPS/LOGIC_FPS/game_speed
	local frame_count_modf = modf__(frame_count)


	-- local real_logic_frame = 1/CCDirector:sharedDirector():getSecondsPerFrame()

	-- local frame_point_scale = real_logic_frame/LOGIC_FPS
	-- Behaviors.frame_point_scale = frame_point_scale
	local dif_step = frame_count/scale_ratio - frame_step
	dif_step = modf__(dif_step)
	for i=1,dif_step do
		CombatLogic.loop()

		CDUpdater.loop()

		VisualEffect.loop()
		
		frame_step = frame_step + 1
	end

	-- if (frame_count_modf%dt == 0)
	-- or (frame_count_modf/game_speed - frame_step) >= 1 then 




	-- 	CombatLogic.loop()

	-- 	CDUpdater.loop()

	-- 	VisualEffect.loop()
		
	-- 	frame_step = frame_step + 1
	-- end

	print("____________________________________________________________________________________\n\n\n"
		,"\ngap is ",gap
		,"\dif_step",dif_step
		,"\nreal_logic_frame",real_logic_frame,1/_dt_,_dt_,frame_point_scale 
		,"\n_______fame_count",frame_count
		,"\nframe_step",frame_step
		,"\nMAXSPEED,game_speed",MAXSPEED,game_speed)
end

 