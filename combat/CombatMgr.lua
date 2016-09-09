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

Performances = require(_.."Performances")
module(...,package.seeall) 
 

local scheduler = require("framework.scheduler")
local socket = require "socket"


 

looper = nil 
frame_count = 0
frame_step = 0
game_speed = 1

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


function main_loop()
	 
	frame_count = frame_count + 1 

	local dt = MAXSPEED/game_speed
	
	if frame_count%dt == 0 then 




		CombatLogic.loop()

		CDUpdater.loop()

		Performances.loop()
		
		frame_step = frame_step + 1
	end

	print("____________________________________________________________________________________\n\n\n"
		,frame_count%dt,dt
		,"\n_______fame_count",frame_count
		,"\nframe_step",frame_step
		,"\nMAXSPEED,game_speed",MAXSPEED,game_speed)
end

 