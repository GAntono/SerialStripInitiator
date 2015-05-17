ScriptName SerialStripperFunctions Extends Quest

Import StorageUtil

String Property SSer_Version = "v1.1.1-beta" AutoReadOnly Hidden

SerialStripFunctions Property SS Auto

String Property SSER_STRIPKEY = "APPS.SerialStripper.StripKey" AutoReadOnly Hidden
String Property SSER_HOLDTIMEFORFULLSTRIP = "APPS.SerialStripper.HoldTimeForFullStrip" AutoReadOnly Hidden

Function ShowVersion()
	Debug.Trace("[SerialStripper] " + SSer_Version)
EndFunction

Event OnKeyUp(Int KeyCode, Float HoldTime)
;when the key is released
	Bool bFullStrip
	ObjectReference Target = Game.GetCurrentCrosshairRef()

	If (KeyCode == GetIntValue(Self, SSER_STRIPKEY) && !Utility.IsInMenuMode()) ;if the key that was released is the key for serial stripping and we are not in a menu
		Debug.Trace("[SerialStripper] Key detected")
		If (HoldTime >= GetFloatValue(Self, SSER_HOLDTIMEFORFULLSTRIP)) ;if the key has been held down long enough
			bFullStrip = True
		EndIf

		If (Target && Target.HasKeyword(Keyword.GetKeyword("ActorTypeNPC")))
			SS.SendSerialStripStartEvent(Self, Target as Actor, bFullStrip)
		Else
			SS.SendSerialStripStartEvent(Self, SS.PlayerRef, bFullStrip)
		EndIf
	EndIf
EndEvent
