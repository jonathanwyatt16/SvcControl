@ECHO off
SETLOCAL

SET command=%3
IF "%command%"=="start" GOTO :SvcControl_start
IF "%command%"=="stop" GOTO :SvcControl_stop
IF "%command%"=="status" GOTO :SvcControl_status

:SvcControl_help
ECHO.
ECHO DESCRIPTION:
ECHO 	SvcControl starts, stops, or prints the status of a list 
ECHO 	of services on a list of servers.
ECHO.	 
ECHO USAGE:
ECHO 	SvcControl [server list] [service list] [command]
ECHO 	EX: SvcControl servers.txt services.txt start
ECHO.
ECHO 	PARAMETERS:
ECHO 	[server list]-----.txt file with hostnames of servers to target.
ECHO 	[service list]----.txt file with names of services to target.
ECHO 	[command]---------The command to execute.
ECHO.
ECHO 	COMMANDS:
ECHO 	start-------------Start the service.
ECHO 	stcommand---------Stop the service.
ECHO 	status------------Print the status of the service.
GOTO :EOF

:SvcControl_start
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		sc \\%%A start %%B > HiddenOutput.txt
	)
)
DEL /Q HiddenOutput.txt
GOTO :SvcControl_status

:SvcControl_stop
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		sc \\%%A stop %%B > HiddenOutput.txt
	)
)
DEL /Q HiddenOutput.txt

:SvcControl_status
ECHO.
ECHO SERVER		SERVICE		STATUS
ECHO ------		-------		------
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		FOR /f "tokens=1-3 delims=: " %%C IN ('sc \\%%A query %%B') DO (
			IF %%C==STATE (ECHO %%A		%%B		%%E))
	)
)
ENDLOCAL