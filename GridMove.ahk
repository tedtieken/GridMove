; <COMPILER: v1.0.48.5>






  MButtonDrag := True
  LButtonDrag := True
  EdgeDrag := True
  EdgeTime := 500
  ShowGroupsFlag := True
  ShowNumbersFlag := True
  TitleSize := 100
  GridName = Grids/3-part.grid
  GridOrder = 2 Part-Vertical,3-Part,EdgeGrid,Dual-Screen
  UseCommand := True
  CommandHotkey = #g
  UseFastMove := True
  FastMoveModifiers = #
  Exceptions = QuarkXPress,Winamp v1.x,Winamp PE,Winamp Gen,Winamp EQ,Shell_TrayWnd,32768,Progman,DV2ControlHost
  MButtonExceptions = inkscape.exe
  MButtonTimeout = 0.3
  Transparency = 200
  SafeMode := True
  FastMoveMeta =
  SequentialMove := False
  DebugMode := False
  StartWithWindows := False
  DisableTitleButtonsDetection := False
  MOVETOHERE = 0
  

  ScriptVersion = 1.19.62

  Sysget, CaptionSize,4
  Sysget, BorderSize, 46
  CaptionSize += BorderSize

  TitleLeft := CaptionSize

  if DebugMode
    Traytip,GridMove,Reading INI,10

  GetScreenSize()
  GetMonitorSizes()
  RectangleSize := 1
  ComputeEdgeRectangles()
  OSDcreate()
  GoSub, ReadIni
  GoSub, ResetMoveTo
  SetWinDelay, 0
  SetBatchLines, -1

  If 0 = 1
    GridName = %1%

  if DebugMode
    Traytip,GridMove,Creating the templates menu,10


  Menu, Tray, Add, About/Help, AboutHelp
  Menu, Tray, Default, About/Help
  Menu, Tray, Tip, GridMove V%ScriptVersion%
  Menu, Tray, Add, Check For Updates!, EnableAutoUpdate
  Menu, Tray, Add, Ignore/Unignore window..., AddToIgnore

  Menu, Tray, Add, Start With Windows, StartWithWindowsToggle

  GoSub,StartWithWindowsDetect
  if(startwithwindows)
    Menu,Tray,Check, Start With Windows
  else
    Menu,Tray,UnCheck, Start With Windows

  CreateTemplatesMenu()
  Menu, Tray, Add, Templates, :Templates
  IfExist %A_ScriptDir%\Images\gridmove.ico
    Menu, Tray, Icon,%A_ScriptDir%\Images\gridmove.ico
  Menu, Tray, NoStandard

  if DebugMode
    Traytip,GridMove,Creating the options tray menu,10

  CreateOptionsMenu()
  Menu, Tray, Add, Options, :Options
  CreateHotkeysMenu()
  Menu, Tray, Add, Hotkeys, :Hotkeys
  Menu, Tray, Add, Restart, ReloadProgram
  Menu, Tray, Add, Exit, ExitProgram

  if DebugMode
    Traytip,GridMove,Reading the grid file,10

  GoSub, ApplyGrid

  Mutex := False
  GroupsShowing := False
  EdgeFlag := True
  MousePositionLock := False
  WM_ENTERSIZEMOVE = 0x231
  WM_EXITSIZEMOVE = 0x232


  WindowY =
  WindowX =
  WindowWidth =
  WindowHeight=
  WindowXBuffer =
  WindowYBuffer =






  if DebugMode
    Traytip,GridMove,Registering Hotkeys...,10


  If UseCommand
    Hotkey, %CommandHotkey%, Command

  If MButtonDrag
    Hotkey, MButton, MButtonMove

  If UseFastMove
    GoSub,DefineHotkeys

  if SequentialMove
  {
    Hotkey, %FastMoveModifiers%Right,MoveToNext
    Hotkey, %FastMoveModifiers%Left,MoveToPrevious
  }

  MPFlag := True
  Settimer, MousePosition, 100


  HotKey,RButton,NextGrid
  HotKey,RButton,off
  HotKey,Esc,cancel
  HotKey,Esc,off
  HotKey,F12,AddCurrentToIgnore
  HotKey,F11,AddCurrentToIgnoreCancel
  HotKey,F12,off
  HotKey,F11,off

#maxthreadsperhotkey,1
#singleinstance,force
#InstallMouseHook
#InstallKeybdHook
#noenv



  if DebugMode
    Traytip,GridMove,Start process completed,10


  SetBatchLines, 20ms
return



DropZoneMode:
  DropZoneModeFlag := true
  gosub,showgroups
  Hotkey,RButton,on
  Hotkey,Esc,on
  Canceled := False
  CoordMode,Mouse,Screen
  loop
  {
    If Canceled
      {
      Critical, on
      Gui,2:Hide
      Hotkey,RButton,off
      Hotkey,Esc,off
      DropZoneModeFlag := false
      Critical, off
      return
      }

    GetKeyState,State,%hotkey%,P
    If State = U
        break

    MouseGetPos, MouseX, MouseY, window,
    flagLButton:=true
    Critical, on
    SetBatchLines, 10ms
    loop,%NGroups%
    {
      TriggerTop    := %A_Index%TriggerTop
      TriggerBottom := %A_Index%TriggerBottom
      TriggerRight  := %A_Index%TriggerRight
      TriggerLeft   := %A_Index%TriggerLeft

      If (MouseY >= TriggerTop AND MouseY <= TriggerBottom
          AND MouseX <= TriggerRight AND MouseX >= TriggerLeft)
      {
        GetGrid(A_Index)

        If (GridTop = "AlwaysOnTop" OR GridTop = "Run")
        {
          GridTop := TriggerTop
          GridLeft := TriggerLeft
          GridWidth := TriggerRight - TriggerLeft
          GridHeight := TriggerBottom - TriggerTop
        }
        If (GridTop = "Maximize")
        {
          GridTop := GetMonitorTop(MouseX,MouseY)
          GridLeft := GetMonitorLeft(MouseX,MouseY)
          GridWidth := GetMonitorRight(MouseX,MouseY) - GetMonitorLeft(MouseX,MouseY)
          GridHeight := GetMonitorBottom(MouseX,MouseY) - GetMonitorTop(MouseX,MouseY)
        }

        If not canceled
        {
          GridLeft := Floor(GridLeft)
          GridTop := Floor(GridTop)
          GridWidth := Floor(GridWidth)
          GridHeight := Floor(GridHeight)
          Gui, 2: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
          Gui, 2:show, x%GridLeft% y%GridTop% w%GridWidth% h%GridHeight% NoActivate
        }
        flagLButton:=false
        break
      }
    }
    Critical, off
    if flagLButton
      Gui,2:Hide
  }
  DropZoneModeFlag := false
  Gui,2:Hide
  Hotkey,RButton,off
  Hotkey,Esc,off
  GoSub,SnapWindow
  Gosub,hidegroups
return

cancel:
  if not canceled
  {
    canceled := True
    GoSub, HideGroups
    Gui,2:Hide
  }
return



MButtonMove:
  CoordMode,Mouse,Screen
  MouseGetPos, OldMouseX, OldMouseY, Window,
  WinGetTitle,WinTitle,ahk_id %Window%
  WinGetClass,WinClass,ahk_id %Window%
  WinGetPos,WinLeft,WinTop,WinWidth,WinHeight,ahk_id%Window%
  WinGet,WinStyle,Style,ahk_id %Window%
  WinGet,WindowId,Id,ahk_id %Window%
  WinGet, WindowProcess , ProcessName, ahk_id %Window%

  if SafeMode
  {
    if not (WinStyle & 0x40000)
    {
      sendinput,{MButton down}
      Keywait,mbutton
      sendinput,{MButton up}
      Return
    }
  }
  If Winclass in %Exceptions%
  {
    sendinput,{MButton down}
    Keywait,mbutton
    sendinput,{MButton up}
    Return
  }
  If WindowProcess in %MButtonExceptions%
  {
    sendinput,{MButton down}
    Keywait,mbutton
    sendinput,{MButton up}
    Return
  }
  KeyWait,MButton,T%MButtonTimeOut%
  if errorlevel = 0
  {
    sendinput,{MButton}
    return
  }

  Winactivate, ahk_id %window%
  Hotkey = MButton
  GoSub, DropZoneMode
  return



MousePosition:
  Settimer, MousePosition,off

  if MousePositionLock
    return

  KeyWait, LButton,U
  KeyWait, LButton,D

  SetBatchLines, -1

  CoordMode,Mouse,Relative
  MouseGetPos,OldMouseX,OldMouseY,MouseWin, MouseControl
  WinGetTitle,Wintitle,ahk_id %mousewin%
  WinGetClass,WinClass,ahk_id %mousewin%
  WinGetPos,WinLeft,WinTop,WinWidth,WinHeight,ahk_id%MouseWin%
  WinGet,WinStyle,Style,ahk_id %mousewin%
  WinGet,WindowId,Id,ahk_id %mousewin%

  If Winclass in %Exceptions%
  {
    Settimer, MousePosition,10
    Return
  }

  if SafeMode
    if not (WinStyle & 0x40000)
    {
      Settimer, MousePosition,10
      Return
    }

  If (OldMouseY > CaptionSize OR OldMouseY <= BorderSize + 1 OR WinTitle = "" )
  {
    Settimer, MousePosition,10
    return
  }

  if(WinWidth > 3 * TitleSize)
  {
    If (TitleSize < WinWidth - 100 AND LButtonDrag
        AND OldmouseX > TitleLeft AND OldMouseX < TitleSize
  AND (MouseControl = "" OR DisableTitleButtonsDetection))
    {
      Hotkey = LButton
      sendinput {LButton up}
      GoSub,DropZoneMode
      Settimer, MousePosition,10
      return
    }
  }
  else
  {
    If (LButtonDrag AND OldmouseX > TitleLeft
        AND OldMouseX < TitleLeft + 20 AND WinWidth > 170
        AND (MouseControl = "" OR  DisableTitleButtonsDetection))
    {
      Hotkey = LButton
      sendinput {LButton up}
      GoSub,DropZoneMode
      Settimer, MousePosition,10
      return
    }
  }

  if not EdgeDrag
  {
    settimer, MousePosition,10
    return
  }

  SetBatchLines, 10ms

  CoordMode,Mouse,Screen
  EdgeFlag := true
  SetTimer, EdgeMove, Off
  loop
  {
    MouseGetPos, MouseX, MouseY

    GetKeyState, State, LButton, P
    If (state = "U" or MousePositionLock)
    {
      SetTimer, EdgeMove, Off
      Settimer, MousePosition,10
      return
    }

    EdgeFlagFound := false
    loop,%RectangleCount%
    {
      if(mouseX >= EdgeRectangleXL%A_Index% && mouseX <= EdgeRectangleXR%A_Index%
          && mouseY >= EdgeRectangleYT%A_Index% && mouseY <= EdgeRectangleYB%A_Index%)
      {
        EdgeFlagFound := true
        break
      }
    }

    if EdgeFlagFound
    {
      if EdgeFlag
      {
        settimer, EdgeMove, %EdgeTime%
        EdgeFlag := False
      }
    }
    else
    {
      SetTimer, EdgeMove, Off
      EdgeFlag := True
    }

    sleep,100

  }
