Class SDManager {

    ;Public variables
    _saSelectedSD     := []                                                                 ;Selected devices to switch between them
    
    ;Private variables
    _idxsaSelectedSD := 0                                                                   ;Index of the active sound device in aSelDevices

    ;--------------------------------------------------------------------------------------------------
    ;
    Init() {
        global gconfig
        gconfig.LoadConfigFile()
        this._idxsaSelectedSD := this._IdxInsaSelectedSD(this.ActiveSDName())               ;Store index of active sound device (index=0 if active device is not included en selected devices)
    }

    ;--------------------------------------------------------------------------------------------------
    ; Change active sound device to the next devices in the selected devices array (aSelDevices)
    ; If "modifier" parameter is "info" or shift key is pressed --> shows notification with the active sound device
    ; In other cases --> change the active sound device
    ;
    ChangeDevice(modifier := "") {
        global ghotkeyManager
    
        if (GetKeyState("Shift", "P") or (modifier = "info"))                               ;If shift is pressed --> show the name of the active sound device instead of changing it
            ToastNotification("The active sound device is `n" . this.ActiveSDName())

        else {

            if (this._saSelectedSD.Length()<=1) {
                text := this._saSelectedSD.Length()=0 ? "No sound devices selected" : "Only one sound device is selected"
                text .= "`n`nDo you want to select at least two sound devices?"

                msgbox, 52, %A_ScriptName% , % text , 20
                IfMsgBox, Yes
                    new SDGui()

            } else {
                if (this._idxsaSelectedSD >= this._saSelectedSD.MaxIndex())                     ;Next array index (or first if end of array has been reached)
                    this._idxsaSelectedSD := 1
                else
                    this._idxsaSelectedSD += 1

                deviceName := this._saSelectedSD[this._idxsaSelectedSD]                         ;Obtain device name
                run %A_Scriptdir%\nircmd-x64\nircmd.exe setdefaultsounddevice """%deviceName%""" ;Change sound device
                
                ToastNotification("Changed sound device to `n" . deviceName)
            }
        }
    }

    ;--------------------------------------------------------------------------------------------------
    ; Returns an associative array with all sound devices in the system
    ;
    SDArray() {
        aaSD := {}

        ;Generate a csv file with all sound devices data, unsing NirSoft SoundVolumeView
        this._CreateSoundListFile("Name,Type,Direction,DeviceName")

        FileRead, List, SoundList.csv                                                       ;Read de csv
        loop, read, SoundList.csv
        {
            if (A_Index > 1) {                                                              ;Ignore title line

                name := "" , type := "" , direction := "" , description := ""               ;Clear variables

                loop, parse, A_LoopReadLine, CSV                                            ;Parse csv line
                {
                    switch A_Index {
                    case 1:                                                                 ;Column 1: Device Name
                        name := A_LoopField
                    case 2:                                                                 ;Column 2: Type
                        type := A_LoopField
                    case 3:                                                                 ;Column 3: Direction (Render: speakers; Caputure: microphone)
                        direction := A_LoopField
                    case 4:                                                                 ;Column 4: Description
                        description := A_LoopField
                    }
                }

                if (type = "Device" and direction = "Render")                               ;Only interested in "type=devices" and "direction=render"
                    aaSD[name] := description
                    
            }
        }
        return aaSD
    }

    ;--------------------------------------------------------------------------------------------------
    ; Returns the name of the active sound device in the systema. 
    ;
    ActiveSDName() {

        ;Generate a csv file with all sound devices data, unsing NirSoft SoundVolumeView
        this._CreateSoundListFile("Name,Default")
        
        FileRead, List, SoundList.csv                                                       ;Read de csv
        loop, read, SoundList.csv
        {
            if (A_Index > 1) {                                                              ;Ignore title line

                loop, parse, A_LoopReadLine, CSV                                            ;Parse csv line
                {
                    switch A_Index {
                    case 1:                                                                 ;Column 1: Device Name
                        name := A_LoopField
                    case 2:                                                                 ;Column 2: Default
                        if (A_LoopField="Render") {
                            return name
                        }
                    }
                }
            }
        }
        return ""                                                                           ;No active sound device found
    }

    ;--------------------------------------------------------------------------------------------------
    ; Calls soundvolumeview to create the SoundList.csv file with the columns specified in the parameter
    ;
    _CreateSoundListFile(columns) {
        
        FileDelete, % A_WorkingDir . "\SoundList.csv"
        sleep 100

        run % A_ScriptDir . "\soundvolumeview-x64\SoundVolumeView.exe /scomma " . A_WorkingDir . "\SoundList.csv /Columns """ . columns . """"
        
        While !FileExist(A_WorkingDir . "\SoundList.csv")
            Sleep 100
    }

    ;--------------------------------------------------------------------------------------------------
    ; Functions to manage selected devices array

    ; Returns index of name in selected sound devices array. Zero if isn't found.
    _IdxInsaSelectedSD(name) {
        idx := 0
        for index, value in this._saSelectedSD {
            if (value = name) {
                idx := index
                break
            }
        }
        return idx
    }

    ; Number of selected devices
    NumberOfSelectedDevices() {
        return this._saSelectedSD.length()
    }

    ; "name" parameter is a selected sound device?
    IsSelected(name) {
        return (this._IdxInsaSelectedSD(name)=0) ? false : true
    }

    ; Add to selected devices array a new device
    AddSelectedDevice(name) {
        global gconfig
        if !this.IsSelected(name) {
            this._saSelectedSD.push(name)
            gconfig.SaveConfigFile("SelectedDevices")
        }
    }

    ; Remove a device from selected devices array
    RemoveSelectedDevice(name) {
        global gconfig
        
        idx := this._IdxInsaSelectedSD(name)
        if (idx!=0) {
            this._saSelectedSD.RemoveAt(idx)
            gconfig.SaveConfigFile("SelectedDevices")
        }
    }

    ; Return the selected devices array in text format
    SelectedDevicesArrayToString(delimiter) {
        return ArrayToString(this._saSelectedSD, delimiter)
    }

    ; Load the selected devices string parameter in the selectedSD array
    SelectedDevicesStringToArray(str, delimiter) {
        this._saSelectedSD := StringToArray(str, delimiter)
    }

    ; Load all sound device as selected device
    SelectAllDevices() {
        global gconfig
        for name, description in this.SDArray() {
            this._saSelectedSD.push(name)
        }
        gconfig.SaveConfigFile("SelectedDevices")
    }

    ;Returns a simple array with the names of the selected sound devices that are offline (doesn't appear in the sound devices array)
    SelectedDevicesOffline() {
        saOffline := []
        aaSDArray := this.SDArray()
        for index, name in this._saSelectedSD {
            (!aaSDArray.Haskey(name)) ? saOffline.push(name)                                ;If selected device item don't exists in sound devices array --> save it in offline array
        }        
        return saOffline
    }

}

