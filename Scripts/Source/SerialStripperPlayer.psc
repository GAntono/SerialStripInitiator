ScriptName SerialStripperPlayer Extends ReferenceAlias
{shows SerialStripper version at each game load}

Event OnPlayerLoadGame()
	(GetOwningQuest() as SerialStripper_MCM).ShowVersion()
EndEvent
