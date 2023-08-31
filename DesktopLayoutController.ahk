; For the ColorBox Reference https://www.autohotkey.com/boards/viewtopic.php?t=15787
; For adding the ColorBox script as a library go to you AutoHotKey directory and create a folder named
; lib in the same directory as AutoHotkey.exe and add the ColorBox.ahk script to this folder
; Or you can directly give the path to ColorBox.ahk file's path like:
; #Include FileOrDirName
; I Would suggest changing the target_dir due to temp files get deleted often

#Include %A_ScriptDir%\ColorBox.ahk

if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

target_dir = %A_Temp%\desktop_layout.reg
res := ColorBox("Desktop Layout Controller","Do you want to save the current desktop layout or load the previous desktop layout ?",2,0,1,"Save","Load")

If (res = 0)
{
    if !FileExist(target_dir)
    {
        ColorBox(,"The file doesn't exists creating layout",1,0,1,"OK")
        RunWait, regedit.exe /e %target_dir% HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop
        ExitApp
    }
    LoadFromSavedLayout(target_dir)
}
else
{
    if FileExist(target_dir)
    {
        res := ColorBox(" Duplicate Conflict","There is already another layout saved in the target directory.`n Choose Action to solve the conflict",2,0,1,"Cancel","Override")
        If (res = 0)
        {
            FileDelete, target_dir
            RunWait, regedit.exe /e %target_dir% HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop
        }
    }
    else
    {
        RunWait, regedit.exe /e %target_dir% HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop
        ExitApp
    }
}

ExitApp

LoadFromSavedLayout(directory)
{
    Run %directory%,,Min
    WinWait, "ahk_exe regedit.exe",, 0.15

    if WinExist("ahk_exe regedit.exe")
    {
        WinActivate
        WinGetActiveTitle, Title
        Sleep, 100
        SetControlDelay -1
        ControlClick, Button1, ahk_exe regedit.exe, ,Left, 1
        Sleep, 100
        SetControlDelay -1
        ControlClick, Button1, ahk_exe regedit.exe, ,Left, 1
        Sleep, 100
        Runwait TASKKILL /F /IM explorer.exe
        Run explorer.exe
    }
}