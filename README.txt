This script will read a list of usernames (SamAccountName) from a .csv and do the following:

- Disable the user object
- Set a description on the user object with "Disabled by IT on (whatever the date the script is run)."
- Puts the current date in extensionAttribute10 (This is to help with automation of user deletions later on)
- Move the user object to a 'Disabled' OU
- Check for a home folder
- If home drive is found, zip it up and place the .zip in an archive location
- Delete the home folder

Variables:

$Users = Import-Csv C:\Scripts\UserList.csv
This is the .csv that contains the usernames to off-board. Template provided.

$BackupDir = "E:\UserHomeDrive_Backup\$($User.SamAccountName)_H-Drive_Termed_$($Today).zip"
This is where you want to archive the home folder of the user(s). This is currently saving it locally to E:\UserHomeDriveBackup

============================
Automated Deletion/Cleanup
============================

Set:

User_Data_Cleanup-ScheduledTask.ps1

...as a scheduled task to do the following:

- Read the 'Disabled' OU and get the date in extensionAttribute10
- Delete user objects older than 30 days (set for your own company policy)
- Delete any archived home folders in E:\UserHomeDrive_Backup older than 30 days (set for your own company policy)
- Logging

