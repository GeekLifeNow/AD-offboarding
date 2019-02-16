#Start Script
[string]$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

#--------------------------------------#
# This function writes to the log file #
#--------------------------------------#
function Write-Log {
    <#
    .SYNOPSIS
       Write to a log file with a date-time stamp
    .DESCRIPTION
       This function writes to a logfile. It defaults to the one stored in the logfile variable
    .EXAMPLE
       Write-Log -Text "This is the start of the script log"
    #>
    Param(
    [string]$Text,
    [string]$Path=$LogFile
    )
    If ($Path){
    If (!(Test-path $Path)){
    Add-Content $Path "$(Get-Date -Format G)   Current User: $env:Username" -Encoding UTF8
    Add-Content $Path "$(Get-Date -Format G)   Computer: $env:Computername" -Encoding UTF8
                Add-Content $Path "$(Get-Date -Format G)   Running script from folder: $ScriptPath"
                Add-Content $Path "$(Get-Date -Format G)   __________________________________________________"
    }
    If ($Text) {Add-Content $Path "$(Get-Date -Format G)   $Text" -Encoding UTF8}
    }Else{
    write-error "No Log file specified"
    Exit
    }
}

$DaysBack = "-30"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
$DisabledOU = "OU=Disabled,OU=Users,DC=Company,DC=com"
$UsersToDelete = Get-ADUser -Filter * -SearchBase $DisabledOU -Properties extensionAttribute10
$HomeFolderPath = "E:\UserHomeDrive_Backup"
$LogFile = "C:\Scripts\Logs\DeleteDisabledADUsers_Log.txt"

#Limiting log file size
If ((Get-Item -Path $LogFile -ErrorAction SilentlyContinue).length/1MB -gt 5) {
    $OldName = $LogFile -replace ".txt", ".old"
    If (Test-Path -Path $OldName) {Remove-Item $OldName}
    Rename-Item -Path $LogFile -NewName $OldName
}

Write-Log -Text "Deleting disabled users:" -Path $LogFile

#Looping through the 'Disabled' OU user objects and deleting based on the date set in extensionAttribute10 (Anything older than 30 days)
ForEach($User in $UsersToDelete) {
    $ConvertDate = Get-ADUser $User.SamAccountName -Properties extensionAttribute10 | Select-Object -ExpandProperty extensionAttribute10 | Get-Date
    if ($ConvertDate -lt $DatetoDelete) {
        Try {
        Remove-ADUser -Identity $User.SamAccountName -Confirm:$false -ErrorAction Stop
        Write-Log -Text "Successfully deleted: $($User.SamAccountName)" -Path $LogFile
        }
    Catch {
        Write-Log -Text "Failed to delete: $($User.SamAccountName)" -Path $LogFile
        }
    }
}
    
#Looping through the archived home folder path and deleting anything older than 30 days
Write-Log -Text "Checking dates on archived home folders in $HomeFolderPath" -Path $Logfile
$HomeFoldersArchive = Get-ChildItem $HomeFolderPath | Where-Object { $_.LastWriteTime -lt $DatetoDelete }

Write-Log -Text "Deleting archived home folders > 30 days old:" -Path $LogFile
ForEach ($File in $HomeFoldersArchive){
    try{
        $File | Remove-Item -Force -Recurse -ErrorAction Stop
        Write-Log -Text "Successfully deleted $($File.FullName)" -Path $Logfile
    }
    Catch {
        Write-Log -Text "Failed to delete $($File.FullName)" -Path $Logfile
    }
}