return

edgemove:
  SetTimer, EdgeMove, Off
  HotKey = LButton
  sendinput, {LButton up}
  MousePositionLock := true
  SetBatchLines, -1
  GoSub,DropZoneMode
  MousePositionLock := false
  EdgeFlag := True
  Settimer, MousePosition,10
return



SnapWindow:
  sendinput, {LButton up}
  CoordMode,Mouse,Screen
  Moved := False
  loop %NGroups%
  {
    triggerTop    := %A_Index%TriggerTop
    triggerBottom := %A_Index%TriggerBottom
    triggerRight  := %A_Index%TriggerRight
    triggerLeft   := %A_Index%TriggerLeft

    GridBottom :=0
    GridRight  :=0
    GridTop    :=0
    GridLeft   :=0


    If (MouseY >= triggerTop AND MouseY <= triggerBottom
        AND MouseX <= triggerRight AND MouseX >= triggerLeft)
    {
      GetGrid(A_Index)

      If GridTop = AlwaysOnTop
      {
        WinSet, AlwaysOnTop, Toggle,A
        return
      }
      If GridTop = Maximize
      {
        winget,state,minmax,A
        if state = 1
          WinRestore,A
        else
          PostMessage, 0x112, 0xF030,,, A,
        return
      }
      If GridTop = Run
      {
        Run,%GridLeft% ,%GridRight%
        return
      }

      WinRestore,A
      Moved := True

      if ShouldUseSizeMoveMessage(WinClass)
        SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

      WinMove, ahk_id %windowid%, ,%GridLeft%,%GridTop%,%GridWidth%,%GridHeight%,

      if ShouldUseSizeMoveMessage(WinClass)
        SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%
      break
    }
  }
  If Moved
    StoreWindowState(WindowID,WinLeft,WinTop,WinWidth,WinHeight)
  gosub, hidegroups
return

GetGrid(number)
{
  global

  MouseGetPos, MouseX, MouseY, window,

  GridTop := %number%GridTop
  GridBottom := %number%GridBottom
  GridRight := %number%GridRight
  GridLeft := %number%GridLeft

  TriggerTop := %number%TriggerTop
  TriggerBottom := %number%TriggerBottom
  TriggerRight := %number%TriggerRight
  TriggerLeft := %number%TriggerLeft

  if GridTop in run,maximize,AlwaysOnTop
    return

  If GridTop = WindowHeight
  {
    MonitorBottom := GetMonitorBottom(MouseX, MouseY)
    GridTop := MouseY
    If (GridTop + WinHeight > MonitorBottom)
      GridTop := MonitorBottom - WinHeight
    GridBottom := GridTop + WinHeight
  }

  If GridLeft = WindowWidth
  {
    MonitorRight := GetMonitorRight(MouseX, MouseY)
    GridLeft := MouseX
    If (GridLeft + WinWidth > MonitorRight)
      GridLeft := MonitorRight - WinWidth
    GridRight := GridLeft + WinWidth
  }

  If GridTop = restore
  {
    data := GetWindowState(WindowID)
    If data
    {
      GridLeft   := WindowX
      GridRight  := WindowX + WindowWidth
      GridTop    := WindowY
      GridBottom := WindowY + WindowHeight
    }
    else
    {
      GridLeft   := WinLeft
      GridRight  := WinLeft + WinWidth
      GridTop    := WinTop
      GridBottom := WinTop + WinHeight
    }
  }

  if (GridTop = "Current")
    GridTop := WinTop
  else
    GridTop := round(GridTop)

  if (GridLeft = "Current")
    GridLeft := WinLeft
  else
    GridLeft := round(GridLeft)

  if (GridRight = "Current")
    GridRight := WinLeft + WinWidth
  else
    GridRight := round(GridRight)

  if(GridBottom = "Current")
    GridBottom := WinTop + WinHeight
  else
    GridBottom := round(GridBottom)

  GridWidth  := GridRight - GridLeft
  GridHeight := GridBottom - GridTop
}




showgroups:
  if not ShowGroupsFlag
    return
  Gui,+ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  WinSet, AlwaysOnTop, On,ahk_id %GuiId%
  Gui,Show, X%ScreenLeft% Y%ScreenTop% W%ScreenWidth% H%ScreenHeight% noactivate,GridMove Drop Zone

  GroupsShowing := True
  return

Hidegroups:
  Gui,hide
  return

creategroups:
  gui,destroy
  Gui, Font, s15 cRed, Tahoma
  loop,%NGroups%
  {
    TriggerTop    := %A_Index%TriggerTop - ScreenTop
    TriggerBottom := %A_Index%TriggerBottom - ScreenTop
    TriggerLeft   := %A_Index%TriggerLeft - ScreenLeft
    TriggerRight  := %A_Index%TriggerRight - ScreenLeft
    TriggerHeight := TriggerBottom - TriggerTop
    TriggerWidth  := TriggerRight - TriggerLeft
    GridTop       := %A_Index%GridTop
    GridLeft      := %A_Index%GridLeft

    TextTop := %A_Index%TriggerTop - ScreenTop
    TextTop += Round((%A_Index%TriggerBottom - %A_Index%TriggerTop) / 2 )- 11
    TextLeft := %A_Index%TriggerLeft - ScreenLeft
    TextLeft += Round((%A_Index%TriggerRight - %A_Index%TriggerLeft) / 2) - 5
    RestoreLeft := TextLeft - 50
    Gui, add, Picture, Y%TriggerTop%    X%TriggerLeft% W%TriggerWidth% H1 ,%A_ScriptDir%\Images\Grid.bmp
    Gui, add, Picture, Y%TriggerBottom% X%TriggerLeft% W%TriggerWidth% H1 ,%A_ScriptDir%\Images\Grid.bmp
    Gui, add, Picture, Y%TriggerTop% X%TriggerLeft%  W1 H%TriggerHeight% ,%A_ScriptDir%\Images\Grid.bmp
    Gui, add, Picture, Y%TriggerTop% X%TriggerRight% W1 H%TriggerHeight% ,%A_ScriptDir%\Images\Grid.bmp

    shadowleft := textleft + 1
    shadowtop := texttop + 1
    If ShowNumbersFlag
      If GridTop is number
        If GridLeft is number
          If A_Index < 10
          {
            Gui, add, text, BackGroundTrans c000000 X%ShadowLeft% Y%ShadowTop% ,%A_Index%
            Gui, add, text, BackGroundTrans cFFD300 X%TextLeft% Y%TextTop% ,%A_Index%
          }
          else
          {
            Gui, add, text,% "X" ShadowLeft - 6 " Y" ShadowTop " c000000 BackGroundTrans" ,%A_Index%
            Gui, add, text,% "X" TextLeft - 6 " Y" TextTop " cFFD300 BackGroundTrans" ,%A_Index%
          }


    RestoreLeftShadow := RestoreLeft + 1
    RestoreUndo := RestoreLeft + 20
    RestoreUndoShadow := RestoreUndo + 1

    If ShowNumbersFlag
    {
      If (GridTop = "WindowHeight" OR GridLeft = "WindowWidth")
      {
        Gui, add, text,c000000 BackGroundTrans  X%ShadowLeft% Y%ShadowTop% ,%A_Index%
        Gui, add, text,cFFD300 BackGroundTrans  X%TextLeft% Y%TextTop% ,%A_Index%
      }
      If Gridtop = Restore
      {
        Gui, add, text,c000000 BackGroundTrans  X%RestoreUndoShadow% Y%ShadowTop% ,%A_Index%-Undo
        Gui, add, text,cFFD300 BackGroundTrans  X%RestoreUndo% Y%TextTop% ,%A_Index%-Undo
      }
      If GridTop = Maximize
      {
        Gui, add, text,c000000 BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%A_Index%-Maximize
        Gui, add, text,cFFD300 BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%A_Index%-Maximize
      }
      If GridTop = AlwaysOnTop
      {
        Gui, add, text,c000000 BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%A_Index%-On Top
        Gui, add, text,cFFD300 BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%A_Index%-On Top
      }
    }
    else
    {
      If Gridtop = Restore
      {
        Gui, add, text,c000000 BackGroundTrans  X%RestoreUndoShadow% Y%ShadowTop% ,Undo
        Gui, add, text,cFFD300 BackGroundTrans  X%RestoreUndo% Y%TextTop% ,Undo
      }
      If GridTop = Maximize
      {
        Gui, add, text,c000000 BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,Maximize
        Gui, add, text,cFFD300 BackGroundTrans  X%RestoreLeft% Y%TextTop% ,Maximize
      }
      If GridTop = AlwaysOnTop
      {
        Gui, add, text,c000000 BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,On Top
        Gui, add, text,cFFD300 BackGroundTrans  X%RestoreLeft% Y%TextTop% ,On Top
      }
    }

    If Gridtop = Run
    {
      GridBottom := %A_Index%GridBottom
      GridLeft := %A_Index%GridLeft

      If ShowNumbersFlag
      {
        If (%A_Index%GridBottom != "")
        {
          Gui, add, text,c000000 BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%A_Index%-%GridBottom%
          Gui, add, text,cFFD300 BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%A_Index%-%GridBottom%
        }
        else
        {
          Gui, add, text,c000000 BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%A_Index%-%GridLeft%
          Gui, add, text,cFFD300 BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%A_Index%-%GridLeft%
        }
      }else
      {
        If (%A_Index%GridBottom != "")
        {
          Gui, add, text,c000000 BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%GridBottom%
          Gui, add, text,cFFD300 BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%GridBottom%
        }
        else
        {
          Gui, add, text,c000000 BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%GridLeft%
          Gui, add, text,cFFD300 BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%GridLeft%
        }
      }
    }
  }
  Gui, +AlwaysOnTop +ToolWindow -Caption +LastFound +E0x20
  Gui, Color, EEAA99
  Gui, Margin,0,0

  Gui,show,x0 y0 w0 h0 noactivate,GridMove Drop Zone 0xba
  WinGet,GuiId,Id,GridMove Drop Zone 0xba
  WinSet, TransColor, EEAA99, ahk_id %GuiId%

  Gui,2: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  Gui,2: Margin,0,0
  Gui,2: +lastfound
  WinSet, Transparent, %Transparency%,
  Gui,hide
