This Fork
========

This is an attempted minimal fork of Gridmove to allow setting windows via other hotkey scripts.  It starts with a decompiled copy of gridmove v.  1.19.62 and modifies the minimum number of lines necessary to get Gridmove to accept AHK input on my system.

The issue that motivated this fork is here:  https://github.com/jgpaiva/GridMove/issues/4

I am putting this up in public so I have easy access to the code when I start a new system.  Use at your own risk. 


To use this fork:
========
* Download and install gridmove
* Download this repo, compile gridmove.ahk
* Replace the installed GridMove.exe with the one you just compiled.
* (optional) Copy the teds.grids to the grids directory


Controlling Gridmove with another AHK script:
========
* Enable HotKeys > Use Command
* Add a MoveWinToGrid command to set the move.to file

```
MoveWinToGrid(GridNum) {
  IfNotExist,%A_AppData%/DonationCoder/ 
  {
    FileCreateDir,%A_AppData%/DonationCoder/
  }
  IfNotExist,%A_AppData%/DonationCoder/GridMove
  {
    FileCreateDir,%A_AppData%/DonationCoder/GridMove
  }  
  ScriptDir = %A_AppData%/DonationCoder/GridMove/move.to
  FileAppend, ,%ScriptDir%
  IniWrite,%GridNum%         ,%ScriptDir%,MoveToHere,MoveToHere  
  sleep 200
  Send #g
  sleep 200
}

```

GridMove
========

GridMove is a Windows program that aims at making windows management easier. It helps you with this task by defining a visual grid on your desktop, to which you can easily snap windows. It is built with [AutoHotkey](http://www.autohotkey.com "AutoHotKey"), a scripting language for desktop automation for Windows.

More information at [GridMove's homepage](http://jgpaiva.dcmembers.com/gridmove.html).

This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License.
