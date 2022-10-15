# User settings

# Affinity: Starting from CPU0 to the Max (Right to Left), 1 is Enabled and 0 is Disabled.
# Use the link below to get the Decimal value for your own affinity (e.g: 0101 gives the decimal value of "5", which allows only CPU0 and CPU 2 to be enabled.
# 0101 = Cpu 3=0, Cpu 2=1, Cpu 1=0, Cpu 0=1   (CPU0 is the first value on the right side)

# https://www.mathsisfun.com/binary-decimal-hexadecimal-converter.html

$affinity = 21845





### DONT EDIT BELOW THIS ###


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
        Start-Process powershell.exe -WindowStyle Hidden -Verb RunAs -ArgumentList ('-ExecutionPolicy Bypass -NoLogo -NoProfile -File "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
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
