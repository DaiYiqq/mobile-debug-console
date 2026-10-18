@echo off
for %%f in ("%~dp0*.html") do start "" "%%f"
exit /b
