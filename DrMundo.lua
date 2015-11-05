require('Inspired')

if GetObjectName(GetMyHero()) ~= "DrMundo" then return end

MundoMenu = Menu("DrMundo", "DrMundo")
MundoMenu:SubMenu("Combo", "Combo")
MundoMenu.Combo:Boolean("Q", "Use Q", true)
MundoMenu.Combo:Boolean("W", "Use W", true)
MundoMenu.Combo:Boolean("E", "Use E", true)
MundoMenu.Combo:Boolean("R", "Use R", true)

OnTick(function(myHero)

	local target  = GetCurrentTarget()

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
		if CanUseSpell(myHero, _E) == READY and ValidTarget(target, 325) and GetDistance(myHero, target) <= 200 and MundoMenu.Combo.E:Value() then
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

end)

OnDraw(function(myHero)

	for i,enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, 2000) then
			local trueDMG = getdmg("Q",target)
			local currhp = GetCurrentHP(enemy) - trueDMG
			DrawDmgOverHpBar(enemy,currhp,3,trueDMG,0xff00ffff)
		end

	end

end)
