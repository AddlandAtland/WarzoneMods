require('Utilities');

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game)
	if (not WL.IsVersionOrHigher or not WL.IsVersionOrHigher("5.17")) then
		UI.Alert("You must update your app to the latest version to use this mod");
		return;
	end
	
	Game = game;
	SubmitBtn = nil;
	
	setMaxSize(450, 400);

	vert = UI.CreateVerticalLayoutGroup(rootParent);

	if (game.Us == nil) then
		UI.CreateLabel(vert).SetText("null");
		return;
	end

	local row1 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row1).SetText("Set Territory Owner: ");
	TargetPlayerBtn = UI.CreateButton(row1).SetText("Select player...").SetOnClick(TargetPlayerClicked);


	local row2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(row2).SetText("Set Territory to be modified: ");
	TargetTerritoryBtn = UI.CreateButton(row2).SetText("Select source territory...").SetOnClick(TargetTerritoryClicked);
	TargetTerritoryInstructionLabel = UI.CreateLabel(vert).SetText("").SetPreferredHeight(70); --give it a fixed height just so things don't jump around as we change its text

end


function TargetPlayerClicked()
	local players = Game.Game.Players; -- No filtering, includes all players
	local options = map(players, PlayerButton);
	table.insert(options, {
        	text = "Neutral",
        	selected = function()
            		TargetPlayerBtn.SetText("Neutral");
            		TargetPlayerID = WL.PlayerID.Neutral; -- Set to neutral player ID
            		CheckCreateFinalStep();
        	end
    	});
	UI.PromptFromList("Select the player you'd like to give the territory to", options);
end

function PlayerButton(player)
	local name = player.DisplayName(nil, false);
	local ret = {};
	ret["text"] = name;
	ret["selected"] = function() 
		TargetPlayerBtn.SetText(name);
		TargetPlayerID = player.ID;

		CheckCreateFinalStep();
	end
	return ret;
end

function TargetTerritoryClicked()
	UI.InterceptNextTerritoryClick(TerritoryClicked);
	TargetTerritoryInstructionLabel.SetText("Please click on the territory you wish to modify.  If needed, you can move this dialog out of the way.");
	TargetTerritoryBtn.SetInteractable(false);
end

function TerritoryClicked(terrDetails)
	TargetTerritoryBtn.SetInteractable(true);

	if (terrDetails == nil) then
		--The click request was cancelled. 
		TargetTerritoryInstructionLabel.SetText("");
	else
		--Territory was clicked, remember it
		TargetTerritoryInstructionLabel.SetText("Selected territory: " .. terrDetails.Name);
		SelectedTerritory = terrDetails;
		CheckCreateFinalStep();
	end

	return ret;
end

function CheckCreateFinalStep()

	if (SelectedTerritory == nil or TargetPlayerID == nil) then return; end;

	if (SubmitBtn == nil) then

		local row3 = UI.CreateHorizontalLayoutGroup(vert);
		UI.CreateLabel(row3).SetText("Army value modifier: ");
		NumArmiesInput = UI.CreateNumberInputField(row3)
			.SetSliderMinValue(-15)  -- Fixed minimum value
        		.SetSliderMaxValue(15) -- Fixed maximum value
        		.SetValue(0);          -- Default to 0

		SubmitBtn = UI.CreateButton(vert).SetText("Submit Change").SetOnClick(SubmitClicked);
	
	end

end

function SubmitClicked()
	if (SelectedTerritory == nil or TargetPlayerID == nil) then return; end;

	local msg = ""
	if (TargetPlayerID ~= WL.PlayerID.Neutral) then
		msg = 'Transferring ' .. SelectedTerritory.Name;
	else
		msg = 'Neutralizing ' .. SelectedTerritory.Name;
	end

	local payload = 'GMTool_' .. NumArmiesInput.GetValue() .. ',' .. SelectedTerritory.ID .. ',' .. TargetPlayerID;

	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, msg, payload));
	Game.Orders = orders;
	

end
