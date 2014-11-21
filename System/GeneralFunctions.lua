function IGetLocation(Unit)
	return ObjectPosition(Unit)
end

function UnitBuffID(unit, spellID, filter)
	local spellName = GetSpellInfo(spellID)
	if filter == nil then
		return UnitBuff(unit, spellName)
	else
		local exactSearch = strfind(strupper(filter), "EXACT")
		local playerSearch = strfind(strupper(filter), "PLAYER")
		if exactSearch then
			for i=1,40 do
				local _, _, _, _, _, _, _, buffCaster, _, _, buffSpellID = UnitBuff(unit, i)
				if buffSpellID ~= nil then
					if buffSpellID == spellID then
						if (not playerSearch) or (playerSearch and (buffCaster == "player")) then
							return UnitBuff(unit, i)
						end
					end
				else
					return nil
				end
			end
		else
			return UnitBuff(unit, spellName, nil, filter)
		end
	end
end

function UnitDebuffID(unit, spellID, filter)
	local spellName = GetSpellInfo(spellID)
	if filter == nil then
		return UnitDebuff(unit, spellName)
	else
		local exactSearch = strfind(strupper(filter), "EXACT")
		local playerSearch = strfind(strupper(filter), "PLAYER")

		if exactSearch then
			for i=1,40 do
				local _, _, _, _, _, _, _, buffCaster, _, _, buffSpellID = UnitDebuff(unit, i)
				if buffSpellID ~= nil then
					if buffSpellID == spellID then
						if (not playerSearch) or (playerSearch and (buffCaster == "player")) then
							return UnitDebuff(unit, i)
						end
					end
				else
					return nil
				end
			end
		else
			return UnitDebuff(unit, spellName, nil, filter)
		end
	end
end

--[[           ]]		  --[[]]		--[[]]     --[[]]
--[[           ]]		 --[[  ]]		--[[  ]]   --[[]]
--[[]]				    --[[    ]] 		--[[    ]] --[[]]
--[[]]				   --[[      ]] 	--[[           ]]
--[[]]				  --[[        ]]	--[[           ]]
--[[           ]]	 --[[]]    --[[]]	--[[]]   --[[  ]]
--[[           ]]	--[[]]      --[[]]	--[[]]     --[[]]

-- if canAttack("player","target") then
function canAttack(Unit1,Unit2)
	if Unit1 == nil then Unit1 = "player"; end
	if Unit2 == nil then Unit2 = "target"; end
	-- if UnitCanAttack(Unit1,Unit2) == 1 then
	-- 	return true;
	-- end
	return UnitCanAttack(Unit1,Unit2)
end

-- if canCast(12345,true)
function canCast(SpellID,KnownSkip,MovementCheck)
	local myCooldown = getSpellCD(SpellID)
	local lagTolerance = getValue("Lag Tolerance") or 0;
  	if (KnownSkip == true or isKnown(SpellID)) and IsUsableSpell(SpellID)
   	  and (MovementCheck == false or myCooldown == 0 or isMoving("player") ~= true or UnitBuffID("player",79206) ~= nil) then
      	return true;
    end
end

function canDisarm(Unit)
	if DisarmedTarget == nil then DisarmedTarget = 0 end
	if isDisarmed == true then
		if UnitExists(Unit) and UnitGUID(Unit)~=DisarmedTarget then
			DisarmedTarget = UnitGUID(Unit)
			return false
		else
			isDisarmed = false
			return true
		end
	end
	if not isInCombat("player") or UnitExists(Unit) then
		if not isInCombat("player") or UnitGUID(Unit)~=DisarmedTarget then
			isDisarmed = false
			return true
		end
	end
end

-- if canDispel("target",SpellID) == true then
function canDispel(Unit,spellID)
  	local HasValidDispel = false
  	local ClassNum = select(3, UnitClass("player"))
	if ClassNum == 1 then --Warrior
		typesList = { }
	end
	if ClassNum == 2 then --Paladin
		typesList = { }
	end
	if ClassNum == 3 then --Hunter
		typesList = { }
	end
	if ClassNum == 4 then --Rogue
		-- Cloak of Shadows
		if spellID == 31224 then typesList = { "Poison", "Curse", "Disease", "Magic" } end
	end
	if ClassNum == 5 then --Priest
		typesList = { }
	end
	if ClassNum == 6 then --Death Knight
		typesList = { }
	end
	if ClassNum == 7 then --Shaman
		if spellID == 51886 then typesList = { "Curse" } end -- Cleanse Spirit
	end
	if ClassNum == 8 then --Mage
		typesList = { }
	end
	if ClassNum == 9 then --Warlock
		typesList = { }
	end
	if ClassNum == 10 then --Monk
		-- Detox
		if spellID == 115450 then typesList = { "Poison", "Disease" } end
		-- Diffuse Magic
		if spellID == 122783 then typesList = { "Magic" } end
	end
	if ClassNum == 11 then --Druid
		-- Remove Corruption
		if spellID == 2782 then typesList = { "Poison", "Curse" } end
		-- Nature's Cure
		if spellID == 88423 then typesList = { "Poison", "Curse", "Magic" } end
		-- Symbiosis: Cleanse
		if spellID == 122288 then typesList = { "Poison", "Disease" } end
	end
	local function ValidType(debuffType)
		if typesList == nil then
			return false
		else
	  		for i = 1, #typesList do
	  			if typesList[i] == debuffType then
	  				return true;
	  			else
	  				return false;
	  			end
	  		end
	  	end
  	end
	local ValidDebuffType = false
	local i = 1
  	while UnitDebuff(Unit, i) do
  		local _, _, _, _, debuffType, _, _, _, _, _, debuffid = UnitDebuff(Unit, i)
  		-- Blackout Debuffs
  		if debuffType and ValidType(debuffType)
  			and debuffid ~= 138732 --Ionization from Jin'rokh the Breaker - ptr
			and debuffid ~= 138733 --Ionization from Jin'rokh the Breaker - live
		then
  			HasValidDispel = true
  			break;
  		end
  		i = i + 1
  	end
	return HasValidDispel
end

-- if canHeal("target") then
function canHeal(Unit)
	if UnitExists(Unit) and UnitInRange(Unit) == true and UnitCanCooperate("player",Unit)
		and not UnitIsEnemy("player",Unit) and not UnitIsCharmed(Unit) and not UnitIsDeadOrGhost(Unit)
		and getLineOfSight(Unit) == true and not UnitDebuffID(Unit,33786) then
		return true;
	end
	return false;
end

-- canInterrupt("target", 20)
function canInterrupt(unit, percentint)
    local unit = unit or "target"
    local castDuration = 0
    local castTimeRemain = 0
    local castPercent = 0 -- Possible to set hard coded value
    local channelDelay = 0.4 -- Delay to mimick human reaction time for channeled spells
    local interruptable = false
    local castType = "spellcast" -- Handle difference in logic if the spell is cast or being channeles
    if UnitExists(unit)
        and UnitCanAttack("player", unit)
        and not UnitIsDeadOrGhost(unit)
    then
        if select(6,UnitCastingInfo(unit)) and not select(9,UnitCastingInfo(unit)) then --Get spell cast time
            castStartTime = select(5,UnitCastingInfo(unit))
            castEndTime = select(6,UnitCastingInfo(unit))
            interruptable = true
            castType = "spellcast"
        elseif select(6,UnitChannelInfo(unit)) and select(8,UnitChannelInfo(unit)) then -- Get spell channel time
            castStartTime = select(5,UnitChannelInfo(unit))
            castEndTime = select(6,UnitChannelInfo(unit))
            interruptable = true
            castType = "spellchannel"
        else
            castStartTime = 0
            castEndTime = 0
            interruptable = false
        end
        if castEndTime > 0 and castStartTime > 0 then
            castDuration = (castEndTime - castStartTime)/1000
            castTimeRemain = ((castEndTime/1000) - GetTime())
            if percentint == nil and castPercent == 0 then
                castPercent = math.random(75, 95) --  I am not sure that this is working, we are doing this check every pulse so its different randoms each time
            elseif percentint == 0 and castPercent == 0 then
                castPercent = math.random(75, 95)
            elseif percentint > 0 then
                castPercent = percentint
            end
        else
            castDuration = 0
            castTimeRemain = 0
            castPercent = 0
        end
        if castType == "spellcast" then
        	if math.ceil((castTimeRemain/castDuration)*100) <= castPercent and interruptable == true then
            	return true
        	end
        end
        if castType == "spellchannel" then
        	if (GetTime() - castStartTime/1000) > channelDelay and interruptable == true then
        		return true
        	end
        end
        return false
    end
end

-- if canPrepare() then
function canPrepare()
	if UnitBuffID("player",104934) -- Eating (Feast)
	  or UnitBuffID("player",80169) -- Eating
	  or UnitBuffID("player",87959) -- Drinking
	  or UnitBuffID("player",11392) -- 18 sec Invis Pot
	  or UnitBuffID("player",3680) -- 15 sec Invis pot
	  or UnitBuffID("player",5384) -- Feign Death
	  or IsMounted() then
	  	return false;
	else
	  	return true;
	end
end

-- if canRun() then
function canRun()
	if BadBoy_data['Pause'] ~= 1 then
		if BadBoy_data["Power"] == 1 and isAlive("player") then
			if SpellIsTargeting()
			  or UnitInVehicle("Player")
			  or  (IsMounted() and ((getUnitID("target") ~= 56877) or (not UnitBuffID("player",164222)) or (not UnitBuffID("player",165803))))
			  or UnitIsDeadOrGhost("player") ~= false
			  or UnitBuffID("player",11392) ~= nil
			  or UnitBuffID("player",80169) ~= nil
			  or UnitBuffID("player",87959) ~= nil
			  or UnitBuffID("player",104934) ~= nil
			  or UnitBuffID("player",9265) ~= nil then -- Deep Sleep(SM)
				return nil;
			else
				return true;
			end
		end
	else
		ChatOverlay("|cffFF0000-BadBoy Paused-")
		return false;
	end
