require('Inspired')
require('DamageLib')

if GetObjectName(GetMyHero()) ~= "DrMundo" then return end

if not pcall( require, "Inspired" ) then PrintChat("You are missing Inspired.lua - Go download it and save it Common!") return end
if not pcall( require, "DamageLib" ) then PrintChat("You are missing DamageLib.lua - Go download it and save it in Common!") return end

local MundoMenu = Menu("DrMundo", "DrMundo")
MundoMenu:SubMenu("Combo", "Combo")
MundoMenu.Combo:Boolean("Q", "Use Q", true)
MundoMenu.Combo:Boolean("W", "Use W", true)
MundoMenu.Combo:Boolean("E", "Use E", true)
MundoMenu.Combo:Boolean("R", "Use R", true)

MundoMenu:Menu("Harass", "Harass")
MundoMenu.Harass:Boolean("Q", "Use Q", true)
MundoMenu.Harass:Boolean("E", "Use E", true)

MundoMenu:Menu("Killsteal", "Killsteal")
MundoMenu.Killsteal:Boolean("Q", "Killsteal with Q", true)
MundoMenu.Killsteal:Boolean("E", "Killsteal with E", true)

MundoMenu:Menu("Misc", "Misc")
if Ignite ~= nil then MundoMenu.Misc:Boolean("Autoignite", "Auto Ignite", true) end
MundoMenu.Misc:Boolean("Autolvl", "Auto level", true)
MundoMenu.Misc:DropDown("Autolvltable", "Priority", 1, {"Q-W-E", "Q-E-W"})

MundoMenu:Menu("Lasthit", "Lasthit")
MundoMenu.Lasthit:Boolean("Q", "Use Q", true)

MundoMenu:Menu("LaneClear", "LaneClear")
MundoMenu.LaneClear:Boolean("Q", "Use Q", true)
MundoMenu.LaneClear:Boolean("W", "Use W", false)
MundoMenu.LaneClear:Boolean("E", "Use E", false)

MundoMenu:Menu("JungleClear", "JungleClear")
MundoMenu.JungleClear:Boolean("Q", "Use Q", true)
MundoMenu.JungleClear:Boolean("W", "Use W", true)
MundoMenu.JungleClear:Boolean("E", "Use E", true)

MundoMenu:Menu("Drawings", "Drawings")
MundoMenu.Drawings:Boolean("Q", "Draw Q Range", true)
MundoMenu.Drawings:Boolean("W", "Draw W Range", true)
MundoMenu.Drawings:Boolean("E", "Draw E Range", true)
MundoMenu.Drawings:ColorPick("color", "Color Picker", {255,255,255,0})

local lastlevel = GetLevel(myHero)-1

OnDraw(function(myHero)
	local col = MundoMenu.Drawings.color:Value()
	local pos = GetOrigin(myHero)
	if MundoMenu.Drawings.Q:Value() then DrawCircle(pos,1000,1,0,col) end
	if MundoMenu.Drawings.W:Value() then DrawCircle(pos,325,1,0,col) end
	if MundoMenu.Drawings.E:Value() then DrawCircle(pos,125,1,0,col) end
	end)

