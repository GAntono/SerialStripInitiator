ScriptName SerialStripperPlayer Extends ReferenceAlias
{shows SerialStripper version at each game load}

SerialStripper_MCM Property SSer Auto

Event OnPlayerLoadGame()
	SSer.ShowVersion()
EndEvent