end

-- if canUse(1710) then
function canUse(itemID)
	local goOn = true;
	local DPSPotionsSet = {
		[1] = {Buff = 105702, Item = 76093}, -- Intel
		[2] = {Buff = 105697, Item = 76089}, -- Agi
		[3] = {Buff = 105706, Item = 76095}, -- Str
	}
	for i = 1, #DPSPotionsSet do
		if DPSPotionsSet[i].Item == itemID then
			if potionUsed then
				if potionUsed <= GetTime() - 60000 then
					goOn = false;
				else
					if potionUsed > GetTime() - 60000 and potionReuse == true then
						goOn = true;
					end
					if potionReuse == false then
						goOn = false;
					end
				end
			end
		end
	end
	if goOn == true and GetItemCount(itemID,false,false) > 0 then
		if select(2,GetItemCooldown(itemID))==0 then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end


function castAoEHeal(spellID, numUnits, missingHP, rangeValue)
	-- i start an iteration that i use to build each units Table, wich i will reuse for the next second
	if not holyRadianceRangeTable or not holyRadianceRangeTableTimer or holyRadianceRangeTable <= GetTime() - 1 then
		holyRadianceRangeTable = { }
		for i = 1, #nNova do
			-- i declare a sub-table for this unit if it dont exists
			if nNova[i].distanceTable == nil then nNova[i].distanceTable = { } end
			-- i start a second iteration where i scan unit ranges from one another.
			for j = 1, #nNova do
				-- i make sure i dont compute unit range to hisself.
				if not UnitIsUnit(nNova[i].unit,nNova[j].unit) then
					-- table the units
					nNova[i].distanceTable[j] = { distance = getDistance(nNova[i].unit,nNova[j].unit), unit = nNova[j].unit, hp = nNova[j].hp }
				end
			end
		end
	end
	-- declare locals that will hold number
	local bestTarget, bestTargetUnits = 1, 1
	-- now that nova range is built, i can iterate it
	local inRange, missingHealth, mostMissingHealth = 0, 0, 0
	for i = 1, #nNova do
		if nNova[i].distanceTable ~= nil then
			-- i count units in range
			for j = 1, #nNova do
				if nNova[i].distanceTable[j] and nNova[i].distanceTable[j].distance < rangeValue then
					inRange = inRange + 1
					missingHealth = missingHealth + (100 - nNova[i].distanceTable[j].hp)
				end
			end
			nNova[i].inRangeForHolyRadiance = inRange
			-- i check if this is going to be the best unit for my spell
			if missingHealth > mostMissingHealth then
				bestTarget, bestTargetUnits, mostMissingHealth = i, inRange, missingHealth
			end
		end
	end
	if bestTargetUnits and bestTargetUnits > 3 and mostMissingHealth and missingHP and mostMissingHealth > missingHP then
		if castSpell(nNova[bestTarget].unit, spellID, true, true) then return true end
	end
end

-- castGround("target",12345,40);
function castGround(Unit,SpellID,maxDistance)
	if UnitExists(Unit) and getSpellCD(SpellID) == 0 and getLineOfSight("player", Unit) and getDistance("player", Unit) <= maxDistance then
 		CastSpellByName(GetSpellInfo(SpellID),"player");
		if IsAoEPending() then
		local X, Y, Z = ObjectPosition(Unit);
			CastAtPosition(X,Y,Z);
			return true;
		end
 	end
 	return false;
end

-- castGroundBetween("target",12345,40);
function castGroundBetween(Unit,SpellID,maxDistance)
	if UnitExists(Unit) and getSpellCD(SpellID) <= 0.4 and getLineOfSight("player", Unit) and getDistance("player", Unit) <= 5 then
 		CastSpellByName(GetSpellInfo(SpellID),"player");
		if IsAoEPending() then
		local X, Y, Z = ObjectPosition(Unit);
			CastAtPosition(X, Y, Z);
			return true;
		end
 	end
 	return false;
end

-- if shouldNotOverheal(spellCastTarget) > 80 then
function shouldNotOverheal(Unit)
	local myIncomingHeal, allIncomingHeal = 0, 0
	if UnitGetIncomingHeals(Unit, "player") ~= nil then myIncomingHeal = UnitGetIncomingHeals(Unit, "player"); end
	if UnitGetIncomingHeals(Unit) ~= nil then allIncomingHeal = UnitGetIncomingHeals(Unit); end
	local allIncomingHeal = UnitGetIncomingHeals(Unit) or 0;
	local overheal = 0;
	if myIncomingHeal >= allIncomingHeal then
		overheal = myIncomingHeal;
	else
		overheal = allIncomingHeal;
	end
	local CurShield = UnitHealth(Unit);
	if UnitDebuffID("player",142861) then --Ancient Miasma
		CurShield = select(15,UnitDebuffID(Unit, 142863)) or select(15,UnitDebuffID(Unit, 142864)) or select(15,UnitDebuffID(Unit, 142865)) or (UnitHealthMax(Unit) / 2);
		overheal = 0;
	end
	local overhealth = 100 * (CurShield+ overheal ) / UnitHealthMax(Unit);
	if overhealth and overheal then
		return overhealth, overheal;
	else
		return 0, 0;
	end
end

-- if castHealGround(_HealingRain,18,80,3) then
function castHealGround(SpellID,Radius,Health,NumberOfPlayers)
	if shouldStopCasting(SpellID) ~= true then
		local lowHPTargets, foundTargets = { }, { };
		for i = 1, #nNova do
			if nNova[i].hp <= Health then
				if UnitIsVisible(nNova[i].unit) and ObjectPosition(nNova[i].unit) ~= nil then
					local X, Y, Z = ObjectPosition(nNova[i].unit);
					tinsert(lowHPTargets, { unit = nNova[i].unit, x = X, y = Y, z = Z });
		end end end
		if #lowHPTargets >= NumberOfPlayers then
			for i = 1, #lowHPTargets do
				for j = 1, #lowHPTargets do
					if lowHPTargets[i].unit ~= lowHPTargets[j].unit then
						if math.sqrt(((lowHPTargets[j].x-lowHPTargets[i].x)^2)+((lowHPTargets[j].y-lowHPTargets[i].y)^2)) < Radius then
							for k = 1, #lowHPTargets do
								if lowHPTargets[i].unit ~= lowHPTargets[k].unit and lowHPTargets[j].unit ~= lowHPTargets[k].unit then
									if math.sqrt(((lowHPTargets[k].x-lowHPTargets[i].x)^2)+((lowHPTargets[k].y-lowHPTargets[i].y)^2)) < Radius and math.sqrt(((lowHPTargets[k].x-lowHPTargets[j].x)^2)+((lowHPTargets[k].y-lowHPTargets[j].y)^2)) < Radius then
										tinsert(foundTargets, { unit = lowHPTargets[i].unit, x = lowHPTargets[i].x, y = lowHPTargets[i].y, z = lowHPTargets[i].z });
										tinsert(foundTargets, { unit = lowHPTargets[j].unit, x = lowHPTargets[j].x, y = lowHPTargets[j].y, z = lowHPTargets[i].z });
										tinsert(foundTargets, { unit = lowHPTargets[k].unit, x = lowHPTargets[k].x, y = lowHPTargets[k].y, z = lowHPTargets[i].z });
			end end end end end end end
			local medX,medY,medZ = 0,0,0;
			if foundTargets ~= nil and #foundTargets >= NumberOfPlayers then
				for i = 1, 3 do
					medX = medX + foundTargets[i].x;
					medY = medY + foundTargets[i].y;
					medZ = medZ + foundTargets[i].z;
				end
				medX,medY,medZ = medX/3,medY/3,medZ/3
				local myX, myY = ObjectPosition("player");
				if math.sqrt(((medX-myX)^2)+((medY-myY)^2)) < 40 then
			 		CastSpellByName(GetSpellInfo(SpellID),"player");
					if IsAoEPending() then
						CastAtPosition(medX,medY,medZ);
						if SpellID == 145205 then shroomsTable[1] = { x = medX, y = medY, z = medZ}; end
						return true;
	end end end end end
	return false;
end

--[[castSpell(Unit,SpellID,FacingCheck,MovementCheck,SpamAllowed,KnownSkip)
Parameter 	Value
First 	 	UnitID 			Enter valid UnitID
Second 		SpellID 		Enter ID of spell to use
Third 		Facing 			True to allow 360 degrees, false to use facing check
Fourth 		MovementCheck	True to make sure player is standing to cast, false to allow cast while moving
Fifth 		SpamAllowed 	True to skip that check, false to prevent spells that we dont want to spam from beign recast for 1 second
Sixth 		KnownSkip 		True to skip isKnown check for some spells that are not managed correctly in wow's spell book.
]]

-- getLatency()
function getLatency()
	local lag = ((select(3,GetNetStats()) + select(4,GetNetStats())) / 1000)
	if lag < .05 then
		lag = .05
	elseif lag > .4 then
		lag = .4
	end
	return lag
end