return



ExitProgram:
  ExitApp
return

ReloadProgram:
  Reload
return

RefreshTemplates:
  Menu,Templates,DeleteAll
  CreateTemplatesMenu()
return

CreateTemplatesMenu()
{
  global GridName
  Loop,%A_ScriptDir%\Grids\*.grid
  {
    StringTrimRight,out_GridName2,A_LoopFileName,5
    Menu, Templates, add, %out_GridName2%    ,Template-Grids
  }
  Menu, Templates, add,-Refresh this list-, RefreshTemplates

  stringgetpos,out_pos,gridname,\,R1
  if out_pos <= 0
    stringgetpos,out_pos,gridname,/,R1
  if out_pos <= 0
    return
  stringlen, len, gridname
  StringRight,out_GridName,gridname,% len - out_pos -1
  StringTrimRight,out_GridName2,out_GridName,5
  IfExist %A_ScriptDir%\Grids\%out_GridName2%.grid
    menu,templates,check,%out_GridName2%
  }

CreateHotkeysMenu()
{
  global UseCommand
  global CommandHotKey
  global UseFastMove
  global FastMoveModifiers
  Menu, Hotkeys, add, Use Command, Hotkeys_UseCommand
  Menu, Hotkeys, add, Command Hotkey, Hotkeys_CommandHotkey
  Menu, Hotkeys, add, Use Fast Move, Hotkeys_UseFastMove
  Menu, Hotkeys, add, Fast Move Modifiers, Hotkeys_FastMoveModifiers
  If UseCommand
    Menu,Hotkeys,check, Use Command
  else
    Menu,Hotkeys,Disable, Command Hotkey,
  If UseFastMove
    Menu,Hotkeys,check, Use Fast Move
  else
    Menu,Hotkeys,Disable, Fast Move Modifiers
}

Hotkeys_UseCommand:
  If UseCommand
      UseCommand := False
  else
      UseCommand := True
  GoSub,WriteIni
  Reload
return


Hotkeys_UseFastMove:
  If UseFastMove
      UseFastMove := False
  else
      UseFastMove := True
  GoSub,WriteIni
  Reload
return

Hotkeys_CommandHotkey:
  inputbox,input, Input the hotkey, Select the hotkey you'd like to use to make GridMove go into Command Mode. ^ stands for ctrl`, + stands for shift`, ! stands for alt and # stands for Windows key.`nE.G.: ^#g stands for ctrl+win+g. Notice that the order of the modifiers doesn't matter.,,,,,,,,%CommandHotkey%
  if errorlevel <> 0
    return
  CommandHotkey := input
  GoSub, WriteIni
  reload
  return

Hotkeys_FastMoveModifiers:
  inputbox,input, Input the modifier keys for Fast Move, Please input the modifiers for Fast Move.`n^ stands for ctrl`, + stands for shift`,`n! stands for alt and # stands for Win key.`nE.G. : ^# will make ctrl+windows+1 move the active window to the first area.`nNotice that their order doesn't matter.,,,,,,,,%FastMoveModifiers%
  if errorlevel <> 0
    return
  FastMoveModifiers := input
  GoSub, WriteIni
  Reload
  return

CreateOptionsMenu()
{
  global LButtonDrag
  global MButtonDrag
  global EdgeDrag
  global ShowGridFlag
  global ShowGroupsFlag
  global ShowNumbersFlag
  global SafeMode
  Menu, Options, add, Safe Mode, Options_SafeMode
  Menu, Options, add, Show Grid, Options_ShowGrid
  Menu, Options, add, Show Numbers On Grid, Options_ShowNumbers
  Menu, Options, add, Use Drag On Window Title method, Options_LButtonDrag
  Menu, Options, add, Use Drag With Middle Button method, Options_MButtonDrag
  Menu, Options, add, Use Drag Window To Edge method, Options_EdgeDrag
  Menu, Options, add, Set Edge Time, Options_EdgeTime
  Menu, Options, add, Set Title Size, Options_TitleSize
  Menu, Options, add, Set Grid Order, Options_GridOrder
  If LButtonDrag
    Menu,Options,check, Use Drag On Window Title method
  else
    Menu,Options,Disable, Set Title Size,
  If MButtonDrag
    Menu,Options,check, Use Drag With Middle Button method
  If EdgeDrag
    Menu,Options,check, Use Drag Window To Edge method
  else
    Menu,Options,Disable, Set Edge Time
  If ShowGroupsFlag
    Menu, Options, Check, Show Grid
  If ShowNumbersFlag
    Menu, Options, Check, Show Numbers on Grid
  If SafeMode
    Menu, Options, Check, Safe Mode
}

Options_GridOrder:
  inputbox,input, Input an order for the grid Cycle, Just type the names as found in the "templates" menu item`, separated by commas '`,'.,,,,,,,,%GridOrder%
  if errorlevel <> 0
    return
  GridOrder := input
  GoSub, WriteIni
return

Options_LButtonDrag:
  If LButtonDrag
  {
    Menu,Options,Uncheck, Use Drag On Window Title method
    LButtonDrag := false
    Menu,Options,Disable, Set Title Size,
  }
  else
  {
    Menu,Options,check, Use Drag On Window Title method
    LButtonDrag := true
    Menu,Options,Enable, Set Title Size,
  }
  GoSub, WriteIni
return

Options_mbuttonDrag:
  If mbuttonDrag
    mbuttonDrag := false
  else
    mbuttonDrag := true
  GoSub, WriteIni
  reload
return

Options_EdgeDrag:
  If EdgeDrag
  {
    EdgeDrag := false
    Menu,Options,Uncheck, Use Drag Window To Edge method
    Menu,Options,Disable, Set Edge Time
  }
  else
  {
    Menu,Options,check, Use Drag Window To Edge method
    EdgeDrag := true
    Menu,Options,Enable, Set Edge Time
  }
  GoSub, WriteIni
return

Options_EdgeTime:
  inputbox,input, Input the delay for the edge method, Please input the delay before the grid comes up `nwhen a window is dragged to the edge of the screen,,,,,,,,%EdgeTime%
  if errorlevel <> 0
    return
  EdgeTime := input
  GoSub, WriteIni
return

Options_TitleSize:
  inputbox,input, Input the size of the title of windows, Please input the number of pixels to be considered as the title of a window`, for the LButton drag method.,,,,,,,,%TitleSize%
  if errorlevel <> 0
    return
  TitleSize := input
  GoSub, WriteIni
return

Options_SafeMode:
  if SafeMode
  {
    SafeMode := False
    Menu,options,Uncheck, Safe Mode
  }
  else
  {
    SafeMode := True
    Menu,options,check, Safe Mode
  }
  GoSub, WriteIni
return

Options_ShowGrid:
  If ShowGroupsFlag
  {
    ShowGroupsFlag := false
    Menu,options, Uncheck,  Show Grid
    Menu,Options,Disable, Show Numbers On Grid
  }
  else
  {
    ShowGroupsFlag := True
    Menu,options, Check,  Show Grid
    Menu,Options,Enable, Show Numbers On Grid
  }
  GoSub, WriteIni
return

Options_ShowNumbers:
  If ShowNumbersFlag
  {
    ShowNumbersFlag := false
    Menu,options, Uncheck, Show Numbers On Grid
  }
  else
  {
    ShowNumbersFlag := True
    Menu,options, Check, Show Numbers On Grid
  }
  GoSub, WriteIni
  Reload
return

Template-Grids:
  GridName = Grids/%A_ThisMenuItem%.grid
  GoSub, ApplyGrid
  Menu,Templates,DeleteAll
  CreateTemplatesMenu()
  Menu,Templates, check,%A_ThisMenuItem%
return

