#NoEnv                                                                                      ;Recommended for performance and compatibility with future AutoHotkey releases.
#Warn all,outputdebug                                                                       ;Enable warnings to assist with detecting common errors.
#SingleInstance, force                                                                      ;Only one instance running
SendMode Input                                                                              ;Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%                                                                 ;Ensures a consistent starting directory.
;@Ahk2Exe-SetMainIcon .\images\SwitchAudioOutput.ico							            ;Compiler directive for the app incon

gscriptVersion := "1.0"                                                                     ;Version number to control coherence with config.ini file

gsdManager     := new SDManager()                                                           ;Object to manage sound devices
ghotkeyManager := new HotkeyManager()                                                       ;Object to manage the hotkeys
gconfig        := new Configuration(gscriptVersion)                                         ;Object to manage program configuration
gsdManager.Init()                                                                           ;Inicialize the gsdManager
gtrayMenu      := new TrayMenu()

;-------------------------------------------------------------------------
; Includes
;
#include include\Class_Config.ahk
#include include\Class_SDManager.ahk
#include include\Class_HotkeyManager.ahk
#include include\Class_HotkeyGui.ahk
#include include\Class_SDGui.ahk
#include include\Class_TrayMenu.ahk
#include include\Common.ahk