-- castSpell("target",12345,true);
function castSpell(Unit,SpellID,FacingCheck,MovementCheck,SpamAllowed,KnownSkip)
	if shouldStopCasting(SpellID) ~= true and not UnitIsDeadOrGhost(Unit) then
		-- stop if not enough power for that spell
		if IsUsableSpell(SpellID) ~= true then return false; end
		-- Table used to prevent refiring too quick
	    if timersTable == nil then timersTable = { }; end
		-- make sure it is a known spell
		if not (KnownSkip == true or isKnown(SpellID)) then return false; end
		-- gather our spell range information
		local spellRange = select(6,GetSpellInfo(SpellID));
	  	if spellRange == nil or spellRange < 4 then spellRange = 4; end
		-- Check unit, if it's player then we can skip facing
		if (Unit == nil or UnitIsUnit("player",Unit)) or -- Player
			(Unit ~= nil and UnitIsFriend("player",Unit)) then FacingCheck = true; end -- Ally
		-- if MovementCheck is nil or false then we dont check it
		if MovementCheck == false or isMoving("player") ~= true or UnitBuffID("player",79206) ~= nil then
			-- if ability is ready and in range
			if (isChecked("Allow Failcasts") or getSpellCD(SpellID) == 0) and (isChecked("Skip Distance Check") or getDistance("player",Unit) < spellRange) then
				-- if spam is not allowed
	    		if SpamAllowed == false then
	    			-- get our last/current cast
	      			if timersTable == nil or (timersTable ~= nil and (timersTable[SpellID] == nil or timersTable[SpellID] <= GetTime() -0.6)) then
	       				if (FacingCheck == true or getFacing("player",Unit) == true) and (UnitIsUnit("player",Unit) or getLineOfSight("player",Unit) == true) then
	        				timersTable[SpellID] = GetTime();
	        				currentTarget = UnitGUID(Unit);
	        				CastSpellByName(GetSpellInfo(SpellID),Unit);
							if BadBoy_data["Power"] == 1 then mainButton:SetNormalTexture(select(3,GetSpellInfo(SpellID))); end
	        				return true;
	        			end
					end
				elseif (FacingCheck == true or getFacing("player",Unit) == true) and (UnitIsUnit("player",Unit) or getLineOfSight("player",Unit) == true) then
	  		   		currentTarget = UnitGUID(Unit);
					CastSpellByName(GetSpellInfo(SpellID),Unit);
					if BadBoy_data["Power"] == 1 then mainButton:SetNormalTexture(select(3,GetSpellInfo(SpellID))); end
					return true;
				end
	    	end
	  	end
	end
  	return false;
end

function castMouseoverHealing(Class)
	if UnitAffectingCombat("player") then
		local spellTable = {
			["Druid"] = { heal = 8936, dispel = 88423 },
		}
		local npcTable = {
			71604, -- Contaminated Puddle- Immerseus - SoO
			71995, -- Norushen
			71996, -- Norushen
			72000, -- Norushen
			71357, -- Wrathion
		}
		local SpecialTargets = { "mouseover", "target", "focus" }
		local dispelid = spellTable[Class].dispel
		for i = 1, #SpecialTargets do
			local target = SpecialTargets[i]
			if UnitExists(target) and not UnitIsPlayer(target) then
				local npcID = tonumber(string.match(UnitGUID(target), "-(%d+)-%x+$"))
				for i = 1, #npcTable do
					if npcID == npcTable[i] then
						-- Dispel
						for n = 1,40 do
					      	local buff,_,_,count,bufftype,duration = UnitDebuff(target, n)
				      		if buff then
				        		if bufftype == "Magic" or bufftype == "Curse" or bufftype == "Poison" then
				        			if castSpell(target,88423, true,false) then return; end
				        		end
				      		else
				        		break;
				      		end
					  	end
					  	-- Heal
						local npcHP = getHP(target)
						if npcHP < 100 then
							if castSpell(target,spellTable[Class].heal,true) then return; end
						end
					end
				end
			end
		end
	end
end


--[[           ]]   --[[           ]]    --[[           ]]
--[[           ]]   --[[           ]]    --[[           ]]
--[[]]              --[[]]        		       --[[ ]]
--[[]]   --[[  ]]	--[[           ]]          --[[ ]]
--[[]]     --[[]]	--[[]]        		       --[[ ]]
--[[           ]]   --[[           ]]          --[[ ]]
--[[           ]]   --[[           ]]          --[[ ]]

--Calculate Agility
function getAgility()
    local AgiBase, AgiStat, AgiPos, AgiNeg = UnitStat("player",2)
    local Agi = AgiBase + AgiPos + AgiNeg
    return Agi
end

-- if getAllies("player",40) > 5 then
function getAllies(Unit,Radius)
	local alliesTable = {};
 	for i=1, #nNova do
		if not UnitIsDeadOrGhost(nNova[i].unit) then
			if getDistance(Unit,nNova[i].unit) <= Radius then
				tinsert(alliesTable,nNova[i].unit);
			end
		end
 	end
 	return alliesTable;
end

-- if getAlliesInLocation("player",X,Y,Z) > 5 then
function getAlliesInLocation(myX,myY,myZ,Radius)
	local alliesTable = {};
 	for i=1, #nNova do
		if not UnitIsDeadOrGhost(nNova[i].unit) then
			if getDistanceToObject(nNova[i].unit,myX,myY,myZ) <= Radius then
				tinsert(alliesTable,nNova[i].unit);
			end
		end
 	end
 	return alliesTable;
end

-- if getBuffDuration("target",12345) < 3 then
function getBuffDuration(Unit,BuffID,Source)
	if UnitBuffID(Unit,BuffID,Source) ~= nil then
		return select(6,UnitBuffID(Unit,BuffID,Source))*1;
	end
	return 0;
end

-- if getBuffRemain("target",12345) < 3 then
function getBuffRemain(Unit,BuffID,Source)
	if UnitBuffID(Unit,BuffID,Source) ~= nil then
		return (select(7,UnitBuffID(Unit,BuffID,Source)) - GetTime());
	end
	return 0;
end

-- if getBuffStacks(138756) > 0 then
function getBuffStacks(unit,BuffID,Source)
	if UnitBuffID(unit, BuffID,Source) then
		return (select(4, UnitBuffID(unit, BuffID,Source)))
	else
		return 0
	end
end

-- if getCharges(115399) > 0 then
function getCharges(spellID)
	return select(1, GetSpellCharges(spellID))
end

function getChi(Unit)
	return UnitPower(Unit,12)
end

function getChiMax(Unit)
	return UnitPowerMax(Unit,12)
end

-- if getCombatTime() <= 5 then
function getCombatTime()
	local combatStarted = BadBoy_data["Combat Started"];
	local combatTime = BadBoy_data["Combat Time"];
	if combatStarted == nil then return 0; end
	if combatTime == nil then combatTime = 0; end
	if UnitAffectingCombat("player") == true then
		combatTime = (GetTime() - combatStarted);
	else
		combatTime = 0;
	end
	BadBoy_data["Combat Time"] = combatTime;
	return (math.floor(combatTime*1000)/1000);
end

-- if getCreatureType(Unit) == true then
function getCreatureType(Unit)
	local CreatureTypeList = {"Critter", "Totem", "Non-combat Pet", "Wild Pet"}
	for i=1, #CreatureTypeList do
		if UnitCreatureType(Unit) == CreatureTypeList[i] then return false; end
	end
	if not UnitIsBattlePet(Unit) and not UnitIsWildBattlePet(Unit) then return true; else return false; end
end

-- if getCombo() >= 1 then
function getCombo()
	return GetComboPoints("player");
end

-- if getDebuffDuration("target",12345) < 3 then
function getDebuffDuration(Unit,DebuffID,Source)
	if UnitDebuffID(Unit,DebuffID,Source) ~= nil then
		return select(6,UnitDebuffID(Unit,DebuffID,Source))*1;
	end
	return 0;
end

-- if getDebuffRemain("target",12345) < 3 then
function getDebuffRemain(Unit,DebuffID,Source)
	if UnitDebuffID(Unit,DebuffID,Source) ~= nil then
		return (select(7,UnitDebuffID(Unit,DebuffID,Source)) - GetTime());
	end
	return 0;
end

-- if getDebuffStacks("target",138756) > 0 then
function getDebuffStacks(Unit,DebuffID,Source)
	if UnitDebuffID(Unit, DebuffID, Source) then
		return (select(4, UnitDebuffID(Unit, DebuffID, Source)));
	else
		return 0;
	end
end

-- if getDistance("player","target") <= 40 then
function getDistance(Unit1,Unit2)
	-- If both units are visible
	if UnitIsVisible(Unit1) == true and (Unit2 == nil or UnitIsVisible(Unit2) == true) then
		-- If Unit2 is nil we compare to Unit1
		if Unit2 == nil then
			if UnitCanAttack(Unit1,"player") == true then
				return rc:GetRange(Unit1) or 1000
			else
				local X1,Y1 = ObjectPosition(Unit1);
				local X2,Y2 = ObjectPosition("player");
				return math.sqrt(((X2-X1)^2)+((Y2-Y1)^2));
			end
		else
			if UnitCanAttack(Unit2,"player") == true then
				return rc:GetRange(Unit2) or 1000
			else
				local X1,Y1 = ObjectPosition(Unit1);
				local X2,Y2 = ObjectPosition(Unit2);
				return math.sqrt(((X2-X1)^2)+((Y2-Y1)^2));
			end
		end
	else
		return 1000;
	end
end

-- if getDistance("player","target") <= 40 then
function getDistanceToObject(Unit1,X2,Y2,Z2)
	if Unit1 == nil then Unit1 = "player"; end
	if UnitIsVisible(Unit1) then
		local X1,Y1 = ObjectPosition(Unit1);
		return math.sqrt(((X2-X1)^2)+((Y2-Y1)^2));
	else
		return 1000;
	end
end

