#description: Script to define regional settings on Azure Virtual Machines to English UK
#execution mode: IndividualWithRestart
#tags: Focus, Nerdio, Preview, Language
# Author: Alexandre Verkinderen
# Modified by Glenn Stockinger 11/07/2023
# Blogpost: https://mscloud.be/configure-regional-settings-and-windows-locales-on-azure-virtual-machines/
<#
Notes:
This script will setup windows OS for English UK Language settings. It will set the Date and time format
as well as the Keyboard layout.

This feature is in preview, and it is recommended that you test in a validation environment
before using in production.

A reboot is required after running this script for the configuration to take effect.
#>

#variables
$regionalsettingsURL = "https://raw.githubusercontent.com/averkinderen/Azure/master/101-ServerBuild/AURegion.xml"
$RegionalSettings = "C:\Windows\AURegion.xml"


#downdload regional settings file
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($regionalsettingsURL,$RegionalSettings)


# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# Set languages/culture. Not needed perse.
Set-WinSystemLocale en-GB
Set-WinUserLanguageList -LanguageList en-GB -Force
Set-Culture -CultureInfo en-GB
Set-WinHomeLocation -GeoId 242
Set-TimeZone -Name "GMT Standard Time"

# restart virtual machine to apply regional settings to current user. You could also do a logoff and login.
Start-sleep -Seconds 40
Restart-Computer