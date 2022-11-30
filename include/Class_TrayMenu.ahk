Class TrayMenu {

    ;Private variables
    _menuNameRunAtStartup        := "Run at Startup"

    ;-------------------------------------------------------------------------
    __New() {
        this._Create()
    }

    ;-------------------------------------------------------------------------
    Refresh() {
        Menu, Tray, DeleteAll
        this._Create()
    }

    ;-------------------------------------------------------------------------
    _Create() {
        global ghotkeyManager, gconfig
        
        hotkeyString := StrReplace(ghotkeyManager.GetHotkey(), "&", "&&")

        Menu, Tray, Icon, % A_ScriptDir . "\images\SwitchAudioOutput.ico"

        Menu, Tray, NoStandard

        menuName := "Change active sound device     (" . hotkeyString . ")"
        boundMenuChangeSoundDevices := ObjBindMethod(this, "_MenuChangeSoundDevices")
        Menu, Tray, Add, % menuName, % boundMenuChangeSoundDevices
        Menu, Tray, Icon, % menuName, % A_ScriptDir . "\images\MenuChangeSoundDevices.ico"
        
        menuName := "Show the active sound device name     (Shift && " . hotkeyString . ")"
        boundMenuShowActiveSoundDevice := ObjBindMethod(this, "_MenuShowActiveSoundDevice")
        Menu, Tray, Add, % menuName, % boundMenuShowActiveSoundDevice
        Menu, Tray, Icon, % menuName, % A_ScriptDir . "\images\MenuShowActiveSoundDevice.ico"
        
        Menu, Tray, Add

        menuName := "Select the sound devices to switch between"
        boundMenuShowSoundDevicesGui := ObjBindMethod(this, "_MenuShowSoundDevicesGui")
        Menu, Tray, Add, % menuName, % boundMenuShowSoundDevicesGui
        Menu, Tray, Icon, % menuName, % A_ScriptDir . "\images\MenuShowSoundDevicesGui.ico"
        
        menuName := "Change the hotkey"
        boundMenuSetHotkey := ObjBindMethod(this, "_MenuSetHotkey")
        Menu, Tray, Add, % menuName, % boundMenuSetHotkey
        Menu, Tray, Icon, % menuName, % A_ScriptDir . "\images\MenuSetHotkey.ico"
        
        Menu, Tray, Add

        boundMenuRunAtStartup := ObjBindMethod(this, "_MenuRunAtStartup")
        Menu, Tray, Add, % this._menuNameRunAtStartup, % boundMenuRunAtStartup
        Menu, Tray, % (gconfig.runAtStartup ? "Check" : "Uncheck"), % this._menuNameRunAtStartup

        Menu, Tray, Add

        menuName := "Reload"
        boundMenuReload := ObjBindMethod(this, "_MenuReload")
        Menu, Tray, Add, % menuName, % boundMenuReload
        Menu, Tray, Icon, % menuName, % A_ScriptDir . "\images\MenuReload.ico"
        
        menuName := "Exit"
        boundMenuExit := ObjBindMethod(this, "_MenuExit")
        Menu, Tray, Add, % menuName, % boundMenuExit
        Menu, Tray, Icon, % menuName, % A_ScriptDir . "\images\MenuExit.ico"
    }

    ;-------------------------------------------------------------------------
    _MenuChangeSoundDevices() {
        global gsdManager
        gsdManager.ChangeDevice("")
    }

    ;-------------------------------------------------------------------------
    _MenuShowActiveSoundDevice() {
        global gsdManager
        gsdManager.ChangeDevice("info")
    }

    ;-------------------------------------------------------------------------
    _MenuShowSoundDevicesGui() {
        new SDGui()
    }

    ;-------------------------------------------------------------------------
    _MenuRunAtStartup() {
        global gconfig
        
        gconfig.runAtStartup := !gconfig.runAtStartup
        Menu, Tray, % (gconfig.runAtStartup ? "Check" : "Uncheck"), % this._menuNameRunAtStartup
    }

    ;-------------------------------------------------------------------------
    _MenuSetHotkey() {
        global ghotkeyManager
        new HotkeyGui(ghotkeyManager.GetHotkey())
    }

    ;-------------------------------------------------------------------------
    _MenuReload() {
        Reload
    }

    ;-------------------------------------------------------------------------
    _MenuExit() {
        ExitApp
    }

}