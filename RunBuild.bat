::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: RunBuild.bat
:: --------
:: Builds IRS Basis Solution
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal

:: Cache some environment variables.
set ROOT=%~dp0
:: Since the root ends with a \ character, when we quote it on a command line, 
:: it will end with \", which is an escaped quote character. We need to end
:: with \\", which is what the following lines do.
set QUOTEDROOT="%ROOT%"
set QUOTEDROOT=%QUOTEDROOT:\"=\\"% 

:: Set the default arguments
set FLAVOR=debug
set ACTION=
set VERBOSE=
set PAUSEBAT=no
set TARGET=
set BUILDFILE=BuildAndTest.proj
set MasterBuildAll=("C:\tfs\Fusion Rates\BASIS\Source\Dev"/MasterBuildAll)
set TestClient=("C:\tfs\Fusion Rates\BASIS\Source\Dev\Testing\NormalisedClient"/NormalisedClient)

:ParseArgs
:: Parse the incoming arguments
if /i "%1"==""      					goto Build
if /i "%1"=="-?"    					goto Syntax
if /i "%1"=="-v"    					(set VERBOSE=-v)   & shift & goto ParseArgs
if /i "%1"=="debug" 					(set FLAVOR=debug) & shift & goto ParseArgs
if /i "%1"=="-p"    					(set PAUSEBAT=yes) & shift & goto ParseArgs
if /i "%1"=="/t"   						(set MSTARGET=/t:%2) & shift & goto ParseArgs
if /i "%1"=="/b"   						(set BUILDFILE=%2) & shift & goto ParseArgs
if /i "%1"=="/p"   						(set BUILD_PARAMS=/p:%2) & shift & goto ParseArgs
if /i "%1"=="Master"					set TARGET=%MasterBuildAll% & shift & goto ParseArgs
if /i "%1"=="TestClient"				set TARGET=%TestClient% & shift & goto ParseArgs

shift
goto ParseArgs

if DEFINED %TARGET% GOTO Build

goto Error

:Build
pushd %ROOT%

FOR %%a IN %TARGET% DO (
	FOR /f "tokens=1,2 delims=/" %%b in ("%%a") DO (
		echo %%b %%c
		C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe %BUILDFILE% /P:SolutionFolder=%%b /P:SolutionToBuild=%%c /maxcpucount:2 %ACTION% /nologo /verbosity:m /flp:verbosity=m %MSTARGET%
		IF ERRORLEVEL 1 GOTO failed
	)	
)

IF %PAUSEBAT% == yes goto pausefile

popd
goto End

:Error
echo Invalid command line parameter: %1
echo.

:Syntax
echo %~nx0 [-?] [-v] [debug or ship] [clean or build or full or inc]
echo.
echo   -?    			: this help
echo   -v    			: verbose messages
echo   -p    			: Pause build file so you can see the output from the console
echo   Master 			: Build master build all (IRS Utils, etc)
echo   TestClient		: Build the NormalisedClient
echo.
echo.

:pausefile
echo.
echo.
IF ERRORLEVEL 1 goto failed
IF ERRORLEVEL 0 goto sucess

:failed
echo BUILD FAILED
goto pause

:sucess
echo BUILD SUCCESSFUL
goto pause

:pause
pause

:End
endlocal