-- /dump UnitGUID("target")
-- /dump getEnemies("target",10)
function getEnemies(Unit,Radius)

	local enemiesTable = {};

	if UnitExists("target") == true
	  and getCreatureType("target") == true
	  and UnitCanAttack("player","target") == true
	  and getDistance("player","target") <= Radius then
	    tinsert(enemiesTable,"target");
	end

 	for i=1,ObjectCount() do
 		if UnitExists(ObjectWithIndex(i)) == true and bit.band(ObjectType(ObjectWithIndex(i)), ObjectTypes.Unit) == 8 then
	  		local thisUnit = ObjectWithIndex(i);
	  		if UnitGUID(thisUnit) ~= UnitGUID("target") and getCreatureType(thisUnit) == true then
	  			if UnitCanAttack("player",thisUnit) == true and UnitIsDeadOrGhost(thisUnit) == false then
	  				if getDistance(Unit,thisUnit) <= Radius then
	   					tinsert(enemiesTable,thisUnit);
	   				end
	  			end
	  		end
	  	end
 	end
 	return enemiesTable;
end

-- use this to build enemiesTable
-- makeEnemiesTable()
function makeEnemiesTable(maxDistance)
	local  maxDistance = maxDistance or 50
	-- Throttle this 1 sec.
	if enemiesTable == nil or enemiesTableTimer == nil or enemiesTableTimer <= GetTime() - 1 then
		-- create/empty table
		enemiesTable = { };
		-- use objectmanager to build up table
	 	for i=1,ObjectCount() do
	 		if UnitExists(ObjectWithIndex(i)) and bit.band(ObjectType(ObjectWithIndex(i)), ObjectTypes.Unit) == 8 then
		  		local thisUnit = ObjectWithIndex(i);
		  		if UnitIsVisible(thisUnit) == true and getCreatureType(thisUnit) == true then
		  			if UnitCanAttack(thisUnit, "player") == true and UnitIsDeadOrGhost(thisUnit) == false then
		  				local unitDistance = getDistance("player",thisUnit)
		  				local X1, Y1, Z1 = ObjectPosition(thisUnit)

		  				if unitDistance <= maxDistance then
		  					local unitHP = getHP(thisUnit)
		  					-- insert unit as a sub-array holding unit informations
		   					tinsert(enemiesTable,{ unit = thisUnit, distance = unitDistance, hp = unitHP, x = X1, y = Y1, z = Z1 })
		   					--print("inserted")
		   				end
		  			end
		  		end
		  	end
	 	end

	 	-- sort them by range
	 	table.sort(enemiesTable, function(x,y)
	 		return x.distance < y.distance
	 	end)
	end
end

-- this function uses enemiesTable
function getNumEnemiesInRange(Unit, Radius)
	-- here i make sure it will work even if user dont enter values
	local Unit = Unit or "target"
	local minimumUnits = minimumUnits or 3
	local Radius = Radius or 10
	-- i make sure i do have enemiesTable loaded into memory
	if enemiesTable then
		-- here i set best units to their "worst" values. on each check that beat this value, i will update the bestTarget
		local foundTargets =  0

		-- since i want to iterate from a specific unit, i add its position to locals
		local X1, Y1, Z1 = ObjectPosition(Unit)

		-- then i start itreation of my array,
		for i = 1, #enemiesTable do
			-- i want to compare two units so i already store my 1st one into local mem
			local X2, Y2, Z2 = enemiesTable[i].x, enemiesTable[i].y, enemiesTable[i].z

			-- find range
			local unitDistance = math.sqrt(((X2-X1)^2)+((Y2-Y1)^2)+((Z2-Z1)^2))
			--print(unitDistance)
			-- see if i have at least minimum Units
			if unitDistance < Radius then
				foundTargets = foundTargets + 1
			end
		end
		-- i return number of units in range
		return foundTargets
	end
end


-- findTarget(10,true,1)   will find closest target in 10 yard front that have more or equal to 1%hp
function findTarget(range, facingCheck, minimumHealth)
	if enemiesTable ~= nil then
		for i = 1, #enemiesTable do
			if enemiesTable[i].distance <= range then
				if FacingCheck == false or getFacing("player", enemiesTable[i].unit) == true then
					if not minimumHealth or minimumHealth and minimumHealth >= enemiesTable[i].hp then
						TargetUnit(enemiesTable[i].unit)
					end
				end
			else
				break
			end
		end
	end
end

--if getFallTime() > 2 then
function getFallTime()
	if fallStarted==nil then fallStarted = 0 end
	if fallTime==nil then fallTime = 0 end
	if IsFalling() then
		if fallStarted == 0 then
			fallStarted = GetTime()
		end
		if fallStarted ~= 0 then
			fallTime = (math.floor((GetTime() - fallStarted)*1000)/1000);
		end
	end
	if not IsFalling() then
		fallStarted = 0
		fallTime = 0
	end
	return fallTime
end

-- if getFacing("target","player") == false then
function getFacing(Unit1,Unit2,Degrees)
	if Degrees == nil then Degrees = 90; end
	if Unit2 == nil then Unit2 = "player"; end
	if UnitIsVisible(Unit1) and UnitIsVisible(Unit2) then
		local Angle1,Angle2,Angle3;
		local Angle1 = ObjectFacing(Unit1)
		local Angle2 = ObjectFacing(Unit2)
		local Y1,X1,Z1 = ObjectPosition(Unit1);
        local Y2,X2,Z2 = ObjectPosition(Unit2);
	    if Y1 and X1 and Z1 and Angle1 and Y2 and X2 and Z2 and Angle2 then
	        local deltaY = Y2 - Y1
	        local deltaX = X2 - X1
	        Angle1 = math.deg(math.abs(Angle1-math.pi*2))
	        if deltaX > 0 then
	            Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2)+math.pi)
	        elseif deltaX <0 then
	            Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2))
	        end
	        if Angle2-Angle1 > 180 then
	        	Angle3 = math.abs(Angle2-Angle1-360)
	        else
	        	Angle3 = math.abs(Angle2-Angle1)
	        end
	        if Angle3 < Degrees then return true; else return false; end
	    end
	end
end

function getGUID(unit)
	local nShortHand = ""
	if UnitExists(unit) then
		if UnitIsPlayer(unit) then
			targetGUID = UnitGUID(unit)
			nShortHand = string.sub(UnitGUID(unit),-5)
  		else
		    targetGUID = string.match(UnitGUID(unit), "-(%d+)-%x+$")
  	        nShortHand = string.sub(UnitGUID(unit),-5)
		end
	end
	return targetGUID, nShortHand
end

-- if getHP("player") then
function getHP(Unit)
	if UnitIsDeadOrGhost(Unit) or not UnitIsVisible(Unit) then
		return 0;
	end
	for i = 1, #nNova do
		if nNova[i].guidsh == string.sub(UnitGUID(Unit),-5) then
			return nNova[i].hp;
		end
	end
	if isChecked("No Incoming Heals") ~= true and UnitGetIncomingHeals(Unit,"player") ~= nil then
		return 100*(UnitHealth(Unit)+UnitGetIncomingHeals(Unit,"player"))/UnitHealthMax(Unit)
	else
		return 100*UnitHealth(Unit)/UnitHealthMax(Unit)
	end
end

-- if getLowAllies(60) > 3 then
function getLowAllies(Value)
 	local lowAllies = 0;
 	for i = 1, #nNova do
  		if nNova[i].hp < Value then
   			lowAllies = lowAllies + 1
  		end
 	end
 	return lowAllies
end

-- if getMana("target") <= 15 then
function getMana(Unit)
	return 100 * UnitPower(Unit,0) / UnitPowerMax(Unit,0);
end

-- if getPower("target") <= 15 then
function getPower(Unit)
	local value = 100 * UnitPower(Unit) / UnitPowerMax(Unit)
	if _MyClass == 11 and UnitBuffID("player",106951) then value = value*2 end
	return value;
end

function getRecharge(spellID)
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
	if charges < maxCharges then
		chargeEnd = chargeStart + chargeDuration
		return chargeEnd - GetTime()
	else
		return 0
	end
end

--/dump TraceLine()
-- /dump getTotemDistance("target")
function getTotemDistance(Unit1)
	if Unit1 == nil then Unit1 = "player"; end
	if activeTotem ~= nil and UnitIsVisible(Unit1) then
		for i = 1, ObjectCount() do
            --print(UnitGUID(ObjectWithIndex(i)))
            if activeTotem == UnitGUID(ObjectWithIndex(i)) then
                X2, Y2, Z2 = ObjectPosition(ObjectWithIndex(i));
            end
		end
		local X1,Y1,Z1 = ObjectPosition(Unit1);

		TotemDistance = math.sqrt(((X2-X1)^2)+((Y2-Y1)^2)+((Z2-Z1)^2))

		--print(TotemDistance)
		return TotemDistance
	else
		return 1000;
	end
end

-- if getBossID("boss1") == 71734 then
function getBossID(BossUnitID)
	local UnitConvert = 0;
	if UnitIsVisible(BossUnitID) then
		UnitConvert = tonumber(string.match(UnitGUID(BossUnitID), "-(%d+)-%x+$"))
	end
	return UnitConvert;
end


function getUnitID(Unit)
	local UnitConvert = 0;
	if UnitIsVisible(BossUnitID) then
		UnitConvert = tonumber(strmatch(UnitGUID(Unit) or "", "-(%d+)-%x+$"), 10)
	end
	return UnitConvert;
end

-- if getNumEnemies("target",10) >= 3 then
function getNumEnemies(Unit,Radius)
  	local Units = 0;
 	for i=1,ObjectCount() do
		if UnitExists(ObjectWithIndex(i)) == true and bit.band(ObjectType(ObjectWithIndex(i)), ObjectTypes.Unit) == 8 then
	  		local thisUnit = ObjectWithIndex(i);
	  		if getCreatureType(thisUnit) == true then
	  			if UnitIsVisible(thisUnit) and UnitCanAttack("player",thisUnit) and not UnitIsDeadOrGhost(thisUnit) then
	  				if getDistance(Unit,thisUnit) <= Radius then
	  					Units = Units+1;
	   				end
		 		end
		 	end
		end
 	end
 	return Units;
