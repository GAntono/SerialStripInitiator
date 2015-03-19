ScriptName SerialStripper_MCM Extends SKI_ConfigBase
{an MCM menu for the SerialStrip plugin, allowing to intiate serial stripping via keypress}

Import StorageUtil

SerialStrip Property SS Auto

String Property SS_STRIPPER_STRIPKEYONOFF = "APPS.SerialStripper.StripKeyOnOff" AutoReadOnly Hidden
String Property SS_STRIPPER_STRIPKEY = "APPS.SerialStripper.StripKey" AutoReadOnly Hidden
String Property SS_STRIPPER_HOLDTIMEFORFULLSTRIP = "APPS.SerialStripper.HoldTimeForFullStrip" AutoReadOnly Hidden
String Property SS_STRIPPER_WAITTIMEAFTERANIM = "APPS.SerialStripper.WaitingTimeAfterAnim" AutoReadOnly Hidden

Event OnConfigInit()
	SetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP, 2.0)
	SetFloatValue(None, SS_STRIPPER_WAITTIMEAFTERANIM, 1.0) ;this is saved on None because it will be used by other mods too.
EndEvent

Event OnPageReset(String asPage)
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddToggleOptionST("StripKeyOnOff", "Strip on keypress", GetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF))
	AddKeyMapOptionST("StripKey", "Key for stripping", GetIntValue(Self, SS_STRIPPER_STRIPKEY), OPTION_FLAG_WITH_UNMAP)
	AddSliderOptionST("HoldTimeForFullStrip", "Keypress duration for full stripping", GetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP), "{1} sec")
	AddSliderOptionST("WaitingTimeAfterAnim", "Time between animating and stripping", GetFloatValue(None, SS_STRIPPER_WAITTIMEAFTERANIM), "{1} sec")
EndEvent

State StripKeyOnOff
	Event OnSelectST()
		Int Status
		If (GetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF)) == 0
			Status = 1
		EndIf

		SetToggleOptionValueST(Status)
		SerialStripOn(Status)
		SetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF, Status)
	EndEvent

	Event OnHighlightST()
		SetInfoText("ON: will strip when key is pressed\nOFF: key inactive")
	EndEvent
EndState

State StripKey
	Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		If (conflictControl)
			String Msg
				If (conflictName)
					Msg = "This key is already mapped to:\n" + conflictControl + "\n(" + conflictName + ")\n\nAre you sure you want to continue?"
				Else
					Msg = "This key is already mapped to:\n" + conflictControl + "\n\nAre you sure you want to continue?"
				EndIf
			If (ShowMessage(Msg, True, "Yes", "No"))
				UnregisterForAllKeys()
				SetIntValue(Self, SS_STRIPPER_STRIPKEY, keyCode)
				SetKeymapOptionValueST(keyCode)
			EndIf
		Else
			UnregisterForAllKeys()
			SetIntValue(Self, SS_STRIPPER_STRIPKEY, keyCode)
			SetKeymapOptionValueST(keyCode)
		EndIf

		If(GetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF) == 1)
			SerialStripOn(1)
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("Select the key for stripping")
	EndEvent
EndState

State HoldTimeForFullStrip
	Event OnSliderOpenST()
		SetSliderDialogStartValue(GetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP))
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(0.0, 5.0)
		SetSliderDialogInterval(0.1)
	EndEvent

	Event OnSliderAcceptST(float afSelectedValue)
		Float HoldTimeForFullStrip
		If (0.0 < afSelectedValue && afSelectedValue < 0.5)	;waiting times < 0.5 seconds are prone to errors (Heromaster)
			HoldTimeForFullStrip = 0.5
		Else
			HoldTimeForFullStrip = afSelectedValue
		EndIf

		SetSliderOptionValueST(HoldTimeForFullStrip, "{1} sec")
		SetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP, HoldTimeForFullStrip)
	EndEvent

	Event OnHighlightST()
		SetInfoText("Select how long the key should be held to start a full serial strip.\nSimple taps will trigger a single serial strip.")
	EndEvent
EndState

State WaitingTimeAfterAnim
	Event OnSliderOpenST()
		SetSliderDialogStartValue(GetFloatValue(None, SS_STRIPPER_WAITTIMEAFTERANIM))
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 5.0)
		SetSliderDialogInterval(0.1)
	EndEvent

	Event OnSliderAcceptST(float afSelectedValue)
		Float WaitingTimeAfterAnim
		
		If (0.0 < afSelectedValue && afSelectedValue < 0.5)	;waiting times < 0.5 seconds are prone to errors (Heromaster)
			WaitingTimeAfterAnim = 0.5
		Else
			WaitingTimeAfterAnim = afSelectedValue
		EndIf

		SetSliderOptionValueST(WaitingTimeAfterAnim, "{1} sec")
		SetFloatValue(None, SS_STRIPPER_WAITTIMEAFTERANIM, WaitingTimeAfterAnim)
	EndEvent

	Event OnHighlightST()
		SetInfoText("After a stripping animation ends, this defines how long to wait until the items are stripped\nAdjust according to your system's speed to achieve best results.")
	EndEvent
EndState

Function SerialStripOn(Int abActivateSerialStrip)
;turns on serial stripping. Pass 1 to run on, 0 to turn off.

	If (abActivateSerialStrip == 1) ;if serial stripping is set to activate
		RegisterForKey(GetIntValue(Self, SS_STRIPPER_STRIPKEY)) ;registers to listen for the strip key
	Else ;if serial stripping is set to deactivate
		UnRegisterForKey(GetIntValue(Self, SS_STRIPPER_STRIPKEY)) ;stops listening for the strip key
	EndIf
EndFunction

Event OnKeyUp(Int KeyCode, Float HoldTime)
;when the key is released

	If (KeyCode == GetIntValue(Self, SS_STRIPPER_STRIPKEY) && !Utility.IsInMenuMode()) ;if the key that was released is the key for serial stripping and we are not in a menu
		SS.RegisterForModEvent("SerialStripStart", "OnSerialStripStart")
		
		If (HoldTime < GetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP)) ;if the key has not been held down long enough
			SendSerialStripStartEvent(Self, False)
		Else
			SendSerialStripStartEvent(Self, True)
		EndIf
	EndIf
EndEvent

Bool Function SendSerialStripStartEvent(Form akSender, Bool abFullStrip = False)
	;/ beginValidation /;
	If (!akSender)
		Return False
	EndIf
	;/ endValidation /;

	Int Handle = ModEvent.Create("SerialStripStart")
	If (Handle)
		ModEvent.PushForm(Handle, akSender)
		ModEvent.PushBool(Handle, abFullStrip)
		ModEvent.Send(Handle)
		Return True
	Else
		Return False
	EndIf
EndFunction
