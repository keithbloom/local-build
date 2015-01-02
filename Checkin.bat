@echo off
call update.bat
call RunBuild.bat
IF ERRORLEVEL 1 GOTO End

"%VS100COMNTOOLS%..\ide\tf.exe" checkin /recursive

:End