end

-- if getLineOfSight("target"[,"target"]) then
function getLineOfSight(Unit1,Unit2)
	if Unit2 == nil then if Unit1 == "player" then Unit2 = "target"; else Unit2 = "player"; end end
	if UnitIsVisible(Unit1) and UnitIsVisible(Unit2) then
		local X1,Y1,Z1 = ObjectPosition(Unit1);
		local X2,Y2,Z2 = ObjectPosition(Unit2);
		if TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10) == nil then return true; else return false; end
	else
		return true;
	end
end

-- if getGround("target"[,"target"]) then
function getGround(Unit)
	if UnitIsVisible(Unit) then
		local X1,Y1,Z1 = ObjectPosition(Unit);
		if TraceLine(X1,Y1,Z1+2,X1,Y1,Z1-2, 0x10) == nil and TraceLine(X1,Y1,Z1+2,X1,Y1,Z1-4, 0x100) == nil then return nil; else return true; end
	end
end

-- if getPetLineOfSight("target"[,"target"]) then
function getPetLineOfSight(Unit)
	if UnitIsVisible("pet") and UnitIsVisible(Unit) then
		local X1,Y1,Z1 = ObjectPosition("pet");
		local X2,Y2,Z2 = ObjectPosition(Unit);
		if TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10) == nil then return true; else return false; end
	else return true;
	end
end

-- if getSpellCD(12345) <= 0.4 then
function getSpellCD(SpellID)
	if GetSpellCooldown(SpellID) == 0 then
		return 0
	else
		local Start ,CD = GetSpellCooldown(SpellID);
		local MyCD = Start + CD - GetTime();
		if isChecked("Latency Compensation") then
			MyCD = MyCD - getLatency()
		end
		return MyCD;
	end
end

--- Round
function round2(num, idp)
  mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- if getTalent(8) == true then
function getTalent(Row,Column)
	return select(4, GetTalentInfo(Row,Column,GetActiveSpecGroup())) or false
end

-- if getTimeToDie("target") >= 6 then
function getTimeToDie(unit)
	unit = unit or "target";
	if thpcurr == nil then thpcurr = 0; end
	if thpstart == nil then thpstart = 0; end
	if timestart == nil then timestart = 0; end
	if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
		if currtar ~= UnitGUID(unit) then
			priortar = currtar;
			currtar = UnitGUID(unit);
		end
		if thpstart == 0 and timestart == 0 then
			thpstart = UnitHealth(unit);
			timestart = GetTime();
		else
			thpcurr = UnitHealth(unit);
			timecurr = GetTime();
			if thpcurr >= thpstart then
				thpstart = thpcurr;
				timeToDie = 999;
			else
				if ((timecurr - timestart)==0) or ((thpstart - thpcurr)==0) then
					timeToDie = 999;
				else
					timeToDie = round2(thpcurr/((thpstart - thpcurr) / (timecurr - timestart)),2);
				end
			end
		end
	elseif not UnitIsVisible(unit) or currtar ~= UnitGUID(unit) then
		currtar = 0;
		priortar = 0;
		thpstart = 0;
		timestart = 0;
		timeToDie = 0;
	end
	if timeToDie==nil then
		return 999
	else
		return timeToDie
	end
end

-- if getTimeToMax("player") < 3 then
function getTimeToMax(Unit)
  	local max = UnitPowerMax(Unit);
  	local curr = UnitPower(Unit);
  	local regen = select(2, GetPowerRegen(Unit));
  	if select(3, UnitClass("player")) == 11 and GetSpecialization() == 2 and isKnown(114107) then
   		curr2 = curr + 4*getCombo()
  	else
   		curr2 = curr
  	end
  	return (max - curr2) * (1.0 / regen);
end

-- if getRegen("player") > 15 then
function getRegen(Unit)
	local regen = select(2, GetPowerRegen(Unit));
	return 1.0 / regen;
end

-- if getVengeance() >= 50000 then
function getVengeance()
	local VengeanceID = 0
	if select(3,UnitClass("player")) == 1 then VengeanceID = 93098 -- Warrior
	elseif select(3,UnitClass("player")) == 2 then VengeanceID = 84839 -- Paladin
	elseif select(3,UnitClass("player")) == 6 then VengeanceID = 93099 -- DK
	elseif select(3,UnitClass("player")) == 10 then VengeanceID = 120267 -- Monk
	elseif select(3,UnitClass("player")) == 11 then VengeanceID = 84840 -- Druid
	end
	if UnitBuff("player",VengeanceID) then
		return select(15,UnitAura("player", GetSpellInfo(VengeanceID)))
	end
	return 0
end

--[[]]	   --[[]]		  --[[]]		--[[           ]]
--[[]]	   --[[]]		 --[[  ]]		--[[           ]]
--[[           ]]	    --[[    ]]		--[[ ]]
--[[           ]]	   --[[      ]] 	--[[           ]]
--[[           ]]	  --[[        ]]			  --[[ ]]
--[[]]	   --[[]]	 --[[]]    --[[]]	--[[           ]]
--[[]]	   --[[]]	--[[]]      --[[]]	--[[           ]]

-- if hasGlyph(1234) == true then
function hasGlyph(glyphid)
 	for i=1, 6 do
  		if select(4, GetGlyphSocketInfo(i)) == glyphid or select(6, GetGlyphSocketInfo(i)) == glyphid then return true; end
 	end
 	return false;
end

-- if hasNoControl(12345) == true then
function hasNoControl(spellID)
	local eventIndex = C_LossOfControl.GetNumEvents()
	while (eventIndex > 0) do
		local _, _, text = C_LossOfControl.GetEventInfo(eventIndex)
	-- Warrior
		if select(3, UnitClass("player")) == 1 then

		end
	-- Paladin
		if select(3, UnitClass("player")) == 2 then

		end
	-- Hunter
		if select(3, UnitClass("player")) == 3 then
			if text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_SNARE then
				return true
			end
		end
	-- Rogue
		if select(3, UnitClass("player")) == 4 then

		end
	-- Priest
		if select(3, UnitClass("player")) == 5 then

		end
	-- Death Knight
		if select(3, UnitClass("player")) == 6 then

		end
	-- Shaman
		if select(3, UnitClass("player")) == 7 then
			if spellID == 8143 --Tremor Totem
				and	(text == LOSS_OF_CONTROL_DISPLAY_STUN
					or text == LOSS_OF_CONTROL_DISPLAY_FEAR
					or text == LOSS_OF_CONTROL_DISPLAY_SLEEP)
			then
				return true
			end
			if spellID == 108273 --Windwalk Totem
				and (text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_SNARE)
			then
				return true
			end
		end
	-- Mage
		if select(3, UnitClass("player")) == 8 then

		end
	-- Warlock
		if select(3, UnitClass("player")) == 9 then

		end
	-- Monk
		if select(3, UnitClass("player")) == 10 then
			if text == LOSS_OF_CONTROL_DISPLAY_STUN or text == LOSS_OF_CONTROL_DISPLAY_FEAR or text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_HORROR then
				return true
			end
		end
	-- Druid
		if select(3, UnitClass("player")) == 11 then
			if text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_SNARE then
				return true
			end
		end
		eventIndex = eventIndex - 1
	end
	return false
end

--[[           ]]	--[[           ]]
--[[           ]]	--[[           ]]
	 --[[ ]]		--[[ ]]
	 --[[ ]]		--[[           ]]
	 --[[ ]]				  --[[ ]]
--[[           ]]	--[[           ]]
--[[           ]]	--[[           ]]

-- if isAlive([Unit]) == true then
function isAlive(Unit)
	local Unit = Unit or "target";
	if UnitIsDeadOrGhost(Unit) == false then
		return true;
	else
		return false;
	end
end

