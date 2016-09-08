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

TEMP_EFFECT_VARS = 
{
	"mustCrit",
	"mustIgnoreDefence",
	"mustDie",
	"mustCounterAttack",
	"buSi", 
	"ingnoreSelect", -- 不能被选中 
	"selectFirst", -- 优先选中
	"iceBlock",
	"stun",
	"sleep",
	"silence",
}


STATUS = {
	BASICATTACK = "basicAttack",
	COUNTERATTACK = "counterAttack",
	COMBOATTACK = "comboAttack",
	EXTRATURN = "extraTurn",
	STANDBY = "standBy",
	CASTSKILL = "castSkill",
	DEAD = "dead",
}



-- 将出战双方抽象为 攻方  守方
ATTACKER = "ATTACKER"
DEFENDER = "DEFENDER"

BASIC_SKILL_TYPE = "attack"



MAX_FPS = 60 
-- 正常速度的逻辑的调用间隔fps
LOGIC_FPS = 30
-- 游戏速度数值 保底的 20fps  fixme
SP_X2 = MAX_FPS/LOGIC_FPS
SP_X1 = SP_X2/2 
-- SP_X1 = SP_X3/3
MAXSPEED = SP_X2 



-- 公CD
G_CD = 16*30 
-- 初始CD
INIT_CD = 4*30

-- 子弹飞行fps
BULLET_FLYFRAME = 10
 