NextGrid:
  NextGridFlag := False
  NextGrid =
  Loop
  {
    StringLeft,out,GridOrder,1
    If out = ,
      StringTrimLeft,GridOrder,GridOrder,1
    else
      {
      StringRight,out,GridOrder,1
      If out <> ,
        GridOrder =%GridOrder%,
      break
      }
  }
  Loop, Parse,GridOrder,CSV
  {
    If A_LoopField is space
      continue

    If NextGridFlag
    {
      NextGrid := A_LoopField
      AutoTrim,on
      SetEnv,NextGrid,%NextGrid%
      NextGridFlag:= False
    }
    If ("Grids/" . A_LoopField ".grid" = GridName)
      NextGridFlag := True
  }
  If (NextGridFlag OR NextGrid = "")
    {
    StringGetPos, CommaPosition, GridOrder, `,
    StringLeft, NextGrid, GridOrder, %CommaPosition%
    }
  GridName = Grids/%NextGrid%.grid
  Critical,on
  GoSub,HideGroups
  Gui,2:Hide
  GoSub, ApplyGrid
  GoSub, ShowGroups
  SafeShow := False
  Critical,off
return

ApplyGrid:
  If (GridName = "4part")
    GridName = Grids/4-Part.grid
  if (GridName = "edge")
    GridName = Grids/EdgeGrid.grid
  if (Gridname = "DualScreen")
    GridName = Grids/Dual-Screen.grid
  if (GridName = "2PartHorizontal")
    GridName = Grids/2 Part-Horizontal.grid
  if (Gridname = "2PartVertical")
    GridName = Grids/2 Part-Vertical.grid

  If (GridName = "3part")
    GoSub,Template-3part
  else
    GoSub, CreateGridFromFile
return

CreateGridFromFile:
  Menu,Templates,DeleteAll
  CreateTemplatesMenu()

  GoSub, HideGroups
  Gui,destroy
  Gui,2:destroy
  IniRead,NGroups,%A_ScriptDir%\%GridName%,Groups,NumberOfGroups,Error
  If (NGroups = "error")
    {
    MsgBox,There was an error while Opening the grid file.`nReverting to Default Config. Please select another grid from the templates menu.`nErrorCode:001
    GoSub, Template-3Part
    return
    }
  ErrorLevel := False
  loop,%NGroups%
  {
    if a_index = "0"
      continue
    TriggerTop    = %A_Index%TriggerTop
    TriggerBottom = %A_Index%TriggerBottom
    TriggerRight  = %A_Index%TriggerRight
    TriggerLeft   = %A_Index%TriggerLeft

    GridTop    = %A_Index%GridTop
    GridBottom = %A_Index%GridBottom
    GridRight  = %A_Index%GridRight
    GridLeft   = %A_Index%GridLeft

    IniRead,%TriggerTop%    ,%A_ScriptDir%\%GridName%,%A_Index%,TriggerTop,Error
    IniRead,%TriggerBottom% ,%A_ScriptDir%\%GridName%,%A_Index%,TriggerBottom,Error
    IniRead,%TriggerLeft%   ,%A_ScriptDir%\%GridName%,%A_Index%,TriggerLeft,Error
    IniRead,%TriggerRight%  ,%A_ScriptDir%\%GridName%,%A_Index%,TriggerRight,Error

    IniRead,%GridTop%       ,%A_ScriptDir%\%GridName%,%A_Index%,GridTop,Error
    IniRead,%GridBottom%    ,%A_ScriptDir%\%GridName%,%A_Index%,GridBottom,Error
    IniRead,%GridLeft%      ,%A_ScriptDir%\%GridName%,%A_Index%,GridLeft,Error
    IniRead,%GridRight%     ,%A_ScriptDir%\%GridName%,%A_Index%,GridRight,Error

    If (%TriggerTop%="Error" OR %TriggerBottom%="Error"
        OR %TriggerLeft%="Error" OR %TriggerRight%="Error" )
      {
      ErrorCode := A_Index
      ErrorLevel := True
      break
      }

    if (%GridTop%="Error")
      %GridTop% := %TriggerTop%
    if (%GridBottom%="Error")
      %GridBottom% := %TriggerBottom%
    if (%GridLeft%="Error")
      %GridLeft% := %TriggerLeft%
    if (%GridRight%="Error")
      %GridRight% := %TriggerRight%
  }
  If (ErrorLevel != 0 or ErrorCode)
    {
    MsgBox,There was an error while reading the grid file.`nReverting to default config. (Read error on grid element %ErrorCode%)
    GoSub, Template-3Part
    GridName = 3Part
    return
    }
  evaluateGrid()
  GoSub, CreateGroups
  GoSub, WriteIni
return

GetScreenSize()
{
  Global
  ScreenLeft   :=0
  ScreenTop    :=0
  ScreenRight  :=0
  ScreenBottom :=0
  Sysget,MonitorCount,MonitorCount

  Loop,%MonitorCount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (monitorLeft<ScreenLeft)
      ScreenLeft:=monitorLeft
    If (monitorTop<ScreenTop)
      ScreenTop:=monitorTop
    If (monitorRight>ScreenRight)
      ScreenRight:=monitorRight
    If (monitorBottom>ScreenBottom)
      ScreenBottom:=monitorBottom
  }
  ScreenWidth := ScreenRight - ScreenLeft
  ScreenHeight := ScreenBottom - ScreenTop
  return
}

GetMonitorRight(MouseX, MouseY)
{
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (MouseX <= monitorRight AND MouseX >= monitorLeft
        AND MouseY >= monitorTop AND MouseY <= monitorBottom)
      return %MonitorRight%
  }
  return error
}

GetMonitorBottom(MouseX, MouseY)
{
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (MouseX <= MonitorRight AND MouseX >= MonitorLeft
        AND MouseY >= monitorTop AND MouseY <= monitorBottom)
      return, %MonitorBottom%
  }
  return error
}

GetMonitorLeft(MouseX, MouseY)
{
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (MouseX <= MonitorRight AND MouseX >= MonitorLeft
        AND MouseY >= monitorTop AND MouseY <= monitorBottom)
      return, %MonitorLeft%
  }
  return error
}

GetMonitorTop(MouseX, MouseY)
{
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (MouseX <= MonitorRight AND MouseX >= MonitorLeft
        AND MouseY >= monitorTop AND MouseY <= monitorBottom)
      return, %MonitorTop%
  }
  return error
}

StoreWindowState(WindowID,WindowX,WindowY,WindowWidth,WindowHeight)
{
  global WindowIdBuffer
  global WindowXBuffer
  global WindowYBuffer
  global WindowWidthBuffer
  global WindowHeightBuffer
  WindowIdBuffer = %WindowId%,%WindowIdBuffer%
  WindowXBuffer = %WindowX%,%WindowXBuffer%
  WindowYBuffer = %WindowY%,%WindowYBuffer%
  WindowWidthBuffer = %WindowWidth%,%WindowWidthBuffer%
  WindowHeightBuffer = %WindowHeight%,%WindowHeightBuffer%
  return
}

GetWindowState(WindowId)
{
  global
  StringSplit, WindowX     , WindowXBuffer     , `,,,
  StringSplit, WindowY     , WindowYBuffer     , `,,,
  StringSplit, WindowWidth , WindowWidthBuffer , `,,,
  StringSplit, WindowHeight, WindowHeightBuffer, `,,,
  loop, parse, WindowIdBuffer,CSV
  {
    if a_loopfield is space
      continue
    if (WindowId = A_LoopField)
    {
      WindowX := WindowX%A_Index%
      WindowY := WindowY%A_Index%
      WindowWidth  := WindowWidth%A_Index%
      WindowHeight := WindowHeight%A_Index%
      return true
    }
  }
  return false
}

evaluateGrid()
{
  global
  count := 0
  loop,%NGroups%
  {
    value := A_Index - count

    %value%TriggerTop    := eval(%A_Index%TriggerTop)
    %value%TriggerBottom := eval(%A_Index%TriggerBottom)
    %value%TriggerLeft   := eval(%A_Index%TriggerLeft)
    %value%TriggerRight  := eval(%A_Index%TriggerRight)

    If (%A_Index%GridTop = "Run")
    {
      %value%GridTop    := %A_Index%GridTop
      %value%GridBottom := %A_Index%GridBottom
      %value%GridLeft   := %A_Index%GridLeft
      %value%GridRight  := %A_Index%GridRight
      continue
    }


    if(%value%GridTop <> "")
      %value%GridTop    := eval(%A_Index%GridTop)
    if(%value%GridBottom <> "")
      %value%GridBottom := eval(%A_Index%GridBottom)
    if(%value%GridLeft <> "")
      %value%GridLeft   := eval(%A_Index%GridLeft)
    if(%value%GridRight <> "")
      %value%GridRight  := eval(%A_Index%GridRight)

    if (%value%TriggerTop = "error" OR %value%TriggerBottom = "Error"
        OR %value%TriggerLeft = "error" OR %value%TriggerRight = "error"
        OR %value%GridTop = "error" OR %value%GridBottom = "Error"
        OR %value%GridLeft = "error" OR %value%GridRight = "error")
    {
      count += 1
      continue
    }
  }
  ngroups -= count
}

Getmonitorsizes()
{
  global
  sysget,monitorCount,MonitorCount

  loop,%monitorCount%
  {
    sysget,monitorReal,Monitor,%A_Index%
    sysget,monitor,MonitorWorkArea,%A_Index%
    monitor%a_Index%Left   :=MonitorLeft
    monitor%a_Index%Bottom :=MonitorBottom
    monitor%a_Index%Right  :=MonitorRight
    monitor%a_Index%Top    :=MonitorTop
    monitor%a_Index%Width  :=MonitorRight - MonitorLeft
    monitor%a_Index%Height :=MonitorBottom - MonitorTop

    monitorreal%A_Index%Left   :=MonitorRealLeft
    monitorreal%A_Index%Bottom :=MonitorRealBottom
    monitorreal%A_Index%Right  :=MonitorRealRight
    monitorreal%A_Index%Top    :=MonitorRealTop
    monitorreal%A_Index%Width  :=MonitorRealRight - MonitorRealLeft
    monitorreal%A_Index%Height :=MonitorRealBottom - MonitorRealTop
  }
  return
}

