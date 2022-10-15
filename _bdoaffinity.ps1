# User settings

# Change this value depending on your machine
$affinity = 21845



# You can check how many processors you have by going to
# Task Manager > Performance > CPU > "Logical Processors" near the bottom right.

# You want to disable every other CPU, if your "Logical Processors" says its 8,
# your value would be: 01010101 (CPU0 (1 enabled) being the first value to the right, and CPU7 (0 disabled) being the last value to the left)

# Use the link below to convert that value from Binary to Decimal for your own affinity,
# for the example above the result would be 85.
# https://www.mathsisfun.com/binary-decimal-hexadecimal-converter.html


# References:

# 1 CPU Enabled = 1
# 2 CPU Enabled = 5
# 3 CPU Enabled = 21
# 4 CPU Enabled = 85
# 5 CPU Enabled = 341
# 6 CPU Enabled = 1365
# 7 CPU Enabled = 5461
# 8 CPU Enabled = 21845












### DONT EDIT ANYTHING BELOW THIS ###

# Ask for admin as BDO binaries requires it.
function Get-UserAdminState {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

#
function Get-BDOProcess {
    Get-Process BlackDesertPatcher32.pae -ErrorAction SilentlyContinue
}

if ((Get-UserAdminState) -eq $false) {
    if (!$elevated) {
        Start-Process powershell.exe -WindowStyle Hidden -Verb RunAs -ArgumentList ('-ExecutionPolicy Bypass -NoProfile -File "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

# cd first into folder instead of accesing the file directly
# otherwise the PALauncher makes you re-download the game again for some odd-reason.
$path = Split-Path $script:MyInvocation.MyCommand.Path
Set-Location $path

# Detect if this is the steam version of BDO
$arg = @{}
if(Test-Path -Path ".\steam_api.dll") { $arg["ArgumentList"] = "--steam" }

# Launch BDO's patcher
Start-Process -NoNewWindow -PassThru -FilePath ".\BlackDesertPatcher32.pae" @arg

# Attempt to get the patcher's process
# If not found after 5 seconds just end the script.
$time = (Get-Date).AddSeconds(5)

do {
    # Wait for child process to start and then set selected CPU affinity
    start-sleep -Seconds 2
    $status = Get-BDOProcess
    if($status) {
        $status | ForEach-Object {
             $_.ProcessorAffinity = $affinity 
        }
        exit
    }
} while((!$status) -and (Get-Date) -lt $time)
