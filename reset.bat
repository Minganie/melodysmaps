@echo off
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"

set "datestamp=%YYYY%%MM%%DD%"

IF "%CD:~0,1%" == "C" (
	cd C:\Program Files\PostgreSQL\11\bin
	set filename=C:\xampp\htdocs\melodysmaps\ffxiv%datestamp%.backup
) ELSE (
	D:
	cd D:\Programmes\Postgres\11\bin
	set filename=D:\Programmes\xamp\htdocs\melodysmaps\ffxiv%datestamp%.backup
)

pg_restore.exe -U postgres -d postgres --clean --create %filename%
PAUSE