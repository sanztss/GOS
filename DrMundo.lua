require('Inspired')
MundoMenu = Menu("Mundo", "Mundo")
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
		local WbRange = 355 
		local wUsed   = false


		if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 and ValidTarget(target, 1050) and GetDistance(myHero, target) <= 999 and MundoMenu.Combo.Q:Value() then
			CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
		end


		if GetDistance(myHero, target) < WRange and MundoMenu.Combo.W:Value() then
                if wUsed == false then
                        CastSkillShot(_W)
                        wUsed = true
                end
        elseif GetDistance(myHero, target) > wbRange and wUsed == true and MundoMenu.Combo.W:Value() then
                CastSkillShot(_W)
                wUsed = false
        end


		if CanUseSpell(myHero, _E) == READY and ValidTarget(target, 225) and GetDistance(myHero, target) <= 200 and MundoMenu.Combo.E:Value() then
			CastSkillShot(_E)
		end

	end

	if myHero.health < (myHero.maxHealth*(20*0.01)) then
		if CanUseSpell(myHero, _R) then
			CastSkillShot(_R)
		end
	end

end)
OnDraw(function(myHero)

for i,enemy in pairs(GetEnemyHeroes()) do

  if ValidTarget(enemy, 2000) then
  local trueDMG = getdmg("Q",target,myHero,GetCastLevel(source, _Q))
  DrawDmgOverHpBar(enemy,GetCurrentHP(enemy),trueDMG,0,0xffffff00)
  end
    
end

end)

