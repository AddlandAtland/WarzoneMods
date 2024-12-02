
function Client_PresentConfigureUI(rootParent)
	local initialValue = Mod.Settings.CostPerNeutralArmy;
	if initialValue == nil then
		initialValue = 0;
	end
    
    local horz = UI.CreateHorizontalLayoutGroup(rootParent);
	UI.CreateLabel(horz).SetText('Cost per neutral army on the territory');
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(8)
		.SetValue(initialValue);

end