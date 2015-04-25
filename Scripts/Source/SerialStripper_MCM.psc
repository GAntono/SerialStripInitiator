ScriptName SerialStripper_MCM Extends SKI_ConfigBase
{an MCM menu for the SerialStrip plugin, allowing to intiate serial stripping via keypress}

Import StorageUtil

String Property SSer_Version = "v1.0-beta" AutoReadOnly Hidden

SerialStrip Property SS Auto

String Property SS_STRIPPER_STRIPKEYONOFF = "APPS.SerialStripper.StripKeyOnOff" AutoReadOnly Hidden
String Property SS_STRIPPER_STRIPKEY = "APPS.SerialStripper.StripKey" AutoReadOnly Hidden
String Property SS_STRIPPER_HOLDTIMEFORFULLSTRIP = "APPS.SerialStripper.HoldTimeForFullStrip" AutoReadOnly Hidden
String Property SS_STRIPPER_WAITTIMEAFTERANIM = "APPS.SerialStripper.WaitingTimeAfterAnim" AutoReadOnly Hidden

Function ShowVersion()
	Debug.Trace("[SerialStriper] " + SSer_Version)
EndFunction

Event OnConfigInit()
	SetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP, 2.0)
	SetFloatValue(None, SS_STRIPPER_WAITTIMEAFTERANIM, 1.0) ;this is saved on None because it will be used by other mods too.
EndEvent

Event OnPageReset(String asPage)
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddToggleOptionST("StripKeyOnOff", "$STRIP_ON_KEYPRESS", GetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF))
	AddKeyMapOptionST("StripKey", "$KEY_FOR_STRIPPING", GetIntValue(Self, SS_STRIPPER_STRIPKEY), OPTION_FLAG_WITH_UNMAP)
	AddSliderOptionST("HoldTimeForFullStrip", "$KEYPRESS_DURATION_FOR_FULL_STRIP", GetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP), "{1} sec")
	AddSliderOptionST("WaitingTimeAfterAnim", "$TIME_BETWEEN_ANIM_&_STRIP", GetFloatValue(None, SS_STRIPPER_WAITTIMEAFTERANIM), "{1} sec")
	AddEmptyOption()
	AddToggleOptionST("UninstallSSer", "$UNINSTALL_SSER", False)
	AddToggleOptionST("UninstallSS", "$UNINSTALL_SS", False)
EndEvent

State StripKeyOnOff
	Event OnSelectST()
		Int Status
		If (GetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF)) == 0
			Status = 1
		EndIf

		SetToggleOptionValueST(Status)
		SerialStripperOn(Status)
		SetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF, Status)
	EndEvent

	Event OnHighlightST()
		SetInfoText("$EXPLAIN_StripKeyOnOff")
	EndEvent
EndState

State StripKey
	Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		If (conflictControl)
			String Msg
				If (conflictName)
					Msg = "$KEY_CONFLICT_WITH_MOD{" + conflictControl + "}{" + conflictName + "}"
				Else
					Msg = "$KEY_CONFLICT_WITH_VANILLA{" + conflictControl + "}"
				EndIf
			If (ShowMessage(Msg, True, "$YES", "$NO"))
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
			SerialStripperOn(1)
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("$EXPLAIN_StripKey")
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
		SetInfoText("$EXPLAIN_HoldTimeForFullStrip")
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
		SetInfoText("$EXPLAIN_WaitingTimeAfterAnim")
	EndEvent
EndState

State UninstallSS
	Event OnSelectST()
		If (ShowMessage("$CONFIRM_UNINSTALL_SS"))
			UnSetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF)
			UnSetIntValue(Self, SS_STRIPPER_STRIPKEY)
			UnSetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP)
			UnSetFloatValue(None, SS_STRIPPER_WAITTIMEAFTERANIM)
			SS.Uninstall()
			SetToggleOptionValueST(True)
			SetOptionFlagsST(OPTION_FLAG_DISABLED)
			SetOptionFlagsST(OPTION_FLAG_DISABLED, "StripKeyOnOff")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, "StripKey")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, "HoldTimeForFullStrip")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, "WaitingTimeAfterAnim")
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("$EXPLAIN_UNINSTALL_SS")
	EndEvent
EndState

State UninstallSSer
	Event OnSelectST()
		If (ShowMessage("$CONFIRM_UNINSTALL_SSER"))
			UnSetIntValue(Self, SS_STRIPPER_STRIPKEYONOFF)
			UnSetIntValue(Self, SS_STRIPPER_STRIPKEY)
			UnSetFloatValue(Self, SS_STRIPPER_HOLDTIMEFORFULLSTRIP)
			UnSetFloatValue(None, SS_STRIPPER_WAITTIMEAFTERANIM)
			SetToggleOptionValueST(True)
			SetOptionFlagsST(OPTION_FLAG_DISABLED)
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("$EXPLAIN_UNINSTALL_SSER")
	EndEvent
EndState

Function SerialStripperOn(Int abActivateSerialStripper)
;turns on serial stripping. Pass 1 to run on, 0 to turn off.

	If (abActivateSerialStripper == 1) ;if serial stripping is set to activate
		RegisterForKey(GetIntValue(Self, SS_STRIPPER_STRIPKEY)) ;registers to listen for the strip key
	Else ;if serial stripping is set to deactivate
		UnRegisterForKey(GetIntValue(Self, SS_STRIPPER_STRIPKEY)) ;stops listening for the strip key
	EndIf
EndFunction

Event OnKeyUp(Int KeyCode, Float HoldTime)
;when the key is released

	If (KeyCode == GetIntValue(Self, SS_STRIPPER_STRIPKEY) && !Utility.IsInMenuMode()) ;if the key that was released is the key for serial stripping and we are not in a menu


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
