# priority: Change this to set the game's priority (eg. High, Normal, Low)
# Default: Normal
# Notes: Set to High or leave it as Normal
$priority = "Normal"

# affinity: Change this value depending on your machine's CPU core count 
# Notes: Set the value to the amount if half your CPUs
$affinity = 85

# Affinity References:

# 8  Cores ~ 4 CPU Enabled = 85
# 12 Cores ~ 6 CPU Enabled = 1365
# 16 Cores ~ 8 CPU Enabled = 21845

# HOW TO:

# You can check how many processors you have by going to
# Task Manager > Performance > CPU > "Logical Processors" near the bottom right.

# You want to disable every other CPU, if your "Logical Processors" says its 8,
# Reading your value from right to left would be: 01010101 (CPU0 (1 enabled) being the last value to the right, and CPU7 (0 disabled) being the last value to the left)
# CPU0 to CPU7 = 8 CPUs (CPU0 Counts)

# Use the link below to convert that value from Binary to Decimal for your own affinity,
# for the example above the result would be 85.
# https://www.mathsisfun.com/binary-decimal-hexadecimal-converter.html





### DONT EDIT ANYTHING BELOW THIS ###

# Run as invoker (UAC Bypass)
[System.Environment]::SetEnvironmentVariable("__COMPAT_LAYER", "RunAsInvoker", [System.EnvironmentVariableTarget]::Process)

# Set the current directory first instead of accessing the file directly
Set-Location $PSScriptRoot

$processName = "BlackDesertPatcher32.exe"

# Check if this is the steam version of BDO
$arg = @{}
if (Test-Path -Path ".\steam_appid.txt") { $arg["ArgumentList"] = "--steam" }

# Start the process and set its priority and affinity
$process = Start-Process -FilePath ".\$processName" @arg -PassThru -NoNewWindow
$process.PriorityClass = $priority
$process.ProcessorAffinity = $affinity
