Import-Module ActiveDirectory
Add-Type -Assembly "system.io.compression.filesystem"
$Users = Import-Csv C:\Scripts\UserList.csv
$TermDate = Get-Date -Format d
$Today = Get-Date -UFormat "%m-%d-%Y"

ForEach($User in $Users) {
$CurrentUser = Get-ADUser $User.samAccountName -Properties distinguishedName,HomeDirectory
$BackupDir = "E:\UserHomeDrive_Backup\$($User.SamAccountName)_H-Drive_Termed_$($Today).zip"
Set-ADUser $User.SamAccountName -Description "Disabled by IT on $TermDate" -Enabled $false -Add @{extensionAttribute10="$TermDate"}
Move-ADObject $CurrentUser.distinguishedName -TargetPath "OU=Disabled,OU=Users,DC=Company,DC=com"

IF ( $CurrentUser.HomeDirectory -ne $null ) {
   [io.compression.zipfile]::CreateFromDirectory($CurrentUser.HomeDirectory, $BackupDir)
 }
ELSE {
Continue
}

IF (Test-Path $BackupDir) {
    Remove-Item -Path $CurrentUser.HomeDirectory -Recurse -Force -ErrorAction SilentlyContinue
	}
ELSE {
    exit
}
}
