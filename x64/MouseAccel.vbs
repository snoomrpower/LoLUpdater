Const HKEY_CURRENT_USER = &H80000001
strComputer = InputBox("Enter the name of the computer")
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _
strComputer & "\root\default:StdRegProv")
strKeyPath = "Control Panel\Mouse"
strEntryName = "MouseSpeed"
strValue = "0"
objReg.SetStringValue HKEY_CURRENT_USER, strKeyPath, _
strEntryName, strValue