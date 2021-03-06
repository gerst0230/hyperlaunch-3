MEmu = Dolphin
MEmuV =  v4.0 r4875
MURL = https://dolphin-emu.org/
MAuthor = djvj
MVersion = 2.0.6
MCRC = 2BC942D7
iCRC = 870A906B
MID = 635038268884477733
MSystem = "Nintendo Gamecube","Nintendo Wii","Nintendo WiiWare"
;----------------------------------------------------------------------------
; Notes:
; Be sure you are running at least Dolphin v4.0 or greater.
; If you get an error that you are missing a vcomp100.dll, install Visual C++ 2010: http://www.microsoft.com/download/en/details.aspx?id=14632
; Also make sure you are running latest directx: http://www.microsoft.com/downloads/details.aspx?FamilyID=2da43d38-db71-4c1b-bc6a-9b6652cd92a3
; Dolphin will sometimes crash when connnecting a Wiimote, then going back to the game. After all Wiimotes are connected that you want to use, it shouldn't have anymore issues.
; Convert all your games to ciso using Wii Backup Manager to save alot of space by stripping everything but the game partition. http://www.wiibackupmanager.tk/
; Render to Main Window needs to be unchecked, otherwise hotkeys to pair wiimotes will not work in fullscreen. This is done for you if you forget.
; If you want to keep your Dolphin.ini in the emu folder, create a "portable.txt" file in MyDocuments\Dolphin Emulator\
;
; Bezels:
; If the game does not fit the window, you can try setting stretch to window manually in dolphin.
;
; Setting up custom Wiimote or GCPad profiles:
; First set UseCustomWiimoteProfiles or UseCustomGCpadProfiles to true in HLHQ for this module
; Launch Dolphin manually and goto Options->(Wiimote or Gamecube Pad) Settings and configure all your controls how you want your default setup to look like. This will be used for all games that you don't set a custom profile for. No need to save any profiles.
; All your controls are stored in WiimoteNew.ini or GCPadNew.ini and get copied to a _Default_(WiimoteNew or GCPadNew).ini on first launch. This ini contains all the controls for all 4 controllers.
; Do not confuse this with Dolphin's built-in profiles as those only contain info for only one controller. The (WiimoteNew or GCPadNew).ini and all the profiles HL uses contain info for all controllers in one file.
; This new profile now called _Default_(WiimoteNew or GCPadNew).ini will be found in Dolphins settings folder: \Config\Profiles\(Wiimote or GCPad) (HL)\Default.ini
; For each game or custom control sets you want to use, edit the controls for all the controllers to work for that game and exit Dolphin. Now copy the (WiimoteNew or GCPadNew).ini to the "(Wiimote or GCPad) (HL)" folder and name it whatever you like.
; In HLHQ's module settings for Dolphin, Click the Rom Settings tab and add each game from your xml you want to use a this custom profile for.
; Now for all those games you added, make sure the Profile setting it set to the custom profile you want to load when that game is launched.
; Any game not added will use the "_Default_(WiimoteNew or GCPadNew).ini" profile HL makes on first launch.
;
; To Pair a Wiimote:
; Make sure all your wiimotes have already been paired with your PC's bluetooth adapter
; All 4 leds on the wiimote should be flashing
; Press your Refresh key (set in HLHQ for this module) or enable continuous scanning in Dolphin
; Press 1 + 2 on the wiimote and one led should go solid designating the player number
;----------------------------------------------------------------------------
StartModule()
BezelGui()
FadeInStart()

settingsFile := modulePath . "\" . moduleName . ".ini"
Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)
UseCustomWiimoteProfiles := IniReadCheck(settingsFile, "Settings", "UseCustomWiimoteProfiles","false",,1)	; set to true if you want to setup custom Wiimote profiles for games
UseCustomGCPadProfiles := IniReadCheck(settingsFile, "Settings", "UseCustomGCPadProfiles","false",,1)	; set to true if you want to setup custom GCPad profiles for games
HideMouse := IniReadCheck(settingsFile, "Settings", "HideMouse","true",,1)					; hides mouse cursor in the emu options
RefreshKey := IniReadCheck(settingsFile, "Settings", "RefreshKey","",,1)						; hotkey to "Refresh" Wiimotes, delete the key to disable it
Timeout := IniReadCheck(settingsFile, "Settings", "Timeout","5",,1)							; amount in seconds we should wait for the above hotkeys to timeout

BezelStart()

; Determine where Dolphin is storing its ini, this will act as the base folder for settings and profiles related to this emu
dolphinININewPath := A_MyDocuments . "\Dolphin Emulator\Config\Dolphin.ini"	; location of Dolphin.ini for v4.0+
dolphinINIOldPath := emuPath . "\User\Config\Dolphin.ini"	; location of Dolphin.ini prior to v4.0
IfExist % dolphinININewPath
{	dolphinBasePath := A_MyDocuments . "\Dolphin Emulator"
	Log("Module - Dolphin's base settings folder is not portable and found in: " . dolphinBasePath)
} Else IfExist % dolphinINIOldPath
{	dolphinBasePath := emuPath . "\User"
	Log("Module - Dolphin's base settings folder is portable and found in: " . dolphinBasePath)
} Else
	ScriptError("Could not find your Dolphin.ini in either of these folders. Please run Dolphin manually first to create it.`n" . dolphinINIOldPath . "`n" . dolphinININewPath)
dolphinINI := dolphinBasePath . "\Config\Dolphin.ini"

