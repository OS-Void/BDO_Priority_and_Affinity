command = "powershell.exe -ExecutionPolicy Bypass -File .\_bdoaffinity.ps1"

Set objShell = CreateObject("Wscript.shell")
objShell.Run command,0