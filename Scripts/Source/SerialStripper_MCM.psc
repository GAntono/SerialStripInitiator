ScriptName SerialStripper_MCM Extends SKI_ConfigBase
{an MCM menu for the SerialStrip plugin, allowing to intiate serial stripping via keypress}

Import StorageUtil

String Property SSer_Version = "v1.0-beta" AutoReadOnly Hidden

SerialStripFunctions Property SS Auto

String Property SSER_STRIPKEYONOFF = "APPS.SerialStripper.StripKeyOnOff" AutoReadOnly Hidden
String Property SSER_STRIPKEY = "APPS.SerialStripper.StripKey" AutoReadOnly Hidden
String Property SSER_HOLDTIMEFORFULLSTRIP = "APPS.SerialStripper.HoldTimeForFullStrip" AutoReadOnly Hidden
String Property SS_WAITTIMEAFTERANIM = "APPS.SerialStrip.WaitingTimeAfterAnim" AutoReadOnly Hidden

Int Property GeneralOptionFlags = 0x00 Auto Hidden ;OPTION_FLAG_NONE from SKI_ConfigBase
Int Property StripKeyOptionFlag = 0x04 Auto Hidden ;OPTION_FLAG_WITH_UNMAP from SKI_ConfigBase

Function ShowVersion()
	Debug.Trace("[SerialStripper] " + SSer_Version)
EndFunction

Event OnConfigInit()
	AdjustIntValue(Self, "OnInitCounter", 1)
	If (GetIntValue(Self, "OnInitCounter") == 2)
		ShowVersion()
		SetFloatValue(Self, SSER_HOLDTIMEFORFULLSTRIP, 2.0)
		SetFloatValue(None, SS_WAITTIMEAFTERANIM, 1.0) ;this is saved on None because it will be used by other mods too. It also has the SS prefix.
		UnSetIntValue(Self, "OnInitCounter")
		Debug.Notification("$SSER_INSTALLSSTRIPPERDONE_NOTIFY{" + SSer_Version + "}")
	EndIf
EndEvent

Event OnPageReset(String asPage)
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddToggleOptionST("StripKeyOnOff", "$SSER_STRIPONKEYPRESS", GetIntValue(Self, SSER_STRIPKEYONOFF), GeneralOptionFlags)
	AddKeyMapOptionST("StripKey", "$SSER_KEYFORSTRIPPING", GetIntValue(Self, SSER_STRIPKEY), StripKeyOptionFlag)
	AddSliderOptionST("HoldTimeForFullStrip", "$SSER_KEYPRESSDURATIONFORFULLSTRIP", GetFloatValue(Self, SSER_HOLDTIMEFORFULLSTRIP), "{1} sec", GeneralOptionFlags)
	AddSliderOptionST("WaitingTimeAfterAnim", "$SSER_TIMEBETWEENANIMANDSTRIP", GetFloatValue(None, SS_WAITTIMEAFTERANIM), "{1} sec", GeneralOptionFlags)
	AddEmptyOption()
	AddEmptyOption()
	AddEmptyOption()
	AddEmptyOption()
	AddToggleOptionST("UninstallSSer", "$SSER_UNINSTALLSSTRIPPER", False, GeneralOptionFlags)
	AddToggleOptionST("UninstallSSerSS", "$SSER_UNINSTALLSSTRIPPERANDSSTRIP", False, GeneralOptionFlags)
EndEvent

State StripKeyOnOff
	Event OnSelectST()
		Int Status
		If (GetIntValue(Self, SSER_STRIPKEYONOFF)) == 0
			Status = 1
		EndIf

		SetToggleOptionValueST(Status)
		SerialStripperOn(Status)
		SetIntValue(Self, SSER_STRIPKEYONOFF, Status)
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SSER_STRIPONKEYPRESS_DESC")
	EndEvent
EndState

State StripKey
	Event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		If (conflictControl)
			String Msg
				If (conflictName)
					Msg = "$SSER_KEYCONFLICTWITHMOD{" + conflictControl + "}{" + conflictName + "}"
				Else
					Msg = "$SSER_KEYCONFLICTWITHVANILLA{" + conflictControl + "}"
				EndIf
			If (ShowMessage(Msg, True, "$YES", "$NO"))
				UnregisterForAllKeys()
				SetIntValue(Self, SSER_STRIPKEY, keyCode)
				SetKeymapOptionValueST(keyCode)
			EndIf
		Else
			UnregisterForAllKeys()
			SetIntValue(Self, SSER_STRIPKEY, keyCode)
			SetKeymapOptionValueST(keyCode)
		EndIf

		If(GetIntValue(Self, SSER_STRIPKEYONOFF) == 1)
			SerialStripperOn(1)
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SSER_KEYFORSTRIPPING_DESC")
	EndEvent