hideEmuObj := Object("Dolphin Wiimote Configuration ahk_class #32770",0,"Dolphin ahk_class wxWindowNR",1)	; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)

If romExtension in .zip,.7z,.rar
	ScriptError(MEmu . " does not support compressed roms. Please enable 7z support in HLHQ to use this module/emu.")

If PairKey {
	PairKey := xHotKeyVarEdit(PairKey,"PairKey","~","Add")
	xHotKeywrapper(PairKey,"PairWiimote")
}
If RefreshKey {
	RefreshKey := xHotKeyVarEdit(RefreshKey,"RefreshKey","~","Add")
	xHotKeywrapper(RefreshKey,"RefreshWiimote")
}

Fullscreen := (If ( Fullscreen = "true" ) ? ("True") : ("False"))
HideMouse := (If ( HideMouse = "true" ) ? ("True") : ("False"))

gcSerialPort = 5	; this puts the BBA network adapter into the serial port. If previous launch was Triforce, AM-Baseboard would be set here and would result in Unknown DVD command errors

iniLookup =
( ltrim c
	Display, Fullscreen, %Fullscreen%
	Display, RenderToMain, False
	Interface, HideCursor, %HideMouse%
	Interface, ConfirmStop, False
	Interface, UsePanicHandlers, False
	Core, SerialPort1, %gcSerialPort%
)
Loop, Parse, iniLookup, `n
{
	StringSplit, split, A_LoopField, `,, %A_Space%%A_Tab%
	IniRead, tempVar, %dolphinINI%, %split1%, %split2%
	If ( tempVar != split3 )
		IniWrite, % split3, %dolphinINI%, %split1%, %split2%
}

 ; Load default or user specified Wiimote or GCPad profiles for launching
If (InStr(systemName, "wii") && UseCustomWiimoteProfiles = "true")
	ChangeDolphinProfile("Wiimote")
If (UseCustomGCPadProfiles = "true")
	ChangeDolphinProfile("GCPad")

HideEmuStart()

Run(executable . " /b /e """ . romPath . "\" . romName . romExtension . """", emuPath)

WinWait("Dolphin ahk_class wxWindowNR")
WinWaitActive("Dolphin ahk_class wxWindowNR")

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


ChangeDolphinProfile(profileType) {
	Global settingsFile,romName,dolphinBasePath
	profile := IniReadCheck(settingsFile, romName, "profile", "Default",,1)
	HLProfilePath := dolphinBasePath . "\Config\Profiles\" . profileType . " (HL)"
	currentProfile := dolphinBasePath . "\Config\" . profileType . "New.ini"
	defaultProfile := HLProfilePath . "\_Default_" . profileType . "New.ini"
	customProfile := HLProfilePath . "\" . profile . ".ini"
	If !FileExist(currentProfile) {
		Log("Module - You have custom " . profileType . " profiles enabled, but could not locate " . currentProfile . ". This file stores all your current controls in Dolphin. Please setup your controls in Dolphin first.",2)
		Return
	}
	If !FileExist(defaultProfile) {
		Log("Module - Creating initial Default " . profileType . " profile by copying " . profileType . ".ini to " . defaultProfile, 2)
		FileCreateDir % HLProfilePath
		FileCopy, %currentProfile%, %defaultProfile%	; create the initial default profile on first launch
	}
	If (profile != "Default" && !FileExist(customProfile))
		Log("Module - " . romName . " is set to load a custom " . profileType . " profile`, but it could not be found: " . customProfile,2)
	FileRead, cProfile, %currentProfile%	; read current profile into memory
	FileRead, nProfile, %customProfile%	; read custom profile into memory
	If ( cProfile != nProfile ) {	; if both profiles do not match exactly
		Log("Module - Current " . profileType . " profile does not match the one this game should use.")
		If (profile != "Default") {	; if user set to use a custom profile
			Log("Module - Copying this defined " . profileType . " profile to replace the current one: " . customProfile)
			FileCopy, %customProfile%, %currentProfile%, 1
		} Else {	; load default profile
			Log("Module - Copying the default " . profileType . " profile to replace the current one: " . defaultProfile)
			FileCopy, %defaultProfile%, %currentProfile%, 1
		}
	} Else
		Log("Module - Current " . profileType . " profile is already the correct one for this game, not touching it.")
}

ConnectWiimote(key) {
	Global Timeout
	wiimoteClass := "Dolphin Controller Configuration ahk_class #32770"
	IfWinNotExist, %wiimoteClass%
	{
		DetectHiddenWindows, OFF ; this needs to be off otherwise WinMenuSelectItem doesn't work for some odd reason
		WinActivate, Dolphin ahk_class wxWindowNR,,,FPS
		WinMenuSelectItem, ahk_class wxWindowNR,, Options, Controller Settings,,,,,,FPS
		WinWait(wiimoteClass)
		WinWaitActive(wiimoteClass)
	}
	;WinActivate, %wiimoteClass% ; test if window needs to be active
	ControlClick, %key%, %wiimoteClass%
	ControlClick, OK, %wiimoteClass%
	; WinActivate, FPS ahk_class wxWindowClassNR ; for older dolphins
	WinActivate, FPS ahk_class wxWindowNR
}

PairWiimote:
	ConnectWiimote("Pair Up")
Return

RefreshWiimote:
	ConnectWiimote("Refresh")
Return

CloseProcess:
	FadeOutStart()
	WinClose("FPS ahk_class wxWindowNR") ; this needs to close the window the game is running in otherwise dolphin crashes on exit
Return
