class Configuration {

    ;Private variables
    _scriptVersion      := ""
    _configFile         := "Config.ini"
    _delimiter          := Chr(9) ;tab

    ;-------------------------------------------------------------------------
    ; Stablihs working directory and, if needed, extract script files from
    ; exe file
    ;
    __New(version) {
        this._scriptVersion := version
        this._SetWorkingDir()
        this._InstallScriptFiles()
    }

    ;-------------------------------------------------------------------------
    ; Property indicating whether this program should run at Windows startup
    ; Values: true / false
    ;
    runAtStartup {
        get {
            SplitPath, A_ScriptFullPath, name, dir, ext, name_no_ext, drive
            linkFile := A_Startup . "\" . name_no_ext . ".lnk"
            if !FileExist(linkFile) {
                return false
            } else {
                FileGetShortcut, % linkFile, OutTarget
                return (OutTarget = A_ScriptFullPath ? true : false)                        ;Returns true if linkFile target is this script
            }
        }
        set {
            SplitPath, A_ScriptFullPath, name, dir, ext, name_no_ext, drive
            linkFile := A_Startup . "\" . name_no_ext . ".lnk"
            
            if (value) {
                if FileExist(linkFile)
                    FileDelete, %linkFile%

                FileCreateShortcut, % A_ScriptFullPath, % linkFile, % dir
                
            } else {
                FileDelete, % linkFile
            }
            
            return !ErrorLevel
        }
    }

    ;-------------------------------------------------------------------------
    ; Set working dir at %Appdata%\Roaming\<script name> (creates directory
    ; in case it doesn't exist)
    ;
    _SetWorkingDir() {
        SplitPath, A_ScriptFullPath, name, dir, ext, name_no_ext, drive

        workingDir := A_AppData . "\" . name_no_ext
        if !FileExist(workingDir) {                                                         ;Check if working directory exist
            FileCreateDir, % workingDir
            if ErrorLevel {
                MsgBox, % "Error creating directory " . workingDir
                ExitApp
            }
        }
        
        SetWorkingDir %workingDir%                                                          ;Set working dir in appdata
        if ErrorLevel {
            MsgBox, % "Error setting working directory " . workingDir
            ExitApp
        }
    }

    ;-------------------------------------------------------------------------
    ; If scripts files doesn't exits, extract them from exe in the working dir
    ;
    _InstallScriptFiles() {

        CreateFolder(A_ScriptDir, "images")
        CreateFolder(A_ScriptDir, "nircmd-x64")
        CreateFolder(A_ScriptDir, "soundvolumeview-x64")
       
        ;FileInstall with last parameter "false" --> only extract file from exe if file doesn't exist.
        ;Images
        FileInstall, images\SwitchAudioOutput.ico            , % A_ScriptDir . "\images\SwitchAudioOutput.ico"           , false
        FileInstall, images\MenuChangeSoundDevices.ico       , % A_ScriptDir . "\images\MenuChangeSoundDevices.ico"      , false
        FileInstall, images\MenuExit.ico                     , % A_ScriptDir . "\images\MenuExit.ico"                    , false
        FileInstall, images\MenuReload.ico                   , % A_ScriptDir . "\images\MenuReload.ico"                  , false
        FileInstall, images\MenuSetHotkey.ico                , % A_ScriptDir . "\images\MenuSetHotkey.ico"               , false
        FileInstall, images\MenuShowActiveSoundDevice.ico    , % A_ScriptDir . "\images\MenuShowActiveSoundDevice.ico"   , false
        FileInstall, images\MenuShowSoundDevicesGui.ico      , % A_ScriptDir . "\images\MenuShowSoundDevicesGui.ico  "   , false

        ;NirSoft NirCmd files
        FileInstall,nircmd-x64\NirCmd.chm                    , % A_ScriptDir . "\nircmd-x64\NirCmd.chm"                  , false
        FileInstall,nircmd-x64\nircmd.exe                    , % A_ScriptDir . "\nircmd-x64\nircmd.exe"                  , false
        FileInstall,nircmd-x64\nircmdc.exe                   , % A_ScriptDir . "\nircmd-x64\nircmdc.exe"                 , false
        
        ;NirSoft SoundVolumeView
        FileInstall, soundvolumeview-x64\readme.txt          , % A_ScriptDir . "\soundvolumeview-x64\readme.txt"         , false
        FileInstall, soundvolumeview-x64\SoundVolumeView.chm , % A_ScriptDir . "\soundvolumeview-x64\SoundVolumeView.chm", false
        FileInstall, soundvolumeview-x64\SoundVolumeView.exe , % A_ScriptDir . "\soundvolumeview-x64\SoundVolumeView.exe", false
    }

    ;-------------------------------------------------------------------------
    ; Delete config file
    ;
    _DeleteConfigFile() {
        FileDelete, % A_WorkingDir . "\" . this._configFile
    }

    ;-------------------------------------------------------------------------
    ; Loads config file content in:
    ;   - The hotkey code in global object ghotkeyManager
    ;   - The list of selected devices in global object gsdManager
    ; If config file version label is diferent from the script version, the
    ; config file is deleted and loaded with default values.
    ;
    LoadConfigFile() {
        global gsdManager, ghotkeyManager

        file := A_WorkingDir . "\" . this._configFile

        if FileExist(file) {
            IniRead, fileValue, %file%, GENERAL, Version, ""
            if (fileValue!=this._scriptVersion) {                                            ;If the version of the configuration file != version of the script --> delete ini file content load default values
                loadDefaults := true
                IniDelete, %file%, GENERAL
            
            } else {                                                                        ;Everything ok --> load config file content
                
                loadDefaults := false
                
                IniRead, fileValue, %file%, GENERAL, Hotkey, "CapsLock & s"
                ghotkeyManager.SetHotkey(fileValue)

                IniRead, fileValue, %file%, GENERAL, SelectedDevices, %A_Space%
                gsdManager.SelectedDevicesStringToArray(fileValue, this._delimiter)
            }
        } else {                                                                            ;No config file --> load defaults
            loadDefaults := true
        }

        if (loadDefaults) {                                                                 ;If needed to load defaults --> selected devices:=all sound devices / Hotkey is set as Caps Lock + s
            gsdManager.SelectAllDevices()
            ghotkeyManager.SetHotkey("Capslock & s")
        }

    }

    ;-------------------------------------------------------------------------
    ; Save actual values into config file
    ;
    SaveConfigFile(label:="") {

        global gsdManager, ghotkeyManager

        file := A_WorkingDir . "\" . this._configFile

        fileValue := this._scriptVersion
        IniWrite, %fileValue%, %file%, GENERAL, Version

        if (label="" or label="Hotkey") {
            IniDelete, %file%, GENERAL, Hotkey
            fileValue := ghotkeyManager.GetHotkey()
            IniWrite, %fileValue%, %file%, GENERAL, Hotkey
        }

        if (label="" or label="SelectedDevices") {
            IniDelete, %file%, GENERAL, SelectedDevices
            fileValue := gsdManager.SelectedDevicesArrayToString(this._delimiter)
            IniWrite, %fileValue%, %file%, GENERAL, SelectedDevices
        }

    }

    ;-------------------------------------------------------------------------
    ; Restore configuration to default values. To do that --> delete the
    ; config file and reload script. That way, if no config file found
    ; the script will create a new one with default values
    ;
    RestoreConfigDefaults() {
        this._DeleteConfigFile()
        Reload
        Sleep 1000
        MsgBox, The script could no be reloaded and it's going to be closed.
        ExitApp
    }

}
