require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)

    local gmos = Mod.Settings.GMosID

    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'GMTool_')) then  --look for the order that we inserted in Client_PresentMenuUI

		--in Client_PresentMenuUI, we comma-delimited the number of armies, the target territory ID, and the target player ID.  Break it out here
		local payloadSplit = split(string.sub(order.Payload, 8), ','); 
		local numArmies = tonumber(payloadSplit[1])
		local targetTerritoryID = tonumber(payloadSplit[2]);
		local targetPlayerID = tonumber(payloadSplit[3]);
		
		--host check
		if (order.PlayerID ~= gmos) then
			skipThisOrder(WL.ModOrderControl.Skip);
			return;
		end 
		
		--add armies to the source territory
		local targetModifier = WL.TerritoryModification.Create(targetTerritoryID);
		targetModifier.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies + numArmies;
		
		--define SU marker
		local SU = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.SpecialUnits
		
		--change territory ownership
		targetModifier.SetOwnerOpt = targetPlayerID;
		--handover SU ownership
		if (SU ~= nil and targetPlayerID ~= WL.PlayerID.Neutral) then
			SU.OwnerID = targetPlayerID
		end 

		--clear SU when neutralizing
		if (SU ~= nil and targetPlayerID == WL.PlayerID.Neutral) then
			for _, v in pairs(SU) do
    				targetModifier.RemoveSpecialUnitsOpt = {v.ID}
			end
		end 
			
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, order.Message, {}, {targetModifier}, nil, nil));

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent, so get rid of the custom order.  There wouldn't be any harm in leaving it there, but it adds clutter to the orders list so it's better to get rid of it.
	end

end