ComputeEdgeRectangles()
{
  global

  sysget,MonitorCount,MonitorCount

  RectangleCount := 0

  loop,%MonitorCount%
  {
    sysget,Monitor,Monitor,%A_Index%

    MonitorRight := MonitorRight -1
    MonitorBottom := MonitorBottom -1


    RectangleCount := RectangleCount +1
    EdgeRectangleXL%RectangleCount% := MonitorLeft
    EdgeRectangleYT%RectangleCount% := MonitorTop

    EdgeRectangleXR%RectangleCount% := MonitorRight
    EdgeRectangleYB%RectangleCount% := MonitorTop + RectangleSize


    RectangleCount := RectangleCount +1
    EdgeRectangleXL%RectangleCount% := MonitorLeft
    EdgeRectangleYT%RectangleCount% := MonitorBottom - RectangleSize

    EdgeRectangleXR%RectangleCount% := MonitorRight
    EdgeRectangleYB%RectangleCount% := MonitorBottom


    RectangleCount := RectangleCount +1
    EdgeRectangleXL%RectangleCount% := MonitorLeft
    EdgeRectangleYT%RectangleCount% := MonitorTop

    EdgeRectangleXR%RectangleCount% := MonitorLeft + RectangleSize
    EdgeRectangleYB%RectangleCount% := MonitorBottom


    RectangleCount := RectangleCount +1
    EdgeRectangleXL%RectangleCount% := MonitorRight - RectangleSize
    EdgeRectangleYT%RectangleCount% := MonitorTop

    EdgeRectangleXR%RectangleCount% := MonitorRight
    EdgeRectangleYB%RectangleCount% := MonitorBottom
  }
}


ShouldUseSizeMoveMessage(class)
{
   return class = "Putty" or class = "Pietty"
}

StartWithWindowsDetect:
  loop,%A_startup%\*.lnk
  {
    if (A_LoopFileName = "GridMove.lnk")
    {
      StartWithWindows := true
      break
    }
  }
return

StartWithWindowsToggle:
  GoSub,StartWithWindowsDetect

  if(StartWithWindows)
  {
    filedelete,%a_startup%\GridMove.lnk
    StartWithWindows := false
  }
  else
  {
    FileCreateShortcut,%A_ScriptDir%/GridMove.exe,%A_startup%\GridMove.lnk
    StartWithWindows := true
  }

  if(startwithwindows)
    Menu,Tray,Check, Start With Windows
  else
    Menu,Tray,UnCheck, Start With Windows
return

EnableAutoUpdate:



  cmdParams = -ri
  uniqueID = GridMove
  dcuHelperDir = %A_ScriptDir%
  IfExist, %dcuHelperDir%\dcuhelper.exe
  {
    OutputDebug, %A_Now%: %dcuHelperDir%\dcuhelper.exe %cmdParams% "%uniqueID%" "%A_ScriptDir%" . -shownew -nothingexit
    Run, %dcuHelperDir%\dcuhelper.exe %cmdParams% "%uniqueID%" "%A_ScriptDir%" Updater ,,Hide
  }
return

AddToIgnore:

  Ignore_added := false
  coordmode,tooltip,screen
  coordmode,mouse,screen
  hotkey,F11,on
  hotkey,F12,on
  loop
  {
    mousegetpos,MouseX,MouseY
    if(Ignore_added)
      break
    tooltip,Focus the window to ignore/unignore and press F12!!`nPress F11 to cancel.
    sleep,50
  }
  tooltip,
  hotkey,F11,off
  hotkey,F12,off
return

AddCurrentToIgnore:
  Ignore_added := true
  wingetclass,WinIgnoreClass,A
  if Exceptions contains %WinIgnoreClass%
  {
    IgnorePattern = ,?\s*%WinIgnoreClass%\s*
    Exceptions := RegExReplace(Exceptions,IgnorePattern)
    msgbox,Removed %WinIgnoreClass% from exceptions (%Errorlevel%)
  }
  else
  {
    Exceptions := Exceptions . "," . WinIgnoreClass
    msgbox,added %WinIgnoreClass% to exceptions
  }
  Gosub,WriteIni
return

AddCurrentToIgnoreCancel:
  Ignore_added := true
return







ReadIni:
  IniVersion = 0

  IfExist,%A_AppData%/DonationCoder/GridMove/%A_ScriptName%.ini
    ScriptDir=%A_AppData%/DonationCoder/GridMove/%A_ScriptName%.ini
  else
    IfExist,%A_ScriptDir%\%A_ScriptName%.ini
    ScriptDir=%A_ScriptDir%\%A_ScriptName%.ini
    else
    {
      ScriptDir=%A_AppData%/DonationCoder/GridMove/%A_ScriptName%.ini
    }

  IfExist,%ScriptDir%
  {
    IniRead,IniVersion            ,%ScriptDir%,IniSettings,IniVersion,1
    If IniVersion = 1
    {
      IniWrite,%GridOrder%        ,%ScriptDir%,GridSettings,GridOrder
      IniVersion = 2
      IniWrite,%IniVersion%       ,%ScriptDir%,IniSettings,Iniversion
    }
    If IniVersion = 2
    {
      IniWrite,%UseCommand%       ,%ScriptDir%,ProgramSettings,UseCommand
      IniWrite,%CommandHotkey%    ,%ScriptDir%,ProgramSettings,CommandHotkey
      IniWrite,%UseFastMove%      ,%ScriptDir%,ProgramSettings,UseFastMove
      IniWrite,%FastMoveModifiers%,%ScriptDir%,ProgramSettings,FastMoveModifiers
      IniVersion = 3
      IniWrite, %IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 3
    {
      IniWrite,%TitleLeft%        ,%ScriptDir%,ProgramSettings,TitleLeft
      IniVersion = 4
      IniWrite, %IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 4
    {
      IniWrite,%ShowNumbersFlag%  ,%ScriptDir%,OtherSettings,ShowNumbersFlag
      IniVersion = 5
      IniWrite,%IniVersion%       ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 5
    {
      IniWrite,%MButtonTimeout%  ,%ScriptDir%,InterfaceSettings,MButtonTimeout
      IniWrite,%Transparency%    ,%ScriptDir%,InterfaceSettings,Transparency
      IniVersion = 6
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 6
    {
      IniWrite,%FastMoveMeta%    ,%ScriptDir%,ProgramSettings,FastMoveMeta
      IniVersion = 7
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 7
    {
      IniWrite,%Exceptions%      ,%ScriptDir%,ProgramSettings,Exceptions
      IniVersion = 8
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 8
    {
      IniWrite,%SafeMode%        ,%ScriptDir%,ProgramSettings,SafeMode
      IniVersion = 9
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 9
    {
      IniWrite,%SequentialMove%  ,%ScriptDir%,ProgramSettings,SequentialMove
      IniVersion = 10
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 10
    {
      IniWrite,%DebugMode%       ,%ScriptDir%,ProgramSettings,DebugMode
      IniVersion = 11
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 11
    {
      IniWrite,%GridOrder%       ,%ScriptDir%,GridSettings,GridOrder
      IniWrite,%GridName%        ,%ScriptDir%,GridSettings,GridName
      IniVersion = 12
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 12
    {
      IniWrite,%DisableTitleButtonsDetection%,%ScriptDir%,OtherSettings,DisableTitleButtonsDetection
      IniVersion = 13
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }

    IniRead,GridName         ,%ScriptDir%,GridSettings     ,GridName,Error
    IniRead,LButtonDrag      ,%ScriptDir%,InterfaceSettings,LButtonDrag,Error
    IniRead,MButtonDrag      ,%ScriptDir%,InterfaceSettings,MButtonDrag,Error
    IniRead,EdgeDrag         ,%ScriptDir%,InterfaceSettings,EdgeDrag,Error
    IniRead,EdgeTime         ,%ScriptDir%,OtherSettings    ,EdgeTime,Error
    IniRead,ShowGroupsFlag   ,%ScriptDir%,OtherSettings    ,ShowGroupsFlag,Error
    IniRead,ShowNumbersFlag  ,%ScriptDir%,OtherSettings    ,ShowNumbersFlag,Error
    IniRead,TitleSize        ,%ScriptDir%,OtherSettings    ,TitleSize,Error
    IniRead,GridOrder        ,%ScriptDir%,GridSettings     ,GridOrder,Error
    IniRead,UseCommand       ,%ScriptDir%,Programsettings  ,UseCommand,Error
    IniRead,CommandHotkey    ,%ScriptDir%,Programsettings  ,CommandHotkey,Error
    IniRead,UseFastMove      ,%ScriptDir%,Programsettings  ,UseFastMove,Error
    IniRead,FastMoveModifiers,%ScriptDir%,Programsettings  ,FastMoveModifiers,Error
    IniRead,FastMoveMeta     ,%ScriptDir%,Programsettings  ,FastMoveMeta,Error
    IniRead,TitleLeft        ,%ScriptDir%,ProgramSettings  ,TitleLeft,Error
    IniRead,MButtonTimeout   ,%ScriptDir%,InterfaceSettings,MButtonTimeout,Error
    IniRead,Transparency     ,%ScriptDir%,InterfaceSettings,Transparency,Error
    IniRead,Exceptions       ,%ScriptDir%,ProgramSettings  ,Exceptions,Error
    IniRead,SafeMode         ,%ScriptDir%,ProgramSettings  ,SafeMode,Error
    IniRead,SequentialMove   ,%ScriptDir%,ProgramSettings  ,SequentialMove,Error
    IniRead,DebugMode        ,%ScriptDir%,ProgramSettings  ,DebugMode,Error
    IniRead,DisableTitleButtonsDetection,%ScriptDir%,OtherSettings    ,DisableTitleButtonsDetection,Error


    If (GridName          = "Error" OR LButtonDrag    = "Error" OR MButtonDrag       = "Error"
        OR EdgeDrag       = "Error" OR EdgeTime       = "Error" OR ShowGroupsFlag    = "Error"
        OR TitleSize      = "Error" OR ShowGroupsFlag = "Error" OR ShowNumbersFlag   = "Error"
        OR TitleSize      = "Error" OR GridOrder      = "Error" OR UseCommand        = "Error"
        OR CommandHotkey  = "Error" OR UseFastMove    = "Error" OR FastMoveModifiers = "Error"
        OR FastMoveMeta   = "Error" OR TitleLeft      = "Error" OR MButtonTimeout    = "Error"
        OR Transparency   = "Error" OR Exceptions     = "Error" OR SafeMode          = "Error"
        OR SequentialMove = "Error" OR DebugMode      = "Error"
        OR DisableTitleButtonsDetection = "Error")
    {
      MsgBox,There was an error reading the .ini file.`nThe script will be restarted, and the ini file will be deleted.
      FileDelete,%ScriptDir%
      Reload
      sleep 20000
    }
  }
  else
  {
    GoSub, AboutHelp
    GoSub,WriteIni
    msgbox,64,Information,As this is GridMove's first run`,you'll get some help in the form of tooltips.`nIf you don't like to see them`, just close GridMove through it's tray menu and run it again.`nPlease notice that GridMove may act a bit slower because of these helpers.
    settimer, helper,100
  }
