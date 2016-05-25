ScriptName SerialStripperFunctions Extends Quest

Import StorageUtil

; String Property SSer_Version = "v1.1.4(1)" AutoReadOnly Hidden (Switched to string directly inside ShowVersion())

SerialStripFunctions Property SS Auto

String Property SSER_STRIPKEY = "APPS.SerialStripper.StripKey" AutoReadOnly Hidden
String Property SSER_HOLDTIMEFORFULLSTRIP = "APPS.SerialStripper.HoldTimeForFullStrip" AutoReadOnly Hidden

Function ShowVersion()
	Debug.Trace("[SerialStripper] v1.1.4(1)")
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
			SS.SendSerialStripStartEvent(Self, Target as Actor, abFullStrip = bFullStrip)
		Else
			SS.SendSerialStripStartEvent(Self, SS.PlayerRef, abFullStrip = bFullStrip)
		EndIf
	EndIf
EndEvent
