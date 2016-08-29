--
-- Author: (£þ.£þ)
-- Date: 2016-08-24 15:41:23
--

SKILLTYPES = 
-- 对应 skill表 AICategory
{
	"DPS",
	"BUFF",
	"CONTROL",
	"HEAL",
	"REVIVE"
}


-- 公CD
G_CD = 12 
-- 初始CD
INIT_CD = 4


MAX_FPS = 60 
-- 正常速度的逻辑的调用间隔fps
LOGIC_FPS = 20
-- 游戏速度数值 保底的 20fps  fixme
SP_X3 = MAX_FPS/LOGIC_FPS
SP_X2 = SP_X3/2 
SP_X1 = SP_X3/3
MAXSPEED = SP_X3 