return

ReadMoveTo:
  MvScriptDir=%A_AppData%/DonationCoder/GridMove/move.to

  IfExist,%MvScriptDir% 
  {
    IniRead,MOVETOHERE,%MvScriptDir%,MoveToHere,MoveToHere,0    
  }
return
  
ResetMoveTo:
  MvScriptDir=%A_AppData%/DonationCoder/GridMove/move.to
  IfExist,%MvScriptDir% 
  {
    IniWrite,0,%MvScriptDir%,MoveToHere,MoveToHere
  }
  MOVETOHERE=0
return

WriteIni:
  IfNotExist,%ScriptDir%
  {
    FileCreateDir,%A_AppData%/DonationCoder/
    if(ErrorLevel <> 0)
    {
      ScriptDir=%A_ScriptDir%\%A_ScriptName%.ini
    }
    else
      FileCreateDir,%A_AppData%/DonationCoder/GridMove/
      if(ErrorLevel <> 0)
      {
        ScriptDir=%A_ScriptDir%\%A_ScriptName%.ini
      }
    FileAppend, ,%ScriptDir%
  }
  IniWrite,%GridName%         ,%ScriptDir%,GridSettings     ,GridName
  IniWrite,%LButtonDrag%      ,%ScriptDir%,InterfaceSettings,LButtonDrag
  IniWrite,%MButtonDrag%      ,%ScriptDir%,InterfaceSettings,MButtonDrag
  IniWrite,%EdgeDrag%         ,%ScriptDir%,InterfaceSettings,EdgeDrag
  IniWrite,%EdgeTime%         ,%ScriptDir%,OtherSettings    ,EdgeTime
  IniWrite,%ShowGroupsFlag%   ,%ScriptDir%,OtherSettings    ,ShowGroupsFlag
  IniWrite,%ShowNumbersFlag%  ,%ScriptDir%,OtherSettings    ,ShowNumbersFlag
  IniWrite,%TitleSize%        ,%ScriptDir%,OtherSettings    ,TitleSize
  IniWrite,%GridOrder%        ,%ScriptDir%,GridSettings     ,GridOrder
  IniWrite,%UseCommand%       ,%ScriptDir%,ProgramSettings  ,UseCommand
  IniWrite,%CommandHotkey%    ,%ScriptDir%,ProgramSettings  ,CommandHotkey
  IniWrite,%UseFastMove%      ,%ScriptDir%,ProgramSettings  ,UseFastMove
  IniWrite,%FastMoveModifiers%,%ScriptDir%,ProgramSettings  ,FastMoveModifiers
  IniWrite,%FastMoveMeta%     ,%ScriptDir%,ProgramSettings  ,FastMoveMeta
  IniWrite,%SafeMode%         ,%ScriptDir%,ProgramSettings  ,SafeMode
  IniWrite,%IniVersion%       ,%ScriptDir%,IniSettings      ,iniversion
  IniWrite,%TitleLeft%        ,%ScriptDir%,ProgramSettings  ,TitleLeft
  IniWrite,%MButtonTimeout%   ,%ScriptDir%,InterfaceSettings,MButtonTimeout
  IniWrite,%Transparency%     ,%ScriptDir%,InterfaceSettings,Transparency
  IniWrite,%Exceptions%       ,%ScriptDir%,ProgramSettings,Exceptions
  IniWrite,%SequentialMove%   ,%ScriptDir%,ProgramSettings,SequentialMove
  IniWrite,%DebugMode%        ,%ScriptDir%,ProgramSettings,DebugMode
  IniWrite,%DisableTitleButtonsDetection%,%ScriptDir%,OtherSettings,DisableTitleButtonsDetection
Return