-- isBoss()
function isBoss()
	------Boss Check------
	for x=1,5 do
	    if UnitExists("boss1") then
	        boss1 = tonumber(string.match(UnitGUID("boss1"), "-(%d+)-%x+$"))
	    else
	        boss1 = 0
	    end
	    if UnitExists("boss2") then
	        boss2 = tonumber(string.match(UnitGUID("boss2"), "-(%d+)-%x+$"))
	    else
	        boss2 = 0
	    end
	    if UnitExists("boss3") then
	        boss3 = tonumber(string.match(UnitGUID("boss3"), "-(%d+)-%x+$"))
	    else
	        boss3 = 0
	    end
	    if UnitExists("boss4") then
	        boss4 = tonumber(string.match(UnitGUID("boss4"), "-(%d+)-%x+$"))
	    else
	        boss4 = 0
	    end
	    if UnitExists("boss5") then
	        boss5 = tonumber(string.match(UnitGUID("boss5"), "-(%d+)-%x+$"))
	    else
	        boss5 = 0
	    end
	end
	BossUnits = {
	    -- Cataclysm Dungeons --
	    -- Abyssal Maw: Throne of the Tides
	    40586,      -- Lady Naz'jar
	    40765,      -- Commander Ulthok
	    40825,      -- Erunak Stonespeaker
	    40788,      -- Mindbender Ghur'sha
	    42172,      -- Ozumat
	    -- Blackrock Caverns
	    39665,      -- Rom'ogg Bonecrusher
	    39679,      -- Corla, Herald of Twilight
	    39698,      -- Karsh Steelbender
	    39700,      -- Beauty
	    39705,      -- Ascendant Lord Obsidius
	    -- The Stonecore
	    43438,      -- Corborus
	    43214,      -- Slabhide
	    42188,      -- Ozruk
	    42333,      -- High Priestess Azil
	    -- The Vortex Pinnacle
	    43878,      -- Grand Vizier Ertan
	    43873,      -- Altairus
	    43875,      -- Asaad
	    -- Grim Batol
	    39625,      -- General Umbriss
	    40177,      -- Forgemaster Throngus
	    40319,      -- Drahga Shadowburner
	    40484,      -- Erudax
	    -- Halls of Origination
	    39425,      -- Temple Guardian Anhuur
	    39428,      -- Earthrager Ptah
	    39788,      -- Anraphet
	    39587,      -- Isiset
	    39731,      -- Ammunae
	    39732,      -- Setesh
	    39378,      -- Rajh
	    -- Lost City of the Tol'vir
	    44577,      -- General Husam
	    43612,      -- High Prophet Barim
	    43614,      -- Lockmaw
	    49045,      -- Augh
	    44819,      -- Siamat
	    -- Zul'Aman
	    23574,      -- Akil'zon
	    23576,      -- Nalorakk
	    23578,      -- Jan'alai
	    23577,      -- Halazzi
	    24239,      -- Hex Lord Malacrass
	    23863,      -- Daakara
	    -- Zul'Gurub
	    52155,      -- High Priest Venoxis
	    52151,      -- Bloodlord Mandokir
	    52271,      -- Edge of Madness
	    52059,      -- High Priestess Kilnara
	    52053,      -- Zanzil
	    52148,      -- Jin'do the Godbreaker
	    -- End Time
	    54431,      -- Echo of Baine
	    54445,      -- Echo of Jaina
	    54123,      -- Echo of Sylvanas
	    54544,      -- Echo of Tyrande
	    54432,      -- Murozond
	    -- Hour of Twilight
	    54590,      -- Arcurion
	    54968,      -- Asira Dawnslayer
	    54938,      -- Archbishop Benedictus
	    -- Well of Eternity
	    55085,      -- Peroth'arn
	    54853,      -- Queen Azshara
	    54969,      -- Mannoroth
	    55419,      -- Captain Varo'then

	    -- Mists of Pandaria Dungeons --
	    -- Scarlet Halls
	    59303,      -- Houndmaster Braun
	    58632,      -- Armsmaster Harlan
	    59150,      -- Flameweaver Koegler
	    -- Scarlet Monastery
	    59789,      -- Thalnos the Soulrender
	    59223,      -- Brother Korloff
	    3977,       -- High Inquisitor Whitemane
	    60040,      -- Commander Durand
	    -- Scholomance
	    58633,      -- Instructor Chillheart
	    59184,      -- Jandice Barov
	    59153,      -- Rattlegore
	    58722,      -- Lilian Voss
	    58791,      -- Lilian's Soul
	    59080,      -- Darkmaster Gandling
	    -- Stormstout Brewery
	    56637,      -- Ook-Ook
	    56717,      -- Hoptallus
	    59479,      -- Yan-Zhu the Uncasked
	    -- Tempe of the Jade Serpent
	    56448,      -- Wise Mari
	    56843,      -- Lorewalker Stonestep
	    59051,      -- Strife
	    59726,      -- Peril
	    58826,      -- Zao Sunseeker
	    56732,      -- Liu Flameheart
	    56762,      -- Yu'lon
	    56439,      -- Sha of Doubt
	    -- Mogu'shan Palace
	    61444,      -- Ming the Cunning
	    61442,      -- Kuai the Brute
	    61445,      -- Haiyan the Unstoppable
	    61243,      -- Gekkan
	    61398,      -- Xin the Weaponmaster
	    -- Shado-Pan Monastery
	    56747,      -- Gu Cloudstrike
	    56541,      -- Master Snowdrift
	    56719,      -- Sha of Violence
	    56884,      -- Taran Zhu
	    -- Gate of the Setting Sun
	    56906,      -- Saboteur Kip'tilak
	    56589,      -- Striker Ga'dok
	    56636,      -- Commander Ri'mok
	    56877,      -- Raigonn
	    -- Siege of Niuzao Temple
	    61567,      -- Vizier Jin'bak
	    61634,      -- Commander Vo'jak
	    61485,      -- General Pa'valak
	    62205,      -- Wing Leader Ner'onok

	    -- Training Dummies --
	    46647,      -- Level 85 Training Dummy
	    67127,      -- Level 90 Training Dummy

	    -- Instance Bosses --
	    boss1,  --Boss 1
	    boss2,  --Boss 2
	    boss3,  --Boss 3
	    boss4,  --Boss 4
	    boss5,  --Boss 5
	}
    local BossUnits = BossUnits

    if UnitExists("target") then
        local npcID = tonumber(string.match(UnitGUID("target"), "-(%d+)-%x+$"))--tonumber(UnitGUID("target"):sub(6,10), 16)

        if (UnitClassification("target") == "rare" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "worldboss" or (UnitClassification("target") == "elite" and UnitLevel("target") >= UnitLevel("player")+3) or UnitLevel("target") < 0)
            --and select(2,IsInInstance())=="none"
            and not UnitIsTrivial("target")
        then
            return true
        else
            for i=1,#BossUnits do
                if BossUnits[i] == npcID then
                    return true
                end
            end
            return false
        end
    else
        return false
    end
end

--- if isBuffed()
function isBuffed(UnitID,SpellID,TimeLeft,Filter)
  	if not TimeLeft then TimeLeft = 0 end
  	if type(SpellID) == "number" then SpellID = { SpellID } end
	for i=1,#SpellID do
		local spell, rank = GetSpellInfo(SpellID[i])
		if spell then
			local buff = select(7,UnitBuff(UnitID,spell,rank,Filter))
			if buff and ( buff == 0 or buff - GetTime() > TimeLeft ) then return true; end
		end
	end
end

function isCastingTime(lagTolerance)
	local lagTolerance = 0;
	if UnitCastingInfo("player") ~= nil then
		if select(6,UnitCastingInfo("player")) - GetTime() <= lagTolerance then
			return true;
		end
	elseif UnitChannelInfo("player") ~= nil then
		if select(6,UnitChannelInfo("player")) - GetTime() <= lagTolerance then
			return true;
		end
	elseif (GetSpellCooldown(GetSpellInfo(61304)) ~= nil and GetSpellCooldown(GetSpellInfo(61304)) <= lagTolerance) then
	  	return true;
	else
		return false;
	end
end

-- if isCasting() == true then
function castingUnit(Unit)
	if Unit == nil then Unit = "player" end
	if UnitCastingInfo(Unit) ~= nil
	  or UnitChannelInfo(Unit) ~= nil
	  or (GetSpellCooldown(61304) ~= nil and GetSpellCooldown(61304) > 0.001) then
	  	return true;
	end
end

-- if isCastingSpell(12345) == true then
function isCastingSpell(spellID)
	local spellName = GetSpellInfo(spellID)
	local spellCasting = UnitCastingInfo("player")

	if spellCasting == nil then
		spellCasting = UnitChannelInfo("player")
	end
	if spellCasting == spellName then
		return true
	else
		return false
	end
end

-- UnitGUID("target"):sub(-15, -10)
-- Dummy Check
function isDummy(Unit)
	if Unit == nil then Unit = "target"; else Unit = tostring(Unit) end
    dummies = {
        87329, --Raider's Training Dummy - Lvl ?? (Stormshield - Tank)
        88837, --Raider's Training Dummy - Lvl ?? (Warspear - Tank)
        87320, --Raider's Training Dummy - Lvl ?? (Stormshield - Damage)
		87762, --Raider's Training Dummy - Lvl ?? (Warspear - Damage)
        31146, --Raider's Training Dummy - Lvl ?? (Ogrimmar, Stormwind, Darnassus, ...)
        70245, --Training Dummy - Lvl ?? (Throne of Thunder)
        88314, --Dungeoneer's Training Dummy - Lvl 102 (Lunarfall - Tank)
        88288, --Dungeoneer's Training Dummy - Lvl 102 (Frostwall - Tank)
        88836, --Dungeoneer's Training Dummy - Lvl 102 (Warspear - Tank)
        87322, --Dungeoneer's Training Dummy - Lvl 102 (Stormshield, Warspear - Tank)
    	87317, --Dungeoneer's Training Dummy - Lvl 102 (Lunarfall - Damage)
    	87318, --Dungeoneer's Training Dummy - Lvl 102 (Lunarfall - Damage)
    	87761, --Dungeoneer's Training Dummy - Lvl 102 (Frostwall - Damage)
    	88906, --Combat Dummy - Lvl 100 (Nagrand)
    	89078, --Training Dummy - Lvl 100 (Lunarfall, Frostwall)
    	87321, --Training Dummy - Lvl 100 (Stormshield, Warspear - Healing)
    	88835, --Training Dummy - Lvl 100 (Warspear - Healing)
    	88967, --Training Dummy - Lvl 100 (Lunarfall, Frostwall)
    	88316, --Training Dummy - Lvl 100 (Lunarfall - Healing)
    	88289, --Training Dummy - Lvl 100 (Frostwall - Healing)
    	79414, --Training Dummy - Lvl 95 (Talador)
        67127, --Training Dummy - Lvl 90 (Vale of Eternal Blossoms)
        46647, --Training Dummy - Lvl 85 (Orgrimmar, Stormwind)
        32546, --Ebon Knight's Training Dummy - Lvl 80 (Eastern Plaguelands)
        31144, --Training Dummy - Lvl 80 (Orgrimmar, Darnassus, Ruins of Gileas, ...)
        32543, --Veteran's Training Dummy - Lvl 75 (Eastern Plaguelands)
        32667, --Training Dummy - Lvl 70 (Darnassus, Silvermoon, Orgrimar, ...)
        32542, --Disciple's Training Dummy - Lvl 65 (Eastern Plaguelands)
        32666, --Training Dummy - Lvl 60 (Orgrimmar, Ironforge, Darnassus, ...)
        32541, --Initiate's Training Dummy - Lvl 55 (Scarlet Enclave)
        32545, --Initiate's Training Dummy - Lvl 55 (Eastern Plaguelands)
        60197, --Scarlet Monastery Dummy
        64446, --Scarlet Monastery Dummy
    }
    for i=1, #dummies do
        if UnitExists(Unit) and UnitGUID(Unit) then
            dummyID = tonumber(string.match(UnitGUID(Unit), "-(%d+)-%x+$"))
        else
            dummyID = 0
        end
        if dummyID == dummies[i] then
            return true
        end
    end
