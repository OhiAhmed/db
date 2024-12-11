# Master SQL Build Script - CASEMGNT app

$masterFile = Join-Path $PSScriptRoot "\CASEMGNT Master Script.sql"

$buildMsg = "-- CASEMGNT Master SQL'n"
Set-Content -Path $masterFile -Value $buildMsg
Write-Output $buildMsg

#Set FK Constraints off
Add-Content -Path $masterFile -Value 'SET FOREIGN_KEY_CHECKS = 0;'

$folders = (Get-ChildItem $PSScriptRoot -Directory | sort).FullName

Foreach ($f in $folders) {
 Write-Output ("Processing (0)" -f (Get-Item $f).Name)
 $sqlFiles = Join-Path $f "\*.sql" | Get-Item
 $sqlFiles | sort | foreach { Add-Content -Value $(Get-Content $_) -Path $masterFile}
 }

 # Set FK Constraints Back On
 Add-Content -Path $masterFile -Value 'SET FOREIGN_KEY_CHECKS = 1;'
 
 $completeMsg = "-- CASEMGNT Master SQL Build Complete'n"  
 Add-Content -Path $masterFile -VAlue $completeMsg
 Write-Output $completeMsg
 
 # Write any errors to log file
 # $errorOutFile = Join-Path $PSScriptRoot "\log.txt" 
 # $Error | Out-File $errorOutFile -Append