EndState

State HoldTimeForFullStrip
	Event OnSliderOpenST()
		SetSliderDialogStartValue(GetFloatValue(Self, SSER_HOLDTIMEFORFULLSTRIP))
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
		SetFloatValue(Self, SSER_HOLDTIMEFORFULLSTRIP, HoldTimeForFullStrip)
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SSER_KEYPRESSDURATIONFORFULLSTRIP_DESC")
	EndEvent
EndState

State WaitingTimeAfterAnim
	Event OnSliderOpenST()
		SetSliderDialogStartValue(GetFloatValue(None, SS_WAITTIMEAFTERANIM))
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
		SetFloatValue(None, SS_WAITTIMEAFTERANIM, WaitingTimeAfterAnim)
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SSER_TIMEBETWEENANIMANDSTRIP_DESC")
	EndEvent
EndState

State UninstallSSer
	Event OnSelectST()
		If (ShowMessage("$SSER_UNINSTALLSSTRIPPERCONFIRM_MSG"))
			GeneralOptionFlags = OPTION_FLAG_DISABLED
			StripKeyOptionFlag = OPTION_FLAG_DISABLED
			ForcePageReset()
			Debug.Trace("SerialStripper uninstalling")
			UnregisterForAllKeys()
			UnSetIntValue(Self, SSER_STRIPKEYONOFF)
			UnSetIntValue(Self, SSER_STRIPKEY)
			UnSetFloatValue(Self, SSER_HOLDTIMEFORFULLSTRIP)
			UnSetFloatValue(None, SS_WAITTIMEAFTERANIM)
			Debug.Trace("SerialStripper uninstalled")
			ShowMessage("$SSER_UNINSTALLSSTRIPPERDONE_MSG")
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SSER_UNINSTALLSSTRIPPER_DESC")
	EndEvent
EndState

State UninstallSSerSS
	Event OnSelectST()
		If (ShowMessage("$SSER_UNINSTALLSSTRIPPERANDSSTRIPCONFIRM_MSG"))
			GeneralOptionFlags = OPTION_FLAG_DISABLED
			StripKeyOptionFlag = OPTION_FLAG_DISABLED
			ForcePageReset()
			Debug.Trace("SerialStripper uninstalling")
			UnregisterForAllKeys()
			UnSetIntValue(Self, SSER_STRIPKEYONOFF)
			UnSetIntValue(Self, SSER_STRIPKEY)
			UnSetFloatValue(Self, SSER_HOLDTIMEFORFULLSTRIP)
			UnSetFloatValue(None, SS_WAITTIMEAFTERANIM)
			Debug.Trace("SerialStripper uninstalled")
			SS.Uninstall()
			ShowMessage("$SSER_UNINSTALLSSTRIPPERANDSSTRIPDONE_MSG")
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SSER_UNINSTALLSSTRIPPERANDSSTRIP_DESC")
	EndEvent
EndState

Function SerialStripperOn(Int abActivateSerialStripper)
;turns on serial stripping. Pass 1 to run on, 0 to turn off.

	If (abActivateSerialStripper == 1) ;if serial stripping is set to activate
		RegisterForKey(GetIntValue(Self, SSER_STRIPKEY)) ;registers to listen for the strip key
	Else ;if serial stripping is set to deactivate
		UnRegisterForKey(GetIntValue(Self, SSER_STRIPKEY)) ;stops listening for the strip key
	EndIf
EndFunction

Event OnKeyUp(Int KeyCode, Float HoldTime)
;when the key is released
	If (KeyCode == GetIntValue(Self, SSER_STRIPKEY) && !Utility.IsInMenuMode()) ;if the key that was released is the key for serial stripping and we are not in a menu
		If (HoldTime < GetFloatValue(Self, SSER_HOLDTIMEFORFULLSTRIP)) ;if the key has not been held down long enough
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
