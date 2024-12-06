require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)

    local gmos = Mod.Settings.GMosID

    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'GMTool_')) then  --look for the order that we inserted in Client_PresentMenuUI

		--in Client_PresentMenuUI, we comma-delimited the number of armies, the target territory ID, and the target player ID.  Break it out here
		local payloadSplit = split(string.sub(order.Payload, 8), ','); 
		local numArmies = tonumber(payloadSplit[1])
		local targetTerritoryID = tonumber(payloadSplit[2]);
		local targetPlayerID = tonumber(payloadSplit[3]);
		local numCities = tonumber(payloadSplit[4]);
		local numIncome = tonumber(payloadSplit[5]);
		local message = "" --checkthis!
		--host check
		if (order.PlayerID ~= gmos) then
			skipThisOrder(WL.ModOrderControl.Skip);
			return;
		end 
		
		--add armies to the source territory
		local targetModifier = WL.TerritoryModification.Create(targetTerritoryID);
		targetModifier.AddArmies = numArmies;
		
		--define SU marker
		local SU = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.SpecialUnits

-- Handover special unit ownership
if SU ~= nil and #SU > 0  and targetPlayerID ~= WL.PlayerID.Neutral and targetPlayerID ~= game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].OwnerPlayerID then
    	local targetSUTransfer = WL.TerritoryModification.Create(targetTerritoryID);
    	for _, v in pairs(SU) do
	       	if v.proxyType == "CustomSpecialUnit" then
            		local builder = WL.CustomSpecialUnitBuilder.CreateCopy(v)

            		--update ownership
            		builder.OwnerID = targetPlayerID
            
            		--update moddata
            		if v.ModData and startsWith(v.ModData, modSign(0)) then
                		local payloadSplit = split(string.sub(v.ModData, 5), ';;')
                		local transfer = tonumber(payloadSplit[2]) or 0
                		if transfer > 0 then
                    			transfer = transfer - 1
                    			builder.ModData = modSign(0) .. payloadSplit[1] .. ';;' .. transfer .. ';;' .. table.concat(payloadSplit, ';;', 3)
                		end
            		end

            		targetSUTransfer.RemoveSpecialUnitsOpt = {v.ID}
            		targetSUTransfer.AddSpecialUnits = {builder.Build()}
			
	    		--message = 'Transferring SU from '.. v.OwnerID.DisplayName(nil,false) .. ' to ' .. builder.OwnerID.DisplayName(nil,false);
			message = 'Transferring ' .. v.Name .. ' "'  .. v.TextOverHeadOpt .. '" from ' .. game.Game.Players[v.OwnerID].DisplayName(nil, false) .. ' to ' .. game.Game.Players[builder.OwnerID].DisplayName(nil, false);
			
			addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].OwnerPlayerID,
                		message,
                        	nil,
                        	{targetSUTransfer}))
        	end
    	end
end

--clear SU when neutralizing
if SU ~= nil and #SU > 0  and targetPlayerID == WL.PlayerID.Neutral then
    	local targetSUTransfer = WL.TerritoryModification.Create(targetTerritoryID);
    	for _, v in pairs(SU) do
            	targetSUTransfer.RemoveSpecialUnitsOpt = {v.ID}
			
	    	message = 'Removing Special Units';
		addNewOrder(WL.GameOrderEvent.Create(game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].OwnerPlayerID,
                	message,
                        nil,
                        {targetSUTransfer}))
    	end
end

    	-- Safely retrieve or initialize the Structures table
    	local cities = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].Structures or {}
    	
	--clear/add cities
    	if targetPlayerID == WL.PlayerID.Neutral then
    		cities[WL.StructureType.City] = 0 
		targetModifier.SetStructuresOpt = cities
	else
		cities[WL.StructureType.City] = numCities
		targetModifier.AddStructuresOpt = cities
	end

		--change territory ownership
		targetModifier.SetOwnerOpt = targetPlayerID

		--add income to destination player
		if incomeMod ~= 0 and targetPlayerID ~= WL.PlayerID.Neutral then
			local incomeMod = WL.IncomeMod.Create(targetPlayerID, numIncome, 'Income added to ' .. game.Game.Players[targetPlayerID].DisplayName(nil, false));
		end
		
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, order.Message, {}, {targetModifier}, nil, {incomeMod}));

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent, so get rid of the custom order.  There wouldn't be any harm in leaving it there, but it adds clutter to the orders list so it's better to get rid of it.
	end

end
