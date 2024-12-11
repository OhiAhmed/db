> **Before proceeding**
>
>Copy the folder 'mysql-maria' to your own project's repo

# CASEMGNT Database Repo
Repo for CASEMGNT database artifacts

\\ Idempotent Database Scripts
*All scripts in this repo should idempotent, allowing the master SQL script to be executed repeatedly on any database environment to
migrate it to the latest versoin,
*Helper functions (with the IDEM_prefix) are provided to make this simpler doe developer.
$Examples of how to use the idempotent script framwork are provided in 'CHEAT_SHEET.sql'

## How to build a master SQL script
* Run the Powershell script 'build-master.ps1' located in the CASEMGNT folder.
* The 'CASEMGNT Master Script.sql' file will be overwritten with the latest DB scripts, extracted from the folders in the current directory
*Use only the master SQL script  for deployment

 