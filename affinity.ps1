# User settings

# Affinity: Starting from CPU0 to the Max (Right to Left), 1 is Enabled and 0 is Disabled.
# Use the link below to get the Decimal value for your own affinity (e.g: 0101 gives the decimal value of "5", which allows only CPU0 and CPU 2 to be enabled.
# 0101 = Cpu 3=0, Cpu 2=1, Cpu 1=0, Cpu 0=1   (CPU0 is the first value on the right side)
# Use: https://www.mathsisfun.com/binary-decimal-hexadecimal-converter.html for the affinity

$steam = $true
$path = "C:\Program Files (x86)\Steam\steamapps\common\Black Desert Online\"
$affinity = 21845






### DONT EDIT BELOW THIS ###


# Ask for admin as BDO binaries requires it.
function Check-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Check-Admin) -eq $false) {
    if (!$elevated) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

$arg = @{}
if($steam) { $arg["ArgumentList"] = "--steam" }

# cd first into folder instead of accesing the file directly
# otherwise the PALauncher makes you re-download the game again.
cd ${path}
$app = Start-Process -NoNewWindow -PassThru -FilePath ".\BlackDesertPatcher32.pae" @arg

# Attempt to get the patcher's process
# If not found after 5 tries just end the script.
for($tries = 0; $tries -le 5; $tries++) {
    $status = Get-Process BlackDesertPatcher32.pae -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1

    if($status) {
        # Honestly, only the first PA process needs the affinity,
        # but might as well do it to all 3 of them just in case.
        foreach($process in $status) {
            $process.ProcessorAffinity=$affinity
        }
    }
}
