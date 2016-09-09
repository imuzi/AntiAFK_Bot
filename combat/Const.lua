--
-- Author: (£þ.£þ)
-- Date: 2016-08-24 15:41:23
--
COMBATSCENE_NAME = "CombatScene"


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
	BASEACTION = "baseAction", -- 单纯的行为 不会有任何逻辑的触发 
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




------------ 表现类 
SPINE_ACTION_MAP = 
{
	-- 战斗待机
	[STATUS.STANDBY]        = {"wait",true},
	-- 非战斗时的待机
	stand                 = "stand",
	-- 跑动
	run                   = {"run",false},
	-- 普通攻击
	[STATUS.BASICATTACK]                = {"attack",false},
	[STATUS.COMBOATTACK]                = {"attack",false},
	[STATUS.COUNTERATTACK]             = {"attack",false},
	[STATUS.BASEACTION]                = {"attack",false},
	-- 技能攻击
	SkillA = {"skill1",false},
	-- 超必杀攻击
	SkillB = {"skill2",false},
	-- 被攻击到了
	onHit            = {"hit",false},
	-- 挂了
	[STATUS.DEAD]            = {"death",false},
	-- 释放技能前的吟唱
	-- sing                  = "sing",
	stun                  = {'stun',true}
}

 
STATION_POSITIONS =  -- 前排只有两个人的站位
{
    {
        x = 325, 
        y = 295+0 
    },
    {
        x = 255, 
        y = 185+0         
    },
    {
        x = 185, 
        y = 350+0
    },
    {
        x = 125, 
        y = 250+0
    },
    {
        x = 65, 
        y = 150+0
    }
}