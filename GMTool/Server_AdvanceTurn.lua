require('Utilities');

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)

    local gmos = Mod.Settings.CostPerNeutralArmy

    if (order.proxyType == 'GameOrderCustom' and startsWith(order.Payload, 'GiftArmies2_')) then  --look for the order that we inserted in Client_PresentMenuUI

		--in Client_PresentMenuUI, we comma-delimited the number of armies, the target territory ID, and the target player ID.  Break it out here
		local payloadSplit = split(string.sub(order.Payload, 13), ','); 
		local numArmies = tonumber(payloadSplit[1])
		local targetTerritoryID = tonumber(payloadSplit[2]);
		local targetPlayerID = tonumber(payloadSplit[3]);
		
		--host check
		if (order.PlayerID ~= gmos) then
			skipThisOrder(WL.ModOrderControl.Skip);
			return;
		end 
		
		--add armies to the source territory
		local addFromSource = WL.TerritoryModification.Create(targetTerritoryID);
		addFromSource.SetArmiesTo = game.ServerGame.LatestTurnStanding.Territories[targetTerritoryID].NumArmies.NumArmies + numArmies;

		--Change ownership
		addFromSource.SetOwnerOpt = targetPlayerID;

		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, order.Message, {}, {addFromSource}, nil, nil));

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage); --we replaced the GameOrderCustom with a GameOrderEvent, so get rid of the custom order.  There wouldn't be any harm in leaving it there, but it adds clutter to the orders list so it's better to get rid of it.
	end

end
