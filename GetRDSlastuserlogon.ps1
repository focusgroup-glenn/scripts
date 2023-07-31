Apologies for the confusion. You're right; the `Get-RDUserSession` cmdlet doesn't provide the last logon time directly. To get the last logon time for users in an RDS farm, we need to use a different approach. One way is to query the Windows event logs to find the last logon event for each user. Here's an updated PowerShell script that accomplishes this:

```powershell
# Function to convert FileTime to DateTime
function Convert-FileTimeToDateTime {
    param([int64]$fileTime)
    $epochStart = [DateTime]::FromFileTimeUtc(0)
    $convertedTime = $epochStart.AddSeconds($fileTime / 10000000)
    return $convertedTime
}

# Get all user sessions in the RDS farm
$sessions = Get-RDUserSession

# Create an array to store the results
$report = @()

# Loop through each session and retrieve the user information
foreach ($session in $sessions) {
    $user = Get-ADUser -Identity $session.UserName

    # Query the security event logs to find the last logon event for the user
    $lastLogonEvent = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        ID        = 4624
        StartTime = (Get-Date).AddDays(-30)  # Change this if you want to search for a different time range
        EndTime   = Get-Date
    } | Where-Object { $_.Properties[5].Value -eq $user.SamAccountName } | Sort-Object TimeCreated -Descending | Select-Object -First 1

    # Check if the last logon event was found, and extract the last logon time
    if ($lastLogonEvent) {
        $lastLogonTime = Convert-FileTimeToDateTime($lastLogonEvent.TimeCreated.ToFileTime())
    } else {
        $lastLogonTime = "N/A"
    }

    # Create a custom PowerShell object for the user with relevant properties
    $userObject = New-Object PSObject -property @{
        "Username"     = $user.SamAccountName
        "SessionID"    = $session.SessionId
        "LastLogon"    = $lastLogonTime
        "LogonServer"  = $session.HostServer
    }

    # Add the user object to the report array
    $report += $userObject
}

# Sort the report by LastLogon date in descending order
$report = $report | Sort-Object LastLogon -Descending

# Display the report
$report | Format-Table -AutoSize
```

This script now queries the Windows security event logs (ID 4624) to find the last logon event for each user within the last 30 days. It then extracts the last logon time from the event and includes it in the report. The report is sorted by the most recent last logon date first.

Again, make sure you have the necessary permissions to run the script and access event logs on the RDS farm. Adjust the time range in the `StartTime` parameter of `Get-WinEvent` if you want to search for a different period.
