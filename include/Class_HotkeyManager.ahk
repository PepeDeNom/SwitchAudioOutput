Class HotkeyManager {

    ;Private variables
    _hotKeyString    := ""

    ;--------------------------------------------------------------------------------------------------
    GetHotkey() {
        return this._hotKeyString
    }

    ;--------------------------------------------------------------------------------------------------
    SetHotkey(newHotKeyString) {
        global gconfig, gsdManager
        
        newHotKeyString := StrReplace(newHotKeyString, """")                                ;Delete "
        boundChangeDevice := ObjBindMethod(gsdManager, "ChangeDevice")                      ;Method to activate with the hotkey
        
        Hotkey, % newHotKeyString, % boundChangeDevice, On UseErrorLevel                    ;Create hotkey and link to 
        if (!ErrorLevel) {
            if (this._hotKeyString<>"" and this._hotKeyString<>newHotKeyString) {           ;Deactivate old hotkey if necesary (if it exists and if it's diferent from the new one)
                oldHotkey := this._hotKeyString
                Hotkey, %oldHotkey%, Off
            }
                
            this._hotKeyString := newHotKeyString 
            gconfig.SaveConfigFile("Hotkey")
            return true

        } else {                                                                            ;Invalid hotkey. Try to restore last valid hotkey
            bError := true
            Msgbox, 16, A_ScriptName, % "ERROR: """ . newHotKeyString . """ is not a valid hotkey. Check the syntax."
            
            if (this._hotKeyString != "") {                                                 ;If we have a previous hotkey
                Hotkey, % this._hotKeyString, % boundChangeDevice, On UseErrorLevel         ;try to restore it
                if (!ErrorLevel)  {
                    bError := false                                                         ;No error, previous hotkey restored
                } else {
                    Msgbox, 16, A_ScriptName, % "ERROR restoring previous hotkey """ . this._hotKeyString . """"
                }
            }

            if (bError) {                                                                   ;If the error couldn't be solved --> ask user to restore config to a stable state
                Msgbox, 20, A_ScriptName, % "FATAL ERROR`n`nReturn script configuration to a stable state?"
                IfMsgBox Yes
                    gconfig.RestoreConfigDefaults()                                         ;Restore default values and RELOAD script

                ;If user don't want to restore config file to a stable state --> Exit script, 
                Msgbox, 20, A_ScriptName, % "SCRIPT TERMINATED.`n`nCheck the value of ""Hotkey"" label in ""config.ini"" file at `n" . A_WorkingDir . "`n`nDo you wan't to open that folder?"
                IfMsgBox Yes
                    Run, explore %A_WorkingDir%

                ExitApp
            }
            return false
        }
    }


}