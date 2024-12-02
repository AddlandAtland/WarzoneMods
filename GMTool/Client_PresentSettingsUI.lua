function Client_PresentSettingsUI(rootParent)
	UI.CreateLabel(rootParent)
		.SetText('Host ID: ' .. Mod.Settings.GMosID);
end
