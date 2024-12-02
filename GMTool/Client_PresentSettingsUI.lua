function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent)
		.SetText('GM ID: ' .. Mod.Settings.GMosID);
end
