@ECHO off
SETLOCAL EnableDelayedExpansion

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
ECHO 	stop--------------Stop the service.
ECHO 	status------------Print the status of the service.
GOTO :EOF

:SvcControl_start
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		ECHO Starting %%B on %%A
		sc \\%%A start %%B > NUL
	)
)
GOTO :SvcControl_status

:SvcControl_stop
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		ECHO Stopping %%B on %%A
		sc \\%%A stop %%B > NUL
	)
)

:SvcControl_status
ECHO.
ECHO SERVER              SERVICE             START TYPE          STATUS
ECHO ------              -------             ----------          ------
FOR /F "" %%A IN (%1) DO (
	FOR /F "" %%B IN (%2) DO (
		SET "svr=%%A                                  "
		SET "svr=!svr:~0,20!"
		SET "svc=%%B                                  "
		SET "svc=!svc:~0,20!"
	
		FOR /f "tokens=1-3 delims=: " %%C IN ('sc \\%%A qc %%B') DO (
			IF %%C==START_TYPE (
				SET "stt=%%E                                  "
				SET "stt=!stt:~0,20!"
			)
		)
		
		FOR /f "tokens=1-3 delims=: " %%C IN ('sc \\%%A query %%B') DO (
			IF %%C==STATE (
				SET "ste=%%E"	
			)
		)
		
		ECHO !svr!!svc!!stt!!ste!
	)
)
ENDLOCAL
