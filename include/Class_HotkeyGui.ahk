Class HotkeyGui {
    ;Private variables
    _hGui := 0                                                                              ;Gui handle
    _hEd := 0                                                                               ;Listview handle
    _hotkeyString := 0                                                                      ;Current hotkey

    ;-------------------------------------------------------------------------
    __New(hotkeyString) {
        global gsdManager
        this._hotkeyString := hotkeyString
        this._GuiCreate()
        this._GuiShow()
    }

    ;-------------------------------------------------------------------------
    _GuiCreate() {
        global gsdManager

        helpText := "You can define the hotkey using AUTOHOTKEY syntax" . "`n`n"
        helpText .= "Examples: (notice the spaces before and after the &&)" . "`n"
        helpText .= "   Shift && s  or   +s" . "`n"
        helpText .= "   Ctrl && o   or   ^o" . "`n"
        helpText .= "   LWin && z   or   #z" . "`n"
        helpText .= "   Alt && 1    or   !1 (""1"" in the number row keys)" . "`n"
        helpText .= "   Alt && Numpad1 (""Numpad1"" is the 1 in the numpad keys)" . "`n"
        helpText .= "   Capslock && s (this is the default hotkey)" . "`n`n"

        
        ;Create gui
        Gui, New, +hwndhGui
        Gui, Margin, 0, 0
        Gui, Color,, DEDEDE
        Gui, Font, s12, Microsoft Sans Serif
        Gui, Add, Text, x45 y30 w340 h30, Hotkey to switch between sound devices 
        Gui, Font, s10, Microsoft Sans Serif
        Gui, Add, Edit, r1 x80 y60 w270 h20 +Left hWndhEd, % this._hotkeyString
        Gui, Font, s10, Microsoft Sans Serif
        Gui, Add, GroupBox, x12 y110 w425 h270 , Help
        Gui, Font, s9, Courier New ;Microsoft Sans Serif
        Gui, Add, Text, x21 y145 w400 h150 , %helpText%
        Gui, Add, Link, y+20, More info about this syntax in Autohotkey documentation:
        Gui, Add, Link, , <a href="https://www.autohotkey.com/docs/Hotkeys.htm">https://www.autohotkey.com/docs/Hotkeys.htm</a>.
        Gui, Add, Button, x120 y390 w100 h30 hWndhBtnSave default, Save
        Gui, Add, Button, x240 y390 w100 h30 hWndhBtnCancel, Cancel
        
        ;Bind buttons functions
        func := ObjBindMethod(this, "_BtnSave")
        Guicontrol +g, %hBtnSave%, %func%
        func := ObjBindMethod(this, "_BtnCancel")
        Guicontrol +g, %hBtnCancel%, %func%

        ;Save handles in object variables
        this._hGui := hGui
        this._hEd  := hEd
    }

    ;-------------------------------------------------------------------------
    _GuiShow() {
        hGui := this._hGui
        Gui, %hGui%:Show, x1649 y335 h432 w450, Define hotkey
    }

    ;-------------------------------------------------------------------------
    GuiClose(guiHwnd) {
        if guiHwnd = this._hGui
            Gui, %guiHwnd%:Destroy
    }

    ;-------------------------------------------------------------------------
    _BtnSave() {
        global ghotkeyManager, gtrayMenu
        
        hEd := this._hEd
        ControlGetText, str, , ahk_id %hEd%
        
        if (this._hotkeyString = str) {                                                     ;If hotkey has no changes, nothing to do
            this._DestroyGui()
        
        } else if (ghotkeyManager.SetHotkey(str)) {                                         ;Set new hotkey and destroy gui if everithing is ok (if problem found, SetHotkey gives user a msg)
            this._DestroyGui()
            gtrayMenu.Refresh()                                                             ;Show new hotkey
        }
    }

    ;-------------------------------------------------------------------------
    _BtnCancel() {
        hGui := this._hGui
        Gui, %hGui%:Destroy
    }

    ;-------------------------------------------------------------------------
    _DestroyGui() {
        hGui := this._hGui
        Gui, %hGui%:Destroy
    }

}