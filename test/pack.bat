@echo off

set source="C:\Date"
set destination="C:\Temp"
set passwd="Password"
set dd=%DATE:~0,2%
set mm=%DATE:~3,2%
set yyyy=%DATE:~6,4%
set curdate=%dd%-%mm%-%yyyy%

"C:\Program Files\7-Zip\7z.exe" a -tzip -ssw -mx1 -p%passwd% -r0 %destination%\backup_%curdate%.zip %source%