AboutHelp:
  if mutex
    return
  mutex:=true

  gui, 3: Add, Tab, x6 y5 w440 h420, About|Help


  gui, 3: Tab, 1
  IfExist %A_ScriptDir%\gridmove.ico
    gui, 3:Add , Picture, x15 y35,%A_ScriptDir%\gridmove.ico
  else
    IfExist %A_ScriptDir%\gridmove.exe
      gui, 3:Add , Picture, x15 y35,%A_ScriptDir%\gridmove.exe

  gui, 3:Font,Bold s10
  gui, 3:Add ,Text,x65 y45,GridMove V%ScriptVersion% by jgpaiva`n

  gui, 3:Font,
  gui, 3:Font, s10
  gui, 3:Add ,Text,x15 y95 w420 ,This is a small script that helps you organize your windows in your desktop, by creating a grid that when called up, you can snap windows into. It's bundled with some predefined templates, but you can create your own grids, or download other people's grids. For more information on how to use it, check the help tab or the DonationCoder.com Forum thread.

  gui, 3:Add ,Text,X15 Y220,It was suggested by Nudone at DonationCoder.com forums, `nin the following thread:
  gui, 3:Font,CBlue Underline
  gui, 3:Add ,Text,X15 Y255 GPost,http://www.donationcoder.com/Forums/bb/index.php?topic=3824
  gui, 3:Font

  gui, 3:Font, s10
  gui, 3:Add ,Text, y280 X15,`nPlease visit us at:
  gui, 3:Font,CBlue Underline s10
  gui, 3:Add ,Text, y313 X15 GMainSite,http://www.donationcoder.com/
  gui, 3:Font

  IfExist,Images/Cody.png
    Gui, 3:Add ,Picture, Y290 X280,Images/Cody.png

  gui, 3:Add ,Button,y350 x15  gdonateAuthor w116 h30,Donate

  gui, 3:Font, s9
  gui, 3:Add ,Text,y400 x15 h10,If you like this program please make a donation to help further development.


  gui, 3:Tab, 2
  gui, 3:Font,

  Gui, 3:Add, Edit, w413 R29 vMyEdit ReadOnly
  IfExist, %A_ScriptDir%\GridMoveHelp.txt
    FileRead, FileContents,%A_ScriptDir%\GridMoveHelp.txt
  Else
    MsgBox,ERROR: GridMoveHelp.txt not found!!
  GuiControl,3:, MyEdit, %FileContents%





















  gui, 3:tab



  Gui, 3:show,,GridMove V%ScriptVersion% by jgpaiva
return

Post:
  Run,http://www.donationcoder.com/Forums/bb/index.php?topic=3824
  GoSub,3GuiCLOSE
return

MainSite:
  Run,http://www.donationcoder.com/
  GoSub,3Guiclose
return

DonateSite:
  Run,http://www.donationcoder.com/Donate/index.html
  GoSub,3Guiclose
return

DonateAuthor:
  Run,https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=jgpaiva`%40gmail`%2ecom&item_name`=donate`%20to`%20jgpaiva&item_number`=donationcoder`%2ecom&no_shipping=1&cn=Please`%20drop`%20me`%20a`%20line`%20`%3aD&tax`=0&currency_code=EUR&bn=PP`%2dDonationsBF&charset=UTF`%2d8
  GoSub,3Guiclose
return

3GuiEscape:
3GuiClose:
buttonok:
  gui,3:destroy
  mutex:=false
return




Template-3part:
  Menu,Templates,DeleteAll
  CreateTemplatesMenu()

  SysGet, MonitorCount, MonitorCount
  Count := 0

  loop, %MonitorCount%
  {
    SysGet, Monitor, MonitorWorkArea,%A_index%
    MonitorWidth := MonitorRight - MonitorLeft
    MonitorHeight := MonitorBottom - MonitorTop

    Count+=1
    %Count%TriggerTop    := MonitorTop
    %Count%TriggerRight  := MonitorRight
    %Count%TriggerBottom := MonitorBottom
    %Count%TriggerLeft   := MonitorLeft + Round(MonitorWidth / 3)
    %Count%GridTop       := %Count%TriggerTop
    %Count%GridRight     := %Count%TriggerRight
    %Count%GridBottom    := %Count%TriggerBottom
    %Count%GridLeft      := %Count%TriggerLeft

    Count+=1
    %Count%TriggerTop    := MonitorTop
    %Count%TriggerRight  := MonitorLeft + Round(MonitorWidth / 3)
    %Count%TriggerBottom := MonitorTop + Round(MonitorHeight / 2)
    %Count%TriggerLeft   := MonitorLeft
    %Count%GridTop       := %Count%TriggerTop
    %Count%GridRight     := %Count%TriggerRight
    %Count%GridBottom    := %Count%TriggerBottom
    %Count%GridLeft      := %Count%TriggerLeft

    Count+=1
    temp := count - 1
    %Count%TriggerTop    := %Temp%TriggerBottom +0.01
    %Count%TriggerRight  := MonitorLeft + Round(MonitorWidth / 3)
    %Count%TriggerBottom := MonitorBottom
    %Count%TriggerLeft   := MonitorLeft
    %Count%GridTop       := %Count%TriggerTop
    %Count%GridRight     := %Count%TriggerRight
    %Count%GridBottom    := %Count%TriggerBottom
    %Count%GridLeft      := %Count%TriggerLeft
  }
  NGroups := MonitorCount * 3
  Gui,Destroy
  GoSub, CreateGroups
  GridName = 3Part
  GoSub, WriteIni
return

; #include GridMoveP2.ahk





ReloadOnResolutionChange:
  OldMonitorCount := MonitorCount

  loop,%MonitorCount%
    {
    OldMonitor%a_Index%Left   := Monitor%a_Index%Left
    OldMonitor%a_Index%Bottom := Monitor%a_Index%Bottom
    OldMonitor%a_Index%Right  := Monitor%a_Index%Right
    OldMonitor%a_Index%Top    := Monitor%a_Index%Top

    OldMonitorReal%A_Index%Left   := MonitorReal%A_Index%Left
    OldMonitorReal%A_Index%Bottom := MonitorReal%A_Index%Bottom
    OldMonitorReal%A_Index%Right  := MonitorReal%A_Index%Right
    OldMonitorReal%A_Index%Top    := MonitorReal%A_Index%Top
    }
  Getmonitorsizes()

  if (MonitorCount <> OldMonitorCount)
    reload

  loop,%MonitorCount%
    {
    if( OldMonitor%a_Index%Left   <> Monitor%a_Index%Left
     OR OldMonitor%a_Index%Bottom <> Monitor%a_Index%Bottom
     OR OldMonitor%a_Index%Right  <> Monitor%a_Index%Right
     OR OldMonitor%a_Index%Top    <> Monitor%a_Index%Top)
      reload

    if( OldMonitorReal%A_Index%Left   <> MonitorReal%A_Index%Left
     OR OldMonitorReal%A_Index%Bottom <> MonitorReal%A_Index%Bottom
     OR OldMonitorReal%A_Index%Right  <> MonitorReal%A_Index%Right
     OR OldMonitorReal%A_Index%Top    <> MonitorReal%A_Index%Top)
      reload
    }
  return
; #include GridMoveP3.ahk





Command:
  GoSub, ReadMoveTo
  if MOVETOHERE <> 0 
  {
    MoveToGrid(MOVETOHERE)
    GoSub, ResetMoveTo
    return
  }
  GoSub, ShowGroups

Drop_Command:
  Settimer,Drop_Command,off
  

  
  OSDwrite("- -")
  Input,FirstNumber,L1 T10,{esc},1,2,3,4,5,6,7,8,9,0,m,r,n,M,v,a,e
  If ErrorLevel = Max
    {
    OSDwrite("| |")
    sleep,200
    GoSub,Command
    }
  If (ErrorLevel = "Timeout" OR ErrorLevel = "EndKey")
    {
    GoSub, Command_Hide
    return
    }

  If FirstNumber is not number
    {
    If (FirstNumber = "M")
      {
      winget,state,minmax,A
      if state = 1
        WinRestore,A
      else
        PostMessage, 0x112, 0xF030,,, A,
      }
    Else If (FirstNumber = "e")
    {
      GoSub, Command_Hide
      exitapp
      return
    }
    Else If (FirstNumber = "A")
    {
      GoSub, Command_Hide
      gosub,AboutHelp
      return
    }
    Else If (FirstNumber = "V")
      {
      GoSub, Command_Hide
      msgbox,NOT DONE!!


      return
      }
    Else If (FirstNumber = "R")
      {
      GoSub, Command_Hide
      Reload
      }
    Else If FirstNumber = n
      {
      gosub, NextGrid
      gosub, command
      return
      }
    GoSub, Command_Hide
    return
    }

  If (NGroups < FirstNumber * 10)
    {
    If (FirstNumber = "0")
      {
      GoSub, Command_Hide
      WinMinimize,A
      return
      }
    GoSub, Command_Hide
    MoveToGrid(FirstNumber)
    return
    }

  Command2:
  output := FirstNumber . " -"
  OSDwrite(Output)
  Input,SecondNumber,L1 T2,{esc}{enter},1,2,3,4,5,6,7,8,9,0
  If ErrorLevel = Max
    {
    OSDwrite("")
    sleep,500
    GoSub,Command2
    }

  If(ErrorLevel = "Timeout")
    {
    If (FirstNumber = "0")
      {
      GoSub, Command_Hide
      WinMinimize,A
      return
      }
    GoSub, Command_Hide
    MoveToGrid(FirstNumber)
    return
    }
  If(ErrorLevel = "EndKey:enter")
    {
    If (FirstNumber = "0")
      {
      GoSub, Command_Hide
      WinMinimize,A
      return
      }
    GoSub, Command_Hide
    MoveToGrid(FirstNumber)
    return
    }
  If(ErrorLevel = "EndKey:esc")
    {
    GoSub, Command_Hide
    return
    }

  If firstnumber = 0
    GridNumber := SecondNumber
  else
    GridNumber := FirstNumber . SecondNumber
  GoSub, Command_Hide
  MoveToGrid(GridNumber)
  return

OSDCreate()
  {
  global OSD
  Gui,4: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  Gui,4: Font,S13
  Gui,4: Add, Button, vOSD x0 y0 w100 h30 ,
  Gui,4: Color, EEAAEE
  Gui,4: Show, x0 y0 w0 h0 noactivate, OSD
  Gui,4: hide
  WinSet, TransColor, EEAAEE,OSD
  return
  }

OSDWrite(Value)
  {
  Global OSD
  Global Monitor1Width
  Global Monitor1Height
  Global Monitor1Top
  Global Monitor1Left
  XPos := Floor(Monitor1Left + Monitor1Width / 2 - 50)
  YPos := Floor(Monitor1Top + Monitor1Height / 2 - 15)
  GuiControl, 4:Text, OSD, %value%
  Gui,4: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  Gui,4:Show, x%Xpos% y%Ypos% w100 h30 noactivate
  return
  }

OSDHide()
  {
  Gui,4:hide,
  return
  }

MoveToGrid(GridToMove)
  {
  global
  triggerTop := %GridToMove%TriggerTop
  triggerBottom := %GridToMove%TriggerBottom
  triggerRight := %GridToMove%TriggerRight
  triggerLeft := %GridToMove%TriggerLeft
  GridBottom :=0
  GridRight  :=0
  GridTop    :=0
  GridLeft   :=0

  GridTop := %GridToMove%GridTop
  GridBottom := %GridToMove%GridBottom
  GridRight := %GridToMove%GridRight
  GridLeft := %GridToMove%GridLeft


  WinGetPos, WinLeft, WinTop, WinWidth, WinHeight,A
  WinGetClass,WinClass,A
  WinGet,WindowId,id,A
  WinGet,WinStyle,Style,A

  if SafeMode
    if not (WinStyle & 0x40000)
      {
      Return
      }

  if (WinClass = "DV2ControlHost" OR Winclass = "Progman"
      OR Winclass = "Shell_TrayWnd")
    Return

  If Winclass in %Exceptions%
    Return

  If (GridTop = )
    return

  If (GridLeft = "WindowWidth" AND GridRight = "WindowWidth")
  {
    WinGetClass,WinClass,A

    if ShouldUseSizeMoveMessage(WinClass)
      SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

    WinMove, A, ,%WinLeft%,%GridTop%, %WinWidth%,% GridBottom - GridTop,

    if ShouldUseSizeMoveMessage(WinClass)
      SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%
    StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
    return
  }
  If (GridTop = "WindowHeight" AND GridBottom = "WindowHeight")
  {
    WinGetClass,WinClass,A

    if ShouldUseSizeMoveMessage(WinClass)
      SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

    WinMove, A, ,%GridLeft%,%WinTop%, % GridRight - GridLeft,%WinHeight%,

    if ShouldUseSizeMoveMessage(WinClass)
      SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%
    StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
    return
  }
  If (GridTop = "AlwaysOnTop")
  {
    WinSet, AlwaysOnTop, Toggle,A
    return
  }
  If (GridTop =  "Maximize")
  {
    winget,state,minmax,A
    if state = 1
      WinRestore,A
    else
      PostMessage, 0x112, 0xF030,,, A,
    return
  }
  If (GridTop = "Run")
  {
    Run,%GridLeft% ,%GridRight%
    return
  }
  if (GridTop = "Restore")
  {
    data := GetWindowState(WindowId)
    If data
      {
      GridLeft  := WindowX
      GridRight := WindowX + WindowWidth
      GridTop   := WindowY
      GridBottom:= WindowY + WindowHeight
      WinRestore,A

      WinGetClass,WinClass,A

      if ShouldUseSizeMoveMessage(WinClass)
        SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

      WinMove, A, ,%GridLeft%,%GridTop%,% GridRight - GridLeft,% GridBottom - GridTop

      if ShouldUseSizeMoveMessage(WinClass)
        SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%

      StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
      }
    return
  }
  GridTop := round(GridTop)
  GridLeft := round(GridLeft)
  GridRight := round(GridRight)
  GridBottom := round(GridBottom)

  GridWidth  := GridRight - GridLeft
  GridHeight := GridBottom - GridTop

  WinRestore,A

  WinGetClass,WinClass,A

  if ShouldUseSizeMoveMessage(WinClass)
    SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

  WinMove, A, ,%GridLeft%,%GridTop%,%GridWidth%,%GridHeight%

  if ShouldUseSizeMoveMessage(WinClass)
    SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%

  StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
  return
  }

Command_Hide:
  critical,on
  Gosub, Cancel
  critical,off
  GoSub, HideGroups
  OSDHide()
  return

DefineHotkeys:
  loop,9
  {
     Hotkey, %FastMoveModifiers%%A_Index%, WinHotkeys
     Hotkey, %FastMoveModifiers%Numpad%A_Index%, WinHotkeys
  }
  Hotkey, %FastMoveModifiers%0, WinHotKey
  Hotkey, %FastMoveModifiers%Numpad0, WinHotkeys
  if FastMoveMeta <>
    Hotkey, %FastMoveModifiers%%FastMoveMeta%, WinHotkeysMeta
  return

WinHotkeys:
  StringRight,Number,A_ThisHotkey,1
  MoveToGrid(Number)
  return

WinHotkeysMeta:
  GoSub, ShowGroups

  Settimer,Drop_Command,off
  OSDwrite("- -")
  Input,FirstNumber,L1 T10,{esc},1,2,3,4,5,6,7,8,9,0,m,r,n,M,v,a,e
  If ErrorLevel = Max
    {
    OSDwrite("| |")
    sleep,200
    GoSub,WinHotkeysMeta
    }
  If (ErrorLevel = "Timeout" OR ErrorLevel = "EndKey")
    {
    GoSub, Command_Hide
    return
    }

  If FirstNumber is not number
    {
    If (FirstNumber = "M")
      {
      winget,state,minmax,A
      if state = 1
        WinRestore,A
      else
        PostMessage, 0x112, 0xF030,,, A,
      }
    Else If (FirstNumber = "e")
    {
      GoSub, Command_Hide
      exitapp
      return
    }
    Else If (FirstNumber = "A")
    {
      GoSub, Command_Hide
      gosub,AboutHelp
      return
    }
    Else If (FirstNumber = "V")
      {
      GoSub, Command_Hide
      msgbox,NOT DONE!!


      return
      }
    Else If (FirstNumber = "R")
      {
      GoSub, Command_Hide
      Reload
      }
    Else If FirstNumber = n
      {
      gosub, NextGrid
      gosub, command
      return
      }
    GoSub, Command_Hide
    return
    }

  GoSub, Command_Hide
  FirstNumber := FirstNumber + 10
  MoveToGrid(FirstNumber)
  return

WinHotkey:
  MoveToGrid("10")
  return

MoveToPrevious:
  direction = back

MoveToNext:
  if direction <> back
    direction = forward

  WinGetPos,WinLeft,WinTop,WinWidth,WinHeight,A
  current = 0
  loop %NGroups%
  {
    triggerTop := %A_Index%TriggerTop
    triggerBottom := %A_Index%TriggerBottom
    triggerRight := %A_Index%TriggerRight
    triggerLeft := %A_Index%TriggerLeft

    GridToMove := A_index
    GridTop := %GridToMove%GridTop
    GridBottom := %GridToMove%GridBottom
    GridRight := %GridToMove%GridRight
    GridLeft := %GridToMove%GridLeft

    If GridTop = WindowHeight
      continue
    If GridLeft = WindowWidth
      continue
    If GridTop = AlwaysOnTop
      continue
    If GridTop = Maximize
      continue
    If GridTop = Run
      continue
    If GridTop = Restore
      continue

    GridTop := round(GridTop)
    GridBottom := round(GridBottom)
    GridRight := round(GridRight)
    GridLeft := round(GridLeft)

    GridHeight := GridBottom - GridTop
    GridWidth := GridRight - GridLeft

    if (WinTop = GridTop && WinLeft = GridLeft
      && WinHeight = GridHeight && WinWidth = GridWidth)
    {
      current := a_index
      break
    }

  }
  if (current = 0 AND direction = "back")
    current := ngroups + 1

  if direction = forward
  {
    loop %NGroups%
    {
      if (a_index <= current)
        continue

      GridToMove := A_index
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(A_Index)
      direction =
      return
    }
    loop %NGroups%
    {
      GridToMove := A_index
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(A_Index)
      direction =
      return
    }
  }

  if direction = back
  {
    loop %NGroups%
    {
      if (Ngroups - a_index + 1 >= current)
        continue

      GridToMove := NGroups - A_index + 1
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(Ngroups - A_Index + 1)
      direction =
      return
    }
    loop %NGroups%
    {
      GridToMove := NGroups - A_index + 1
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(Ngroups - A_Index + 1)
      direction =
      return
    }
  }
  direction =
  return
; #include Command.ahk



Eval(X)
  {
  Global Monitor1Left
  Global Monitor1Right
  Global Monitor1Top
  Global Monitor1Bottom
  Global Monitor1Width
  Global Monitor1Height
  Global Monitor2Left
  Global Monitor2Right
  Global Monitor2Top
  Global Monitor2Bottom
  Global Monitor2Width
  Global Monitor2Height
  Global Monitor3Left
  Global Monitor3Right
  Global Monitor3Top
  Global Monitor3Bottom
  Global Monitor3Width
  Global Monitor3Height
  Global MonitorReal1Left
  Global MonitorReal1Right
  Global MonitorReal1Top
  Global MonitorReal1Bottom
  Global MonitorReal1Width
  Global MonitorReal1Height
  Global MonitorReal2Left
  Global MonitorReal2Right
  Global MonitorReal2Top
  Global MonitorReal2Bottom
  Global MonitorReal2Width
  Global MonitorReal2Height
  Global MonitorReal3Left
  Global MonitorReal3Right
  Global MonitorReal3Top
  Global MonitorReal3Bottom
  Global MonitorReal3Width
  Global MonitorReal3Height






  StringReplace,x, x, %A_Space%,, All
  StringReplace,x, x, %A_Tab%,, All
  StringReplace,x, x, -, #, All
  StringReplace,x, x, (#, (0#, All
  If (Asc(x) = Asc("#"))
    x = 0%x%
  StringReplace x, x, (+, (, All
  If (Asc(x) = Asc("+"))
    StringTrimLeft x, x, 1
  Loop
  {
    StringGetPos,i, x, [
    IfLess i,0, Break
    StringGetPos,j, x, ], L, i+1
    StringMid,y, x, i+2, j-i-1
    StringLeft,L, x, i
    StringTrimLeft,R, x, j+1
    if (%Y% = "")
      {

      return "Error"
      }
    x := L . %y% . R
  }
  Loop
  {
  StringGetPos,i, x, (, R
  IfLess i,0, Break
  StringGetPos,j, x, ), L, i+1
  StringMid,y, x, i+2, j-i-1
  StringLeft,L, x, i
  StringTrimLeft,R, x, j+1
  x := L . Eval@(y) . R
  }
  Return Eval@(X)
  }

Eval@(x)
  {
  StringGetPos,i, x, +, R
  StringGetPos,j, x, #, R
  If (i > j)
    Return Left(x,i)+Right(x,i)
  If (j > i)
    Return Left(x,j)-Right(x,j)
  StringGetPos,i, x, *, R
  StringGetPos,j, x, /, R
  If (i > j)
    Return Left(x,i)*Right(x,i)
  If (j > i)
    Return Left(x,j)/Right(x,j)
  StringGetPos,i1, x, abs, R
  StringGetPos,i2, x, ceil, R
  StringGetPos,i3, x, floor, R
  m := Max1(i1,i2,i3)
  If (m = i1)
    Return abs(Right(x,i1+2))
  Else If (m = i2)
    Return ceil(Right(x,i2+3))
  Else If (m = i3)
    Return floor(Right(x,i3+4))
  Return x
}

Left(x,i)
{
   StringLeft,x, x, i
   Return Eval@(x)
}
Right(x,i)
{
   StringTrimLeft,x, x, i+1
   Return Eval@(x)
}
Max1(x0,x1="",x2="",x3="",x4="",x5="",x6="",x7="",x8="",x9="",x10="",x11="",x12="",x13="",x14="",x15="",x16="",x17="",x18="",x19="",x20="")
{
   x := x0
   Loop 20
   {
      IfEqual   x%A_Index%,, Break
      IfGreater x%A_Index%, %x%
           x := x%A_Index%
   }
   IfLess x,0, Return -2
   Return %x%
}
; #include calc.ahk
Helper:
  If DropZoneModeFlag
    {
    Tooltip, You can now select where to drop the window.
    return
    }
  CoordMode,Mouse,relative
  CoordMode,Tooltip,relative
  MouseGetPos, OldMouseX, OldMouseY, MouseWin,
  WinGetPos,,,winwidth,,ahk_id %mousewin%
  WinGetTitle,Wintitle,ahk_id %mousewin%
  WinGetClass,WinClass,ahk_id %mousewin%

  if winTitle contains GridMove V%ScriptVersion% by jgpaiva
    return

  If (OldMouseY <= CaptionSize AND OldMouseY > BorderSize + 1
      AND oldmouseX > CaptionSize AND OldMouseX < TitleSize
      AND WinTitle != "" AND WinClass != "Shell_TrayWnd"
      AND TitleSize < WinWidth - 20 AND LButtonDrag)
    {
    Tooltip,You may now drag the window`nto go into drop zone mode
    return
    }
  If (OldMouseY <= CaptionSize AND OldMouseY > BorderSize + 1
      AND WinTitle != "" AND WinClass != "Shell_TrayWnd" AND EdgeDrag)
    {
    KeyWait,LButton,D T0.01
    If errorlevel = 0
      {
      CoordMode, Mouse, Screen
      If (MouseY <= 2 OR MouseX <= 2 OR MouseY >= Monitor1Height -2 OR MouseX >= Monitor1Width -2)
        Tooltip,If you keep the mouse here`ndrop zone mode will be activated
      }
    else
      Tooltip,You can now drag the window to the edge of the screen`nto activate drop zone mode.
    return
    }
    tooltip,
return


Helper2:
  CoordMode,Mouse,Relative
  hCurs := DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt")
  MouseGetPos, OldMouseX, OldMouseY, MouseWin,
  CoordMode,Mouse,screen
  MouseGetPos, MouseX, MouseY, ,
  If (OldMouseY <= CaptionSize AND OldMouseY > BorderSize + 1
      AND oldmouseX > CaptionSize AND OldMouseX < TitleSize
      AND WinTitle != "" AND WinClass != "Shell_TrayWnd"
      AND TitleSize < WinWidth - 20 AND LButtonDrag)
    If not image
    {
    SplashImage , GridMove.bmp, B X%MouseX% y%MouseY%, , , ,
    Image := true
    }
    else
      return
  else
    {
    SplashImage, Off
    Image := false
    }
return
; #include helper.ahk
