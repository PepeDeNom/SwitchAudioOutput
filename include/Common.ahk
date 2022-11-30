; Common functions

;-------------------------------------------------------------------------
; Convert a string into a simple array
;
StringToArray(str, delimiter) {
    aArray := []
	StrLen(str)!=0 ? aArray:=StrSplit(str, delimiter)
    return aArray
}

;-------------------------------------------------------------------------
; Convert a simple array into a string
;
ArrayToString(aArray, delimiter) {
    str := ""
	for index, value in aArray {
		str .= (str="" ? "" : delimiter) . value
	}
	return str
}

;-------------------------------------------------------------------------
; Show a toast notification
;
ToastNotification(text) {

    ;Hide last notification in case it is visible
    TrayTip  ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion,1,3) = "10." {
        Menu Tray, NoIcon
        Sleep 200  ; It may be necessary to adjust this sleep.
        Menu Tray, Icon
    }
    
    ;Show notification
    TrayTip, , %text%, 5, 0x1 + 0x10
}

;-------------------------------------------------------------------------
; Create folder (path without last "\")
;
CreateFolder(path, folder) {
    if !FileExist(path . "\" . folder) {                                                    ;Create images directory in working dir in case it doesn´t exist
        FileCreateDir, % path . "\" . folder
        if ErrorLevel {
            MsgBox, % "Error creating directory: " . path . "\" . folder
            ExitApp
        }
    }
}
