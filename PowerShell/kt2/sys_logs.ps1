$startDatePrompt = Read-Host "Please enter the start date (e.g., 'MM/DD/YYYY')"
$endDatePrompt = Read-Host "Please enter the end date (e.g., 'MM/DD/YYYY')"
$filePathPrompt = Read-Host "Please enter the path to save the file (e.g., 'C:\path\to\file.txt')"

$startTime = [datetime]::ParseExact($startDatePrompt, 'MM/dd/yyyy', $null)
$endTime = [datetime]::ParseExact($endDatePrompt, 'MM/dd/yyyy', $null)

$systemLogs = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    StartTime = $startTime
    EndTime = $endTime
    Level = @(1, 2, 3) 
} -ErrorAction SilentlyContinue

$groupedSystemLogs = $systemLogs | Group-Object { $_.ProviderName } | 
                     Sort-Object { $_.Count } -Descending | 
                     ForEach-Object {
                         $logGroup = $_
                         $logEntries = $logGroup.Group | 
                                       Sort-Object TimeCreated -Descending | 
                                       Select-Object @{
                                           Name="ID"; 
                                           Expression={$_.Id}
                                       }, 
                                       @{
                                           Name="Time"; 
                                           Expression={$_.TimeCreated}
                                       }, 
                                       @{
                                           Name="Message"; 
                                           Expression={$_.Message.Substring(0, [Math]::Min(100, $_.Message.Length))}
                                       }

                         "[ $($logEntries[0].ID) ] [ $($logGroup.Name) ]`n" + 
                         "`n" + ($logEntries | Format-Table -HideTableHeaders | Out-String).Trim() + "`n"
                     }

if (!(Test-Path -Path $(Split-Path -Path $filePathPrompt -Parent))) {
    New-Item -ItemType Directory -Force -Path $(Split-Path -Path $filePathPrompt -Parent)
}

$groupedSystemLogs | Out-File -FilePath $filePathPrompt

Write-Host "System logs saved to: $filePathPrompt"