end

function isDummyByName(unitName)
	if Unit == nil then Unit = UnitName("target"); else Unit = tostring(Unit) end
    dummies = {
        "Training Dummy", -- 31144 - Lvl 80
        --"Raider's Training Dummy", -- 31146 - Lvl ??
        "Initiate's Training Dummy", -- 32541 - Lvl 55 (Scarlet Enclave)
        "Disciple's Training Dummy", -- 32542 - Lvl 65
        "Initiate's Training Dummy", -- 32545 - Lvl 55
        "Ebon Knight's Training Dummy",  -- 32546 - Lvl 80
        "Training Dummy", -- 32666 - Lvl 60
        "Training Dummy", -- 32667 - Lvl 70
        "Training Dummy", -- 46647 - Lvl 85
        "Scarlet Monastery Dummy", -- 60197 -- Lvl 1
        "Training Dummy" -- 67127 - Lvl 90
    }
    for i=1, #dummies do
        if dummies[i] == unitName then
        	return true;
        end
    end
end

-- if isEnnemy([Unit])
function isEnnemy(Unit)
	local Unit = Unit or "target";
	if UnitCanAttack(Unit,"player") then
		return true;
	else
		return false;
	end
end

--if isGarrMCd() then
function isGarrMCd(Unit)
	if Unit == nil then Unit = "target"; end
	if UnitExists(Unit)
	  and (UnitDebuffID(Unit,145832)
      or UnitDebuffID(Unit,145171)
      or UnitDebuffID(Unit,145065)
      or UnitDebuffID(Unit,145071)) then
		return true;
	else
		return false;
	end
end

-- if isInCombat("target") then
function isInCombat(Unit)
	if UnitAffectingCombat(Unit) then return true; else return false; end
end

-- if isInDraenor() then
function isInDraenor()
	local tContains = tContains
	local currentMapID = GetCurrentMapAreaID();
	local draenorMapIDs =
	{
	    962, -- Draenor
	    978, -- Ashran
	    941, -- Frostfire Ridge
	    976, -- Frostwall
	    949, -- Gorgrond
	    971, -- Lunarfall
	    950, -- Nagrand
	    947, -- Shadowmoon Valley
	    948, -- Spires of Arak
	    1009, -- Stormshield
	    946, -- Talador
	    945, -- Tanaan Jungle
	    970, -- Tanaan Jungle - Assault on the Dark Portal
	    1011, -- Warspear
	}
	if (tContains(draenorMapIDs, currentMapID)) then
		return true
	else
		return false
	end
end

-- if isInMelee() then
function isInMelee(Unit)
	if Unit == nil then Unit = "target"; end
	if getDistance(Unit) < 4 then return true; else return false; end
end

-- if IsInPvP() then
function isInPvP()
	local inpvp = GetPVPTimer()
	if inpvp ~= 301000 and inpvp ~= -1 then
		return true;
	else
		return false;
	end
end

-- if isKnown(106832) then
function isKnown(spellID)
  	local spellName = GetSpellInfo(spellID)
	if GetSpellBookItemInfo(tostring(spellName)) ~= nil then
    	return true;
  	end
	if IsPlayerSpell(tonumber(spellID)) == true then
		return true
	end
  	return false;
end

-- if isLooting() then
function isLooting()
	if GetNumLootItems() > 0 then
		return true;
	else
		return false;
	end
end

-- if not isMoving("target") then
function isMoving(Unit)
	if GetUnitSpeed(Unit) > 0 then return true; else return false; end
end

-- if IsMovingTime(5) then
function IsMovingTime(time)
	if time == nil then time = 1 end
	if GetUnitSpeed("player") > 0 then
		if IsRunning == nil then
			IsRunning = GetTime();
			IsStanding = nil;
		end
		if GetTime() - IsRunning > time then
			return true;
		end
	else
		if IsStanding == nil then
			IsStanding = GetTime();
			IsRunning = nil;
		end
		if GetTime() - IsStanding > time then
			return false;
		end
	end
end

function isPlayer(Unit)
	if UnitExists(Unit) ~= true then return false; end
	if UnitIsPlayer(Unit) == true then
		return true;
	elseif UnitIsPlayer(Unit) ~= true then
		local playerNPC = {
			[72218] = "Oto the Protector",
			[72219] = "Ki the Asssassin",
			[72220] = "Sooli the Survivalist",
			[72221] = "Kavan the Arcanist",
		}
		if playerNPC[tonumber(string.match(UnitGUID(Unit), "-(%d+)-%x+$"))] ~= nil then
			return true;
		end
	else
		return false;
	end
end

function getStandingTime()
	return DontMoveStartTime and GetTime() - DontMoveStartTime or nil;
end

--
function isStanding(Seconds)
	return IsFalling() == false and DontMoveStartTime and getStandingTime() >= Seconds or false;
end

-- if IsStandingTime(5) then
function IsStandingTime(time)
	if time == nil then time = 1 end
	if not IsFalling() and GetUnitSpeed("player") == 0 then
		if IsStanding == nil then
			IsStanding = GetTime();
			IsRunning = nil;
		end
		if GetTime() - IsStanding > time then
			return true;
		end
	else
		if IsRunning == nil then
			IsRunning = GetTime();
			IsStanding = nil;
		end
		if GetTime() - IsRunning > time then
			return false;
		end
	end
end

-- if isCasting(12345,"target") then
function isCasting(SpellID,Unit)
	if UnitExists(Unit) and UnitIsVisible(Unit) then
		if isCasting(tostring(GetSpellInfo(SpellID)),Unit) == 1 then return true; end
	else
		return false;
	end
end

-- if isValidTarget("target") then
function isValidTarget(Unit)
	if UnitIsEnemy("player",Unit) then
		if UnitExists(Unit) and not UnitIsDeadOrGhost(Unit) then return true; else return false; end
	else
		if UnitExists(Unit) then return true; else return false; end
	end
end

-- Adaptation of Xelper(PQR)'s Interrupt
function Interrupts()
	if BadBoy_data["Check Interrupts"] ~= true then return false; end
	local _MyInterruptValue = BadBoy_data["Box Interrupts"];
	if RandomInterrupt == nil then RandomInterrupt = math.random(45,75); end
	function InterruptSpell()
		local MyClass = UnitClass("player");
		--Warrior
		if MyClass == 1 and GetSpellInfo(6552) ~= nil and getSpellCD(6552) == 0 then return 6552;
		-- Paladin
		elseif MyClass == 2 and GetSpellInfo(96231) ~= nil and getSpellCD(96231) == 0 then return 96231;
		-- Hunter
		elseif MyClass == 3 and GetSpellInfo(147362) ~= nil and getSpellCD(147362) == 0 then return 147362;
		-- Rogue
		elseif MyClass == 4 and GetSpellInfo(1766) ~= nil and getSpellCD(1766) == 0 then return 1766;
		-- Priest
		elseif MyClass == 5 and GetSpecialization("player") == 3 and GetSpellInfo(15487) ~= nil and getSpellCD(15487) == 0 then return 15487;
		-- DeathKnight
		elseif MyClass == 6 and GetSpellInfo(80965) ~= nil and getSpellCD(80965) == 0 then return 47528;
		-- Shaman
		elseif MyClass == 7 and GetSpellInfo(57994) ~= nil and getSpellCD(57994) == 0 then return 57994;
		-- Mage
		elseif MyClass == 8 and GetSpellInfo(2139) ~= nil and getSpellCD(2139) == 0 then return 2139;
		-- Warlock
		elseif MyClass == 9 and IsSpellKnown(19647) ~= nil and getSpellCD(19647) == 0 then return 19647;
		-- Monk
		elseif MyClass == 10 and GetSpellInfo(116705) ~= nil and getSpellCD(116705) == 0 then return 116705;
		-- Druid
		elseif MyClass == 11 and UnitBuffID("player", 768) ~= nil and IsPlayerSpell(80965) ~= nil and getSpellCD(80965) == 0 then return 80965;
		elseif MyClass == 11 and UnitBuffID("player", 5487) ~= nil and IsPlayerSpell(80964) ~= nil and getSpellCD(80964) == 0 then return 80964;
		elseif MyClass == 11 and GetSpecialization("player") == 1 then return 78675;
		else return 0; end
	end
	local interruptSpell = InterruptSpell();
	local interruptName = GetSpellInfo(interruptSpell);
	-- Interrupt Casts and Channels on Target and Focus.
	if interruptSpell ~= 0 then
		if UnitExists("target") == 1 then
			local customTarget = "target";
			local castName, _, _, _, castStartTime, castEndTime, _, _, castInterruptable = UnitCastingInfo(customTarget);
			local channelName, _, _, _, channelStartTime, channelEndTime, _, channelInterruptable = UnitChannelInfo(customTarget);
			if channelName ~= nil then
				--target is channeling a spell that is interruptable
				--load the channel variables into the cast variables to make logic a little easier.
				castName = channelName;
				castStartTime = channelStartTime;
				castEndTime = channelEndTime;
				castInterruptable = channelInterruptable;
				PQR_InterruptPercent = 0;
				IsChannel = true;
			end
			if castInterruptable == false then castInterruptable = true; else castInterruptable = false; end
			if castInterruptable then
			  	local timeSinceStart = (GetTime() * 1000 - castStartTime) / 1000;
				local timeLeft = ((GetTime() * 1000 - castEndTime) * -1) / 1000;
				local castTime = castEndTime - castStartTime;
				local currentPercent = timeSinceStart / castTime * 100000;
			  	if IsSpellInRange(GetSpellInfo(interruptSpell), customTarget) == 1
			  	  and UnitCanAttack("player", customTarget) ~= nil then
					if currentPercent and RandomInterrupt and currentPercent < RandomInterrupt and not IsChannel then return false; end
					ChatOverlay("INTERRUPT");
					InteruptTimer = GetTime();
					RandomInterrupt = nil;
				end
			end
		end
	end