OnTick(function(myHero)

	local target  = GetCurrentTarget()

	-- COMBO
	if IOW:Mode() == "Combo" then

		local QPred   = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target),2000,250,1050,75,true,false)
		local WRange  = 325
		local WbRange = 805
		local wUsed   = false

		-- AUTO CAST Q
		if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 and ValidTarget(target, 1050) and GetDistance(myHero, target) <= 999 and MundoMenu.Combo.Q:Value() then
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
		end

		-- AUTO CAST W
		if GotBuff(myHero, "BurningAgony") ~= 1 then
			if CanUseSpell(myHero, _W) == READY and ValidTarget(target, 325) then
				CastTargetSpell(myHero, _W)
			end
		end

		if GotBuff(myHero, "BurningAgony") == 1 then
			if CanUseSpell(myHero, _W) == READY and GetDistance(myHero, target) >= 600 or ValidTarget(target, 325) == nil then
				CastTargetSpell(myHero, _W)
			end
		end

		-- AUTO CAST E
		if CanUseSpell(myHero, _E) == READY and ValidTarget(target, 200) and MundoMenu.Combo.E:Value() then
			CastSpell(_E)
		end

		-- AUTO CAST R
		local minhaHP = GetCurrentHP(myHero)
		if  minhaHP < (GetMaxHP(myHero)*(20*0.01)) then
			if CanUseSpell(myHero, _R) then
				CastSpell(_R)
			end
		end

	end

	-- HARASS
	if IOW:Mode() == "Harass" then
		-- AUTO CAST Q
		if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 and ValidTarget(target, 1050) and GetDistance(myHero, target) <= 999 then
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
		end
		-- AUTO CAST E
		if CanUseSpell(myHero, _E) == READY and ValidTarget(target, 200) and MundoMenu.Combo.E:Value() then
			CastSpell(_E)
		end

	end

	-- AUTO IGNITE | KILL STEAL
	for i,enemy in pairs(GetEnemyHeroes()) do

		if Ignite and MundoMenu.Misc.Autoignite:Value() then
			if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*2.5 and ValidTarget(enemy, 600) then
				CastTargetSpell(enemy, Ignite)
			end
		end

		if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 and ValidTarget(target, 1050) and GetDistance(myHero, target) <= 999 and MundoMenu.Killsteal.Q:Value() and GetHP2(enemy) < getdmg("Q",enemy) then
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
			elseif CanUseSpell(myHero, _E) == READY and ValidTarget(enemy, 200) and MundoMenu.Killsteal.E:Value() and GetHP2(enemy) < getdmg("E",enemy) then
				CastSpell(_E)
			end

		end

	end

	-- LANE CLEAR
	if IOW:Mode() == "LaneClear" then
		local closeminion = ClosestMinion(GetOrigin(myHero), MINION_ENEMY)

		if CanUseSpell(myHero, _Q) == READY and MundoMenu.LaneClear.Q:Value() then
			if GetCurrentHP(closeminion) < getdmg("Q",closeminion) and ValidTarget(closestminion, 1000) then
				CastSkillShot(_Q, GetOrigin(closeminion))
			end
		end

		if GotBuff(myHero, "BurningAgony") ~= 1 then
			if CanUseSpell(myHero, _W) == READY and ValidTarget(closestminion, 325) and MundoMenu.LaneClear.W:Value() then
				CastSpell(_W)
			end
		end

		if GotBuff(myHero, "BurningAgony") == 1 then
			if CanUseSpell(myHero, _W) == READY and GetDistance(myHero, closeminion) >= 500 or ValidTarget(closestminion, 325) == nil and MundoMenu.LaneClear.W:Value() then
				CastSpell(_W)
			end
		end

		if CanUseSpell(myHero, _E) == READY and MundoMenu.LaneClear.E:Value() then
			if GetCurrentHP(closeminion) < getdmg("E",closeminion) and ValidTarget(closestminion, 125) then
				CastSpell(_E, GetOrigin(closeminion))
			end
		end

	end

	-- JUNGLE CLEAR | LAST HIT
	for i,mobs in pairs(minionManager.objects) do
		if IOW:Mode() == "LaneClear" and GetTeam(mobs) == 300 then
			if CanUseSpell(myHero, _Q) == READY and MundoMenu.JungleClear.Q:Value() and ValidTarget(mobs, 1000) then
				CastSkillShot(_Q,GetOrigin(mobs))
			end

			if CanUseSpell(myHero, _W) == READY and MundoMenu.JungleClear.W:Value() and ValidTarget(mobs, 325) then
				CastSpell(_W)
			end

			if CanUseSpell(myHero, _E) == READY and MundoMenu.JungleClear.E:Value() and ValidTarget(mobs, 125) then
				CastSpell(_E)
			end
		end

		if IOW:Mode() == "LastHit" and GetTeam(mobs) == MINION_ENEMY then
			if CanUseSpell(myHero, _Q) == READY and ValidTarget(mobs, 1000) and MundoMenu.Lasthit.Q:Value() and GetCurrentHP(mobs) < getdmg("Q",mobs) then
				CastSkillShot(_Q, GetOrigin(mobs))
			end
		end
	end

	-- AUTO SKILL LEVEL
	if MundoMenu.Misc.Autolvl:Value() then  
		
		if GetLevel(myHero) > lastlevel then
			if MundoMenu.Misc.Autolvltable:Value() == 1 then leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
				elseif MundoMenu.Misc.Autolvltable:Value() == 2 then leveltable = {_Q, _E, _W, _Q, _Q , _R, _Q , _E, _Q , _E, _R, _E, _E, _W, _W, _R, _W, _W}
					DelayAction(function() LevelSpell(leveltable[GetLevel(myHero)]) end, math.random(1000,3000))
					lastlevel = GetLevel(myHero)
				end
			end

		end

		end)
