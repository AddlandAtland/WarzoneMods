function Client_PresentConfigureUI(rootParent)
	local num = Mod.Settings.GMosID;
	if num == nil then
		num = 0;
	end
    
    local horz = UI.CreateHorizontalLayoutGroup(rootParent);
	UI.CreateLabel(horz).SetText('Set the ID of GM');
    numberInputField = UI.CreateNumberInputField(horz)
		.SetSliderMinValue(0)
		.SetSliderMaxValue(100)
		.SetValue(num);

end