end

-- Dem Bleeds
-- In a run once environment we shall create the Tooltip that we will be reading
-- all of the spell details from
nGTT = CreateFrame( "GameTooltip", "MyScanningTooltip", nil, "GameTooltipTemplate" );
nGTT:SetOwner( WorldFrame, "ANCHOR_NONE" );
nGTT:AddFontStrings(nGTT:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),nGTT:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ) );
function nDbDmg(tar, spellID, player)
   	if GetCVar("DotDamage") == nil then
      	RegisterCVar("DotDamage", 0);
   	end
   	nGTT:ClearLines()
   	for i=1, 40 do
      	if UnitDebuff(tar, i, player) == GetSpellInfo(spellID) then
         	nGTT:SetUnitDebuff(tar, i, player);
         	scanText=_G["MyScanningTooltipTextLeft2"]:GetText();
         	local DoTDamage = scanText:match("([0-9]+%.?[0-9]*)");
   			--if not issecure() then print(issecure()); end -- function is called inside the profile
         	SetCVar("DotDamage", tonumber(DoTDamage));
         	return tonumber(GetCVar("DotDamage"));
      	end
   	end
end

-- if pause() then
function pause() --Pause
	if (IsLeftAltKeyDown() and GetCurrentKeyBoardFocus() == nil)
      or (IsMounted() and ((getUnitID("target") ~= 56877) or (not UnitBuffID("player",164222)) or (not UnitBuffID("player",165803))))
		or SpellIsTargeting()
		or (not UnitCanAttack("player", "target") and not UnitIsPlayer("target") and UnitExists("target"))
		or UnitCastingInfo("player")
		or UnitChannelInfo("player")
		or UnitIsDeadOrGhost("player")
		or (UnitIsDeadOrGhost("target") and not UnitIsPlayer("target"))
		or UnitBuffID("player",80169) -- Eating
		or UnitBuffID("player",87959) -- Drinking
		or UnitBuffID("target",117961) --Impervious Shield - Qiang the Merciless
		or UnitDebuffID("player",135147) --Dead Zone - Iron Qon: Dam'ren
		or (((UnitHealth("target")/UnitHealthMax("target"))*100) > 10 and UnitBuffID("target",143593)) --Defensive Stance - General Nagrazim
		or UnitBuffID("target",140296) --Conductive Shield - Thunder Lord / Lightning Guardian
	then
		return true;
	else
		return false;
	end
end

-- useItem(12345)
function useItem(itemID)
	if GetItemCount(itemID,false,false) > 0 then
		if select(2,GetItemCooldown(itemID))==0 then
			RunMacroText("/use "..tostring(select(1,GetItemInfo(itemId))));
		end
	end
end

-- if shouldStopCasting(12345) then
function shouldStopCasting(Spell)
	-- if we are on a boss fight
	if UnitExists("boss1") then
		-- Locally  casting informations
		local Boss1Cast, Boss1CastEnd, PlayerCastEnd, StopCasting = Boss1Cast, Boss1CastEnd, PlayerCastEnd, false
		local MySpellCastTime;
		-- Set Spell Cast Time
		if GetSpellInfo(Spell) ~= nil then
			MySpellCastTime = (GetTime()*1000) + select(4,GetSpellInfo(Spell));
		else
			return false;
		end
		-- Spells wich make us immune (buff)
		local ShouldContinue = {
			1022, -- Hand of Protection
			31821, -- Devotion
			104773, -- Unending Resolve
		}
		-- Spells that are dangerous (boss cast)
		local ShouldStop = {
			137457, -- Piercing Roar(Oondasta)
			138763, -- Interrupting Jolt(Dark Animus)
			143343, -- Deafening Screech(Thok)
		}

		if UnitCastingInfo("boss1") then Boss1Cast,_,_,_,_,Boss1CastEnd = UnitCastingInfo("boss1") elseif UnitChannelInfo("boss1") then Boss1Cast,_,_,_,_,Boss1CastEnd = UnitChannelInfo("boss1") else return false; end
		if UnitCastingInfo("player") then PlayerCastEnd = select(6,UnitCastingInfo("player")) elseif UnitChannelInfo("player") then PlayerCastEnd = select(6,UnitChannelInfo("player")) else PlayerCastEnd = MySpellCastTime; end
		for i = 1, #ShouldContinue do
			if UnitBuffID("player", ShouldContinue[i]) and (select(7,UnitBuffID("player", ShouldContinue[i]))*1000)+50 > Boss1CastEnd then ChatOverlay("\124cFFFFFFFFStopper Safety Found") return false; end
		end
		if not UnitCastingInfo("player") and not UnitChannelInfo("player") and MySpellCastTime and SetStopTime and MySpellCastTime > Boss1CastEnd then ChatOverlay("\124cFFD93B3BStop for "..Boss1Cast) return true; end

		for j = 1, #ShouldStop do
			if Boss1Cast == select(1,GetSpellInfo(ShouldStop[j])) then
				SetStopTime = Boss1CastEnd
				if PlayerCastEnd ~= nil then
					if Boss1CastEnd < PlayerCastEnd then
						StopCasting = true;
					end
				end
			end
		end
		return StopCasting
	end
end

function spellDebug(Message)
	if imDebugging == true and isChecked("Debugging Mode") then
		ChatOverlay(Message)
	end
end

--[[           ]]	--[[           ]]	--[[           ]]
--[[           ]]	--[[           ]]	--[[           ]]
--[[]]				--[[]]				--[[]]
--[[]]				--[[           ]] 	--[[]]	 --[[  ]]
--[[]]				--[[		   ]]	--[[]]     --[[]]
--[[           ]]	--[[]]				--[[           ]]
--[[           ]]	--[[]]      		--[[           ]]

-- if isChecked("Debug") then
function isChecked(Value)
	if BadBoy_data["Check "..Value] == 1 then return true; else return false end
end

-- if isSelected("Stormlash Totem") then
function isSelected(Value)
	if BadBoy_data["Cooldowns"] == 3 or (BadBoy_data["Check "..Value] == 1 and (BadBoy_data["Drop "..Value] == 3 or (BadBoy_data["Drop "..Value] == 2 and BadBoy_data["Cooldowns"] == 2))) then return true; else return false; end
end

-- if getHP("player") <= getValue("Eternal Flame") then
function getValue(Value)
	if BadBoy_data["Drop "..Value] ~= nil then
		return BadBoy_data["Drop "..Value];
	elseif BadBoy_data["Box "..Value] ~= nil then
		return BadBoy_data["Box "..Value];
	else
		return 0;
	end
end

--[[Taunts Table!! load once]]
tauntsTable = {
	{ spell = 143436, stacks = 1 }, --Immerseus/71543               143436 - Corrosive Blast                             == 1x
	{ spell = 146124, stacks = 3 }, --Norushen/72276                146124 - Self Doubt                                  >= 3x
	{ spell = 144358, stacks = 1 }, --Sha of Pride/71734            144358 - Wounded Pride                               == 1x
	{ spell = 147029, stacks = 3 }, --Galakras/72249                147029 - Flames of Galakrond                         == 3x
	{ spell = 144467, stacks = 2 }, --Iron Juggernaut/71466         144467 - Ignite Armor                                >= 2x
	{ spell = 144215, stacks = 6 }, --Kor'Kron Dark Shaman/71859    144215 - Froststorm Strike (Earthbreaker Haromm)     >= 6x
	{ spell = 143494, stacks = 3 }, --General Nazgrim/71515         143494 - Sundering Blow                              >= 3x
	{ spell = 142990, stacks = 12 }, --Malkorok/71454                142990 - Fatal Strike                                == 12x
	{ spell = 143426, stacks = 2 }, --Thok the Bloodthirsty/71529   143426 - Fearsome Roar                               == 2x
	{ spell = 143780, stacks = 2 }, --Thok (Saurok eaten)           143780 - Acid Breath                                 == 2x
	{ spell = 143773, stacks = 3 }, --Thok (Jinyu eaten)            143773 - Freezing Breath                             == 3x
	{ spell = 143767, stacks = 2 }, --Thok (Yaungol eaten)          143767 - Scorching Breath                            == 2x
	{ spell = 145183, stacks = 3 } --Garrosh/71865                 145183 - Gripping Despair                            >= 3x
};

--[[Taunt function!! load once]]
function ShouldTaunt()

	--[[Normal boss1 taunt method]]
	if not UnitIsUnit("player","boss1target") then
	  	for i = 1, #tauntsTable do
	  		if not UnitDebuffID("player",tauntsTable[i].spell) and UnitDebuffID("boss1target",tauntsTable[i].spell) and getDebuffStacks("boss1target",tauntsTable[i].spell) >= tauntsTable[i].stacks then
	  			TargetUnit("boss1");
	  			return true;
	  		end
	  	end
	end

  	--[[Swap back to Wavebinder Kardris]]
  	if getBossID("target") ~= 71858 then
  		if UnitDebuffID("player", 144215) and getDebuffStacks("player",144215) >= 6 then
  			if getBossID("boss1") == 71858 then
  				TargetUnit("boss1");
  				return true;
  			else
  				TargetUnit("boss2");
  				return true;
  			end
  		end
  	end
end























