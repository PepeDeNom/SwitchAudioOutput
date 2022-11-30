Class SDGui {

    ;Private variables
    _hGui := 0                                                                              ;Gui handle
    _hLv:= 0                                                                                ;Listview handle

    ;-------------------------------------------------------------------------
    __New() {
        this._GuiCreate()
        this._LoadDevices()
        this._GuiShow()
    }

    ;-------------------------------------------------------------------------
    _GuiCreate() {
        global ghotkeyManager

        ;Create gui
        Gui, New, +hwndhGui
        Gui, Margin, 0, 0
        Gui, Font, s10, Microsoft Sans Serif
        Gui, Color,, DEDEDE
        Gui, Add, Text,x5 y16, % "Select at least two sound devices to be able to switch between them with hotkey """ .  StrReplace(ghotkeyManager.GetHotkey(), "&", "&&") . """"
        
        ;Create listview
        Gui, Font, s10, Microsoft Sans Serif
        Gui, Add, ListView, x0 y50 w700 r10 AltSubmit Checked +Grid +Sort hWndhLv, Name|Description
        eventManagerFunction := ObjBindMethod(this, "_EventManager")
        Guicontrol +g, %hLv%, %eventManagerFunction%                                        ;Bind event manager method
        LV_ModifyCol( 1, 300), LV_ModifyCol( 2, 400)

        ;Save handles in object variables
        this._hGui := hGui
        this._hLv  := hLv
    }

    ;-------------------------------------------------------------------------
    _GuiShow() {
        hGui := this._hGui
        Gui, %hGui%:Show, , Sound devices
    }

    ;-------------------------------------------------------------------------
    GuiClose(guiHwnd) {
        if guiHwnd = this._hGui
            Gui, %guiHwnd%:Destroy
    }

    ;-------------------------------------------------------------------------
    ; Load sound devices listview
    ;
    _LoadDevices(){
        global gsdManager

        aaSD := gsdManager.SDArray()                                                        ;Obtain array with all sound devices
        hGui := this._hGui
        hLv  := this._hLv
        Gui, %hGui%:Default                                                                 ;Default gui to work with
        Gui, ListView, %hLv%                                                                ;Default listview to work with
        LV_Delete()                                                                         ;Clear listview
        for name, description in aaSD {                                                     ;Load sound devices and activate check of devices included in selected devices array
            LV_Add( "", name, description)
            
            if gsdManager.IsSelected(name) {                                                ;Check if it's in selected devices
                LV_Modify(A_Index, "Check")
            }
        }

        saOffline := gsdManager.SelectedDevicesOffline()                                    ;If there are selected devices offline (don't exists in sound devices array "aaSD") --> add them to the listview
        if saOffline.length() > 0 {
            for index, name in saOffline {
                LV_Add( "Check", name, "*** This device is offline ***")
            }
        }
    }

    ;-------------------------------------------------------------------------
    ; Manage Check / Uncheck events in sound devices listview
    ;
    _EventManager() {
        global gconfig, gsdManager

        if (A_GuiEvent == "I") {                                                            ; Item change event ("=="->Case sensitive equal)
            
            LV_GetText(name, A_EventInfo, 1)

            if InStr(ErrorLevel, "C", true) {                                               ;User check a device
                gsdManager.AddSelectedDevice(name)
            
            } else if InStr(ErrorLevel, "c", true) {                                        ;User unchecked a device
                gsdManager.RemoveSelectedDevice(name)
            }
        }
